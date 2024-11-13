import 'dart:ui';

import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Center(
      child: Container(
        height: size.height,
        child: Stack(
          children: [
            ClipRRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Image.network(
                  "https://wp.atenews.ph/wp-content/uploads/2016/06/Finster_Hall_Ateneo_de_Davao_University_2007-1.jpg",
                  fit: BoxFit.cover,
                  height: size.height,
                  color: const Color.fromARGB(255, 8, 100, 175),
                  colorBlendMode: BlendMode.multiply,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              width: size.width,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Logo",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Login",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 40),
                  ),
                  Text("Email"),
                  Text("Password"),
                  Text("Submit")
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
