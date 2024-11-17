import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:univents/screens/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event){
      setState((){
        _user = event;
      });
    });
  }

  void _handleAnonymousSignIn() async{
    try {
      final userCredential =
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const Dashboard(),
      ),
    );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  void _handleGoogleSignIn() async {
  try {
    GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
        UserCredential userCredential = await _auth.signInWithProvider(googleAuthProvider);
    
    if (userCredential.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const Dashboard(),
        ),
      );
    }
  } catch (error) {
    print("Error during Google Sign-In: $error");
  }
}



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color primary = const Color.fromARGB(255, 8, 100, 175);

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
                padding: const EdgeInsets.all(20),
                width: size.width,
                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://www.addu.edu.ph/wp-content/uploads/2020/08/UniversitySealWhite-1024x1020.png",
                          height: 80,
                        ),
                        const SizedBox(width: 20),
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
                    const SizedBox(height: 40),
                    const Text(
                      "Login",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 40),
                    ),
                    const SizedBox(height: 40),
                    InputText("Email"),
                    InputText("Password", true),
                    SizedBox(
                      width: double.infinity,
                      child: const Text(
                        "Forgot your Password?",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      onPressed: () {
                        _handleAnonymousSignIn();
                      },
                      color: primary,
                      minWidth: double.infinity,
                      elevation: 10,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        "Sign in",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        "Create new account",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      "or continue with",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    MaterialButton(
                      onPressed: () {
                        _handleGoogleSignIn();
                        
                      },
                      color: Colors.white,
                      minWidth: double.infinity,
                      elevation: 10,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Sign in with Google",
                        style: TextStyle(
                            color: primary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _userInfo(){
    return SizedBox();
  }




Container InputText(String label, [bool password = false]) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: TextFormField(
      style: const TextStyle(fontSize: 15),
      obscureText: password,
      obscuringCharacter: '*',
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(15),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        floatingLabelStyle: const TextStyle(color: Color.fromRGBO(31, 65, 187, 1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        fillColor: const Color.fromRGBO(241, 244, 255, 1),
        filled: true,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(31, 65, 187, 1)),
        ),
      ),
    ),
  );
  

}
