import 'package:flutter/material.dart';
import 'package:aladdin_app/src/features/splash/splash_screen.dart'; // ✅ package import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // ✅ key parameter with super

  @override
  Widget build(BuildContext context) {
    return const MaterialApp( // ✅ const
      title: 'Aladdin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // اختیاری: تھیم شامل کی
      ),
      home: SplashScreen(), // ✅ const
    );
  }
}
