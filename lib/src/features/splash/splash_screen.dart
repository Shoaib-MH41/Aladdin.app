import 'package:flutter/material.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/navigation.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigation.pushReplacement(context, AppTypeSelectionScreen());
    });

    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                AppStrings.appName,
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
