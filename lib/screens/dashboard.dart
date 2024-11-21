import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(
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
        backgroundColor: const Color.fromARGB(255, 8, 100, 175),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
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
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data found"));
          } else {
            // Display the list
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(15, 20, 10, 0),
                      child: const Text(
                        "Ongoing Events",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromARGB(255, 8, 100, 175),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    ...ongoingEvents(),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(15, 20, 10, 0),
                      child: const Text(
                        "Upcoming Events",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromARGB(255, 8, 100, 175),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    ...upcomingEvents(),
                    SizedBox(height: 40)
                  ]),
            );
          }
        },
      ),
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
      DateFormat dateFormat = DateFormat('MMMM dd, yyyy');
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

      return combinedDateTime;
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

    bool isSameDayAsPrev = prevItem["id"] != item['id']
        ? (item["date"] as Timestamp)
            .toDate()
            .isAtSameMomentAs((prevItem["date"] as Timestamp).toDate())
        : false;

    return Column(
      children: [
        isSameDayAsPrev
            ? SizedBox(height: 10)
            : Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 8, 100, 175),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  item['photoUrls'][0],
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
                      item['name'] ?? 'No Name',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, height: 1),
                    ),
                    SizedBox(height: 10),
                    Text(
                      item['description'] ?? 'No Description',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
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
    );
  }
}
