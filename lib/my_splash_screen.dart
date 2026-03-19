import 'package:cat_dog_detection/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      title: Text("Cat and Dog Detection"),
      seconds: 2,
      navigateAfterSeconds: HomeScreen(title: "Cat and Dog Detection"),
      backgroundColor: Colors.blueGrey,
      styleTextUnderTheLoader: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      loadingText: Text("Welcome to Detection App"),
      loadingTextPadding: EdgeInsets.all(5),
      useLoader: true,
      image:  Image.asset('assets/images/cat_dog_icon.png'),
    );
  }
}
