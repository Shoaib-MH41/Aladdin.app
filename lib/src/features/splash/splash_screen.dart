import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../app_type_selection/app_type_selection_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppTypeSelectionScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/aladdin_lamp.json',
                width: 200, // اینیمیشن کا سائز کنٹرول
                height: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text(
                'علادین ایپ',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
