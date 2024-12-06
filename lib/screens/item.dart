import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Item extends StatelessWidget {
  final Map<String, dynamic> item;
  const Item({Key? key, required this.item}) : super(key: key);

  // Function to parse the date string and convert it into DateTime object
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

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = List<String>.from(item['photoUrls'] ?? []);

    Color primary = const Color.fromARGB(255, 8, 100, 175);
    // Get the date field from Firebase
    var dateField = item['date'];

    String formattedDate = '';
    if (dateField != null) {
      if (dateField is Timestamp) {
        DateTime itemDate = dateField.toDate();

        formattedDate = DateFormat('MMMM dd, yyyy hh:mm:ss a').format(itemDate);
      } else if (dateField is String) {
        DateTime itemDate = parseDateString(dateField);
        formattedDate = DateFormat('MMMM dd, yyyy hh:mm:ss a').format(itemDate);
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Event Detail',
            style: TextStyle(
                color: Color.fromARGB(221, 85, 85, 85),
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.pushNamed(context, '/chat');
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 237, 240, 253),
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
              title: const Text('Home'),
              onTap: () {
                Navigator.popAndPushNamed(context, '/home');
              },
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
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  autoPlay: true,
                  aspectRatio: 9 / 16,
                  viewportFraction: 0.9,
                ),
                items: imageUrls.map((url) {
                  return Container(
                    clipBehavior: Clip.hardEdge,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(8.0),
                    child: Image.network(
                      url,
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['name'] ?? 'No Name'}',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: primary,
                          height: 1.1),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.blueGrey,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${item['location'] ?? 'No Location'}',
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${item['description'] ?? 'No Description'}',
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 97, 97, 97)),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: primary)),
                      clipBehavior: Clip.hardEdge,
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(color: primary),
                              child: Icon(
                                Icons.date_range_rounded,
                                color: Colors.white,
                              )),
                          Container(
                            padding: EdgeInsets.only(right: 40),
                            child: Text(
                              DateFormat("MMMM dd yyyy")
                                  .format(item["date"].toDate()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromARGB(255, 53, 53, 53)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: primary)),
                      clipBehavior: Clip.hardEdge,
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 40),
                            child: Text(
                              DateFormat("hh:mm a")
                                  .format(item["date"].toDate()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromARGB(255, 53, 53, 53)),
                            ),
                          ),
                          Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(color: primary),
                              child: Icon(
                                Icons.access_time,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container dateBlock(Color primary, String text, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary)),
      clipBehavior: Clip.hardEdge,
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(color: primary),
              child: Icon(
                icon,
                color: Colors.white,
              )),
          Container(
            padding: EdgeInsets.only(right: 40),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 53, 53, 53)),
            ),
          ),
        ],
      ),
    );
  }
}
