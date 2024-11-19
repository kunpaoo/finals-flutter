import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item.dart';

class Dashboard extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Dashboard({super.key});

  Future<List<Map<String, dynamic>>> fetchList() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('events').get();
      List<Map<String, dynamic>> list = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return list;
    } catch (e) {
      print("Error fetching list: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Univents')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data found"));
          } else {
            // Display the list
            List<Map<String, dynamic>> list = snapshot.data!;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return InkWell(
                   onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Item(item: item),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 13.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            list[index]['photoUrls'][0],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover, 
                          ),
                        ),
                        const SizedBox(width: 16), 
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list[index]['name'] ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                list[index]['description'] ?? 'No Description',
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                maxLines: 2, 
                                overflow: TextOverflow.ellipsis, 
                              ),
                              SizedBox(height:16),
                              Text(
                                list[index]['location'] ?? 'No Location',
                                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                                maxLines:1,
                                overflow: TextOverflow.clip, 
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
