import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../login_page/first_view.dart';
import 'package:untitled/MQTT/mqtt_connect.dart';



class UsersettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
          child: const Text("登出"),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("first_login", true);
            Disconnected();
            Navigator.push(context, MaterialPageRoute(builder: (context) => first_view()));
          },
        )

    );
  }
}

