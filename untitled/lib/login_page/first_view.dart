//內建涵式庫
import 'package:flutter/material.dart';
//引入的涵式庫
import 'package:shared_preferences/shared_preferences.dart';
//專案涵式庫
import 'package:untitled/main_page/BottomNavigation.dart';
import 'package:untitled/login_page/login.dart';
import 'package:untitled/MQTT/mqtt_connect.dart';
import 'package:untitled/MQTT/user_commend.dart';
import 'package:untitled/database/GlobalVariable.dart' as globals;

class first_view extends StatefulWidget {
  const first_view({super.key});

  @override
  _first_viewState createState() => _first_viewState();

}

class _first_viewState extends State {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.delayed(Duration(seconds: 1));

    if(prefs.getBool("first_login") ?? true)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context)  => login()));
      }
    else
      {
        connect(prefs.getString("username").toString(),prefs.getString("password").toString());
        Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
      }

  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Center(child:Image.asset('assets/images/DAE.png',fit:BoxFit.cover)),

    );
  }
}
