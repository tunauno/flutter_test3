import 'package:flutter/material.dart';

import 'view_page.dart';
import 'user_setting_page.dart';
import 'gateway_page.dart';

import 'package:untitled/GatewaySetting/addgateway.dart';

String title_all = "抄表顯示";

void handleClick(int item,BuildContext context){
  switch (item) {
    case 0:
      Navigator.push(context, MaterialPageRoute(builder: (context) => addgateway()));
      break;
    case 1:

      break;
  }
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomNavigationWidget(),
      debugShowCheckedModeBanner: false
    );
  }
}

class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({super.key});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigation();
}

class _BottomNavigation extends State<BottomNavigationWidget> {
  int _selectedIndex = 0;

  final pages = [ViewPage(), GatewayPage(), UsersettingPage()];

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      '抄表顯示',
      style: optionStyle,
    ),
    Text(
      '閘道器設定',
      style: optionStyle,
    ),
    Text(
      '使用者',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch(index){
        case 0:
          title_all = "抄錶顯示";

          break;
        case 1:
          title_all = "閘道器設定";
          break;
        case 2:
          title_all = "使用者設定";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {

          return null!;
        },
      child : Scaffold(
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
      ]
      ),
      body: Center(
        child:pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.ad_units),
            label: '抄錶顯示',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '閘道器設定',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '使用者設定',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    )
    );
  }
// _widgetOptions.elementAt(_selectedIndex)
  void _onItemClick(int index,BuildContext context) {
    setState(() {
      _selectedIndex = index;
      Navigator.of(context).pop();
    });
  }
}