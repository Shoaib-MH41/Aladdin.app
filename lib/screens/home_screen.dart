import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Aladdin App"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.deepPurple.shade900, Colors.black]
                : [Colors.deepPurple.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCard(
                  context,
                  icon: Icons.folder,
                  title: "My Projects",
                  color: Colors.blue,
                  route: '/projects',
                ),
                const SizedBox(height: 20),
                _buildCard(
                  context,
                  icon: Icons.add_circle,
                  title: "New Project",
                  color: Colors.green,
                  route: '/select',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required String route}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        color: color.withOpacity(0.9),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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
