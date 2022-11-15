import 'dart:async';

import 'package:flutter/material.dart';

class FutureBuilderDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _FutureBuilderDemoState();
  }
}

class _FutureBuilderDemoState extends State {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FutureBuilderDemo',
      home: Scaffold(
        appBar: AppBar(
          title: new Text('FutureBuilderDemo'),
        ),
        body: Center(
          child: FutureBuilder<String>(
            future: mockNetworkData(),
            initialData: '我是預設的數據',
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return new Text('erro');
              } else {
                return new Text(snapshot.data);
              }
            },
          ),
        ),
      ),
    );
  }

  Future<String> mockNetworkData() async {
    return Future.delayed(Duration(seconds: 11), () => '我是網路請求的數據');
  }
}