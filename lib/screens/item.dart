import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Timestamp

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
              title: const Text('Home'),
              onTap: () {
                Navigator.popAndPushNamed(context, '/home');
              },
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
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 400,
                autoPlay: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
              items: imageUrls.map((url) {
                return Image.network(
                  url,
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  fit: BoxFit.cover,
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
                    formattedDate,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${item['name'] ?? 'No Name'}',
                    style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.bold,
                        color: primary,
                        height: 1.1),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 15),
                  Text(
                    '${item['description'] ?? 'No Description'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: primary,
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          '${item['location'] ?? 'No Location'}',
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
