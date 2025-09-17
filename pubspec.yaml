import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../app_type_selection/app_type_selection_screen.dart'; // اگلی اسکرین کا امپورٹ، بعد میں بنائیں گے

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
      backgroundColor: Colors.blue[900], // جادوئی بیک گراؤنڈ
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/aladdin_lamp.json'), // تمہارا اینیمیشن فائل
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppTypeSelectionScreen()),
                );
              },
              child: Text('شروع کریں'),
            ),
          ],
        ),
      ),
    );
  }
}
