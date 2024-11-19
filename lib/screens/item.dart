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

    // Get the date field from Firebase
    var dateField = item['date'];

    String formattedDate = '';
    if (dateField != null) {
      if (dateField is Timestamp) {
        DateTime itemDate = dateField.toDate(); 

        formattedDate = DateFormat('MMMM dd, yyyy \n hh:mm:ss a').format(itemDate);
      } else if (dateField is String) {
        DateTime itemDate = parseDateString(dateField);
        formattedDate = DateFormat('MMMM dd, yyyy \n hh:mm:ss a').format(itemDate);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(item['name'] ?? 'Item Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 300, 
                enlargeCenterPage: true, 
                autoPlay: true, 
                aspectRatio: 16 / 9, 
                viewportFraction: 0.8, 
              ),
              items: imageUrls.map((url) {
                return Builder(
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          url,
                          width: MediaQuery.of(context).size.width,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Name: ${item['name'] ?? 'No Name'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${item['location'] ?? 'No Location'}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${item['description'] ?? 'No Description'}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Date: $formattedDate',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
