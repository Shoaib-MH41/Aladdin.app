import 'package:flutter/material.dart';

class MobilePage extends StatelessWidget {
  const MobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobile App Options"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.android, color: Colors.green),
            title: Text("Android OS"),
          ),
          ListTile(
            leading: Icon(Icons.flutter_dash, color: Colors.blue),
            title: Text("Flutter"),
          ),
          ListTile(
            leading: Icon(Icons.code, color: Colors.deepOrange),
            title: Text("Java"),
          ),
          ListTile(
            leading: Icon(Icons.phone_iphone, color: Colors.purple),
            title: Text("iOS (Swift)"),
          ),
        ],
      ),
    );
  }
}


