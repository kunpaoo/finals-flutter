import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    FirebaseFirestore.instance.collection('chats').add({
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'userId': user?.uid,
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(
              color: Color.fromARGB(221, 85, 85, 85),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(241, 244, 255, 1),
      ),
      backgroundColor: const Color.fromRGBO(241, 244, 255, 1),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Chat messages list
            Expanded(
              child: Container(
                width: 300,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('userId',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No messages yet.'));
                    }

                    final chatDocs = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: chatDocs.length,
                      itemBuilder: (ctx, index) {
                        final chatData =
                            chatDocs[index].data() as Map<String, dynamic>;

                        return Container(
                          constraints: BoxConstraints(maxWidth: 30),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color.fromARGB(
                                        255, 214, 214, 214),
                                    offset: Offset(-0.5, 1.5),
                                    blurRadius: 1)
                              ]),
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          width: 30,
                          child: ListTile(
                            title: Text(
                              chatData['message'],
                              textAlign: TextAlign.right,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            subtitle: Text(
                              'Sent at: ${chatData['timestamp']?.toDate().toString() ?? 'Unknown'}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // Input area
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: "Type a message...",
                        fillColor: Colors.white,
                        filled: true,
                        floatingLabelStyle: const TextStyle(
                            color: Color.fromRGBO(31, 65, 187, 1)),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color.fromRGBO(31, 65, 187, 1)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
