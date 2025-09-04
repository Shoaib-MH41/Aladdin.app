

'package:flutter/material.dart';

class MobilePage extends StatelessWidget {
  const MobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobile Page"),
        backgroundColor: Colors.indigo,
      ),
      body: const Center(
        child: Text(
          "This is the Mobile version of Aladdin App",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

