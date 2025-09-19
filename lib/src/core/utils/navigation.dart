import 'package:flutter/material.dart';

class Navigation {
  static Future<T?> push<T extends Object?>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(builder: (context) => screen),
    );
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget screen, {
    TO? result,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute<T>(builder: (context) => screen),
      result: result,
    );
  }

  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      route,
      arguments: arguments,
    );
  }
}
