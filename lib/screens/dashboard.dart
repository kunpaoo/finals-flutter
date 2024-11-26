import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:univents/search.dart';
import 'item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _listFuture;
  Future<List<Map<String, dynamic>>>? _listShow;

  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();

    _listFuture = fetchList();
    _listShow = _listFuture;

    _searchController.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

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

  void handleSearch(String value) {
    _searchFocusNode.unfocus();

    if (value.isNotEmpty) {
      _searchHistoryService.addSearchToHistory(value);
    }
    setState(() {
      _isSearchFocused = false;
      _listShow = _listFuture?.then((list) => list
          .where(
              (item) => item["name"].toString().toLowerCase().contains(value))
          .toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      drawer: menu(context),
      backgroundColor: const Color.fromARGB(255, 243, 246, 248),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 177, 200, 211))),
              child: SearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: "Search an event...",
                hintStyle: const WidgetStatePropertyAll(TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.black)),
                leading: const Icon(
                  Icons.search,
                  color: Colors.blueGrey,
                ),
                backgroundColor: const WidgetStatePropertyAll(
                    Color.fromARGB(255, 255, 255, 255)),
                elevation: WidgetStatePropertyAll(0.1),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4))),
                onSubmitted: (value) => handleSearch(value.toLowerCase()),
              ),
            ),
            if (_isSearchFocused)
              StreamBuilder<List<String>>(
                stream: _searchHistoryService.getSearchHistory(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index]),
                        onTap: () {
                          _searchController.text = snapshot.data![index];
                        },
                      );
                    },
                  );
                },
              ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _listShow,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data found"));
                } else {
                  List<Map<String, dynamic>> list = snapshot.data!;

                  DateTime now = DateTime.now();
                  List<Map<String, dynamic>> upcoming = list.where((item) {
                    DateTime itemDate = item["date"].toDate();
                    return itemDate.isAfter(now);
                  }).toList();

                  List<Map<String, dynamic>> ongoing = list.where((item) {
                    DateTime itemDate = item["date"].toDate();
                    return itemDate.isAtSameMomentAs(now);
                  }).toList();

                  List ongoingEvents() {
                    if (ongoing.length > 0) {
                      return ongoing.map((item) {
                        var index = list.indexOf(item);
                        var prevItem = list[index > 0 ? index - 1 : index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Item(item: item),
                              ),
                            );
                          },
                          child: Card(item: item, prevItem: prevItem),
                        );
                      }).toList();
                    } else {
                      return [
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("No Ongoing events"),
                        ))
                      ];
                    }
                  }

                  List upcomingEvents() {
                    if (upcoming.length > 0) {
                      return upcoming.map((item) {
                        var index = list.indexOf(item);
                        var prevItem = list[index > 0 ? index - 1 : index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Item(item: item),
                              ),
                            );
                          },
                          child: Card(item: item, prevItem: prevItem),
                        );
                      }).toList();
                    } else {
                      return [
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("No Upcoming events"),
                        ))
                      ];
                    }
                  }

                  return SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),
                          eventHeader("Ongoing Events"),
                          ...ongoingEvents(),
                          SizedBox(height: 20),
                          eventHeader("Upcoming Events"),
                          ...upcomingEvents(),
                          SizedBox(height: 40)
                        ]),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Container eventHeader(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      margin: EdgeInsets.only(
        bottom: 8,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        name,
        textAlign: TextAlign.left,
        style: const TextStyle(
            color: Color.fromARGB(255, 5, 39, 70),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.2),
      ),
    );
  }

  Drawer menu(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
                color: const Color.fromARGB(255, 8, 100, 175)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.network(
                  "https://www.addu.edu.ph/wp-content/uploads/2020/08/UniversitySealWhite-1024x1020.png",
                  height: 80,
                ),
                SizedBox(width: 20),
                const Text(
                  "UNIVENTS",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    letterSpacing: -1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              } catch (e) {
                print('Error logging out: $e');
              }
            },
          )
        ],
      ),
    );
  }

  AppBar Header() {
    return AppBar(
      title: const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Text(
          'UNIVENTS',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      leading: Builder(builder: (context) {
        return Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(5),
          child: IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        );
      }),
      actions: [
      IconButton(
        icon: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
            Navigator.pushNamed(context, '/chat');
        },
      ),
    ],
      backgroundColor: const Color.fromARGB(255, 8, 100, 175),
    );
  }
}

class Card extends StatelessWidget {
  const Card({super.key, required this.item, required this.prevItem});

  final item;
  final prevItem;

  @override
  Widget build(BuildContext context) {
    var dateField = item['date'];

    String formattedDate = '';

    DateTime parseDateString(String dateString) {
      print(dateString);
      final datePart = dateString.split(' at ')[0];
      final timePart = dateString.split(' at ')[1].split(' UTC')[0];

      // Parse the date and time separately
      DateFormat dateFormat = DateFormat('MM dd, yyyy');
      DateFormat timeFormat = DateFormat('h:mm:ss');

      // Parse date and time
      DateTime date = dateFormat.parse(datePart);
      DateTime time = timeFormat.parse(timePart);

      // Combine the date and time
      DateTime combinedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      return date;
    }

    if (dateField != null) {
      if (dateField is Timestamp) {
        DateTime itemDate = dateField.toDate();

        formattedDate = DateFormat('MMMM dd, yyyy').format(itemDate);
      } else if (dateField is String) {
        DateTime itemDate = parseDateString(dateField);
        formattedDate = DateFormat('MMMM dd, yyyy').format(itemDate);
      }
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: Colors.white),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Column(
        children: [
          Image.network(
            item['photoUrls'][0],
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 8, 100, 175),
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat("MMM")
                            .format(item["date"].toDate())
                            .toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            height: 1),
                      ),
                      Text(
                        DateFormat("dd").format(item["date"].toDate()),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 45,
                            height: 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(height: 6),
                      Text(
                        item['name'] ?? 'No Name',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      ),
                      SizedBox(height: 3),
                      Text(
                        item['description'] ?? 'No Description',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['location'] ?? 'No Location',
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
