import 'package:flutter/material.dart';

class Navigation {
  static void push<T>(BuildContext context, Widget screen) {
    Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static void pushReplacement<T>(BuildContext context, Widget screen) {
    Navigator.pushReplacement<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static void pushNamed(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }
}
