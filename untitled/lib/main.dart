import 'package:flutter/material.dart';

import 'login_page/first_view.dart';
import 'main_page/Slippage.dart';

import 'database/sql.dart';
import 'test.dart';

import 'database/shared_preferences.dart';

import 'GatewaySetting/bluetooth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  init_sql();

  runApp(
    const MaterialApp(
      home: first_view(),
      debugShowCheckedModeBanner: false, // 去除右上方Debug標誌
    ),
  );
}



