import 'package:flutter/material.dart';
import 'src/features/splash/splash_screen.dart';

void main() {
  runApp(AladdinApp());
}

class AladdinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'علادین ایپ',
      theme: ThemeData(
        primarySwatch: Colors.blue, // پرائمری رنگ، بعد میں تبدیل کر سکتے ہو
        fontFamily: 'Poppins', // فانٹ، pubspec.yaml میں شامل کرو
      ),
      home: SplashScreen(), // پہلی اسکرین اسپلاش ہوگی
    );
  }
}
