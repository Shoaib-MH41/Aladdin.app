
import 'package:flutter/material.dart';

class WebPage extends StatelessWidget {
  const WebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Web App Options"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.language, color: Colors.blue),
            title: Text("HTML & CSS"),
          ),
          ListTile(
            leading: Icon(Icons.javascript, color: Colors.amber),
            title: Text("JavaScript"),
          ),
          ListTile(
            leading: Icon(Icons.web, color: Colors.indigo),
            title: Text("React / Vue / Angular"),
          ),
          ListTile(
            leading: Icon(Icons.api, color: Colors.red),
            title: Text("Backend APIs"),
          ),
        ],
      ),
    );
  }
}

