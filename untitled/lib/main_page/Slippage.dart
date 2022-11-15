import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'view_page.dart';
import 'user_setting_page.dart';
import 'gateway_page.dart';
import 'package:untitled/GatewaySetting/addgateway.dart';

String title_all = "抄表顯示";
String email = "";
String name = "";

final ImagePicker _picker = ImagePicker();
XFile? image;

class Slippage extends StatefulWidget {
  @override
  _SlippageState createState() => _SlippageState();
}

void handleClick(int item,BuildContext context){
  switch (item) {
    case 0:
      Navigator.push(context, MaterialPageRoute(builder: (context) => addgateway()));
      break;
    case 1:

      break;
  }
}

class _SlippageState extends State<Slippage> {
  //目前選擇頁索引值
  int _currentIndex = 0; //預設值

  final pages = [ViewPage(), GatewayPage(), UsersettingPage()];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    email = prefs.getString("username") ?? "---";
    name = prefs.getString("name") ?? "---";

    Future.delayed(Duration(seconds: 1));

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {

          return null!;
        },
    child: Scaffold(
      appBar: AppBar(
        title: Text(title_all),
          actions: <Widget>[
            PopupMenuButton<int>(
              icon: const Icon(Icons.add),
              onSelected: (item) => handleClick(item,context),
              itemBuilder: (context) => [
                const PopupMenuItem<int>(value: 0, child: Text('新增設備')),
                const PopupMenuItem<int>(value: 1, child: Text('掃QR code')),
              ],
            ),

    ],
    ),

      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            //設定用户名稱
            UserAccountsDrawerHeader(
              accountName: Text(
                name,
              ),
              //設定Email
              accountEmail: Text(
                email,
              ),
              //設定大頭照
              currentAccountPicture: CircleAvatar(
                backgroundImage: new AssetImage("assets/images/icon.png"),
                child: InkWell(
                  onTap: () async {
                    Fluttertoast.showToast(
                        msg: "按到照片",  // message
                        toastLength: Toast.LENGTH_SHORT, // length
                        gravity: ToastGravity.BOTTOM,    // location
                        timeInSecForIosWeb: 2               // duration
                    );
                  },
                ),
              ),
            ),
            //選單
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.ad_units)),
              title: const Text('抄表顯示'),
              onTap: () {
                title_all = "抄表顯示";
                _onItemClick(0,context);
              },
            ),
            ListTile(
              leading: new CircleAvatar(child: Icon(Icons.settings)),
              title: const Text('閘道器'),
              onTap: () {
                title_all = "閘道器";
                _onItemClick(1,context);
              },
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.account_circle)),
              title: const Text('使用者設定'),
              onTap: () {
                title_all = "使用者設定";
                _onItemClick(2,context);
              },
            ),
          ],
        ),
      ),
      body: pages[_currentIndex],

    )
    );
  }


  void _onItemClick(int index,BuildContext context) {
    setState(() {
      _currentIndex = index;
      Navigator.of(context).pop();
    });
  }
}
