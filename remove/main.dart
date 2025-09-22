import 'package:flutter/material.dart';
import 'package:aladdin_app/src/features/splash/splash_screen.dart'; // splash screen import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // key → super.key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aladdin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // const لگایا
    );
  }
}
