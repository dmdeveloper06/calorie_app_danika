import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:calorie_app_danika/authentication/login.dart';
import 'package:calorie_app_danika/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calorie_app_danika/services/singleton.dart';
import 'size_config.dart';

class Initializer extends StatelessWidget {
  const Initializer({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    Singleton _singleton = Singleton();

    if (FirebaseAuth.instance.currentUser == null) {
      return LoginScreen();
    }

    return StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref("users/${FirebaseAuth.instance.currentUser!.uid}")
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.snapshot.value != null) {
              _singleton.setUserData(Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map));
            }
            print(_singleton.userdata?["daily_log"]);

            final ref = FirebaseDatabase.instance.ref();
            ref.child('calorie_reference').get().then(
              (value) {
                if (value.exists) {
                  print(value.value);
                  _singleton.calorieReference =
                      Map<String, dynamic>.from(value.value as Map);
                } else {
                  print('No data available.');
                }
              },
            );
            // print current timestamp
            // print(DateTime.now().millisecondsSinceEpoch);

            return StreamBuilder(
                stream: FirebaseDatabase.instance.ref("ai_server_url").onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.snapshot.value != null) {
                      print(
                          "Setting server URL to ${snapshot.data!.snapshot.value}");

                      _singleton.serverURL =
                          snapshot.data!.snapshot.value.toString();
                    }

                    _singleton.notifyListenersSafe();
                    return homeScreen();
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
