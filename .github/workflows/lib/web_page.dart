
'package:flutter/material.dart';

class WebPage extends StatelessWidget {
  const WebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Web Page"),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          "This is the Web version of Aladdin App",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

