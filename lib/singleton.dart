import 'package:flutter/widgets.dart';

class Singleton extends ChangeNotifier {
  static final Singleton _instance = Singleton._internal();

  factory Singleton() => _instance;

  Singleton._internal();

  void notifyListenersSafe() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Map<String, dynamic>? userdata;
}
