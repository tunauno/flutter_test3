//內建涵式庫
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
//引入的涵式庫
import 'package:flutter_blue_elves/flutter_blue_elves.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
//專案涵式庫
import 'device_control.dart';
import 'package:untitled/main_page/BottomNavigation.dart';
import 'package:untitled/database/GlobalVariable.dart' as globals;

class addgateway extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const addgatewayapp(),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class addgatewayapp extends StatefulWidget {
  const addgatewayapp({Key? key}) : super(key: key);
  @override
  State<addgatewayapp> createState() => _addgatewayState();
}

class _addgatewayState extends State<addgatewayapp> {
  List<AndroidBluetoothLack> _blueLack = [];
  IosBluetoothState _iosBlueState = IosBluetoothState.unKnown;
  List<ScanResult> _scanResultList = [];
  List<HideConnectedDevice> _hideConnectedList = [];
  final List<_ConnectedItem> _connectedList = [];
  bool _isScaning = false;
  bool _isEmpty = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 2000),
        Platform.isAndroid ? androidGetBlueLack : iosGetBlueState);
    device_search();
  }
  void iosGetBlueState(timer) {
    FlutterBlueElves.instance.iosCheckBluetoothState().then((value) {
      setState(() {
        _iosBlueState = value;
      });
    });
  }

  void androidGetBlueLack(timer) {
    FlutterBlueElves.instance.androidCheckBlueLackWhat().then((values) {
      setState(() {
        _blueLack = values;
      });
    });
  }

  void getHideConnectedDevice() {
    FlutterBlueElves.instance.getHideConnectedDevices().then((values) {
      setState(() {
        _hideConnectedList = values;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: const Text("新增裝置"),
            centerTitle: true,
            leading:IconButton(
              icon: const Icon(
                Icons.arrow_back,
              ),
              onPressed: () =>  Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                    return const BottomNavigation();
                  })),
            )
          ),

          body: ListView.separated(
            itemCount: (_connectedList.isNotEmpty ? _connectedList.length + 1 : 0) +
              (_hideConnectedList.isNotEmpty
                  ? _hideConnectedList.length + 1
                  : 0) +
              (_scanResultList.isNotEmpty ? _scanResultList.length + 1 : 0) + (_isEmpty ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if(_isEmpty)
              {

                if(index == 0)
                  {
                    return const Text("附近沒有在設定模式的裝置，請使裝置在設定模式。",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center);
                  }
                else
                  {
                    return null;
                  }

              }
              else
              {
                if (_connectedList.isNotEmpty && index <= _connectedList.length) {

                } else if (_hideConnectedList.isNotEmpty &&
                    index -
                        (_connectedList.isNotEmpty
                            ? _connectedList.length + 1
                            : 0) <=
                        _hideConnectedList.length) {
                } else {
                  int scanStartIndex =
                      (_connectedList.isNotEmpty ? _connectedList.length + 1 : 0) +
                          (_hideConnectedList.isNotEmpty
                              ? _hideConnectedList.length + 1
                              : 0);
                  if (index == scanStartIndex) {
                    return const Text("偵測到的設備：",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold));
                  } else {
                    ScanResult currentScan =
                    _scanResultList[index - scanStartIndex - 1];


                    return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(currentScan.name ?? "Unnamed device",
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 16)),

                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Device toConnectDevice = currentScan.connect(
                                            connectTimeout: 10000);
                                        setState(() {
                                          _connectedList.insert(
                                              0,
                                              _ConnectedItem(
                                                  toConnectDevice,
                                                  currentScan.macAddress,
                                                  currentScan.name));
                                          _scanResultList
                                              .removeAt(index - scanStartIndex - 1);
                                        });


                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return DeviceControl(
                                                  currentScan.name,
                                                  currentScan.macAddress,
                                                  toConnectDevice);
                                            },
                                          ),
                                        );
                                      },
                                      child: const Text("Connect")),
                                ],
                              ),
                            )
                          ],
                        ));
                  }
                }
              }
              return null;

            },
            separatorBuilder: (BuildContext context, int index) {
              if (_connectedList.isNotEmpty && index <= _connectedList.length) {
                if (index == 0 || index == _connectedList.length) {
                  return const Divider(color: Colors.white);
                } else {
                  return const Divider(color: Colors.grey);
                }
              } else if (_hideConnectedList.isNotEmpty &&
                  index -
                      (_connectedList.isNotEmpty
                          ? _connectedList.length + 1
                          : 0) <=
                      _hideConnectedList.length) {
                int hideStartIndex =
                _connectedList.isNotEmpty ? _connectedList.length + 1 : 0;
                if (index == hideStartIndex ||
                    index == hideStartIndex + _hideConnectedList.length) {
                  return const Divider(color: Colors.white);
                } else {
                  return const Divider(color: Colors.grey);
                }
              } else {
                int scanStartIndex =
                    (_connectedList.isNotEmpty ? _connectedList.length + 1 : 0) +
                        (_hideConnectedList.isNotEmpty
                            ? _hideConnectedList.length + 1
                            : 0);
                if (index == scanStartIndex ||
                    index == scanStartIndex + _scanResultList.length) {
                  return const Divider(color: Colors.white);
                } else {
                  return const Divider(color: Colors.grey);
                }
              }
            },

          ),


        floatingActionButton: FloatingActionButton(
          backgroundColor: _isScaning ? Colors.red : Colors.blue,

          onPressed: () {
            device_search();
          },
          tooltip: 'scan',
          child: Icon(_isScaning ? Icons.stop : Icons.find_replace),
        ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void device_search() async{
    getHideConnectedDevice();
    if ((Platform.isAndroid && _blueLack.isEmpty) ||
        (Platform.isIOS &&
            _iosBlueState == IosBluetoothState.poweredOn)) {
      if (_isScaning) {
        FlutterBlueElves.instance.stopScan();
      } else {
        _scanResultList = [];
        setState(() {
          _isScaning = true;
        });

        FlutterBlueElves.instance.startScan(5000).listen((event) {
          setState(() {
            if (event.localName != null) {
              var localName = event.localName.toString();
              var ln = localName.split("-");
              if(ln[0] == "DAE")
              {
                _scanResultList.insert(0, event);
                globals.mac_address = ln[1];
              }

            }
          });
        }).onDone(() {
          setState(() {
            if(_scanResultList.isEmpty)
            {
              _isEmpty = true;
            }
            else
            {
              _isEmpty = false;
            }


            _isScaning = false;
            _timer?.cancel();
            EasyLoading.dismiss();
          });
        });

        _timer?.cancel();
        await EasyLoading.show(
          status: '搜尋附近裝置...',
          maskType: EasyLoadingMaskType.black,
        );



        //EasyLoading.show(status: '搜尋附近裝置...');
/*
        _progress = 0;
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(milliseconds: 100),
                (Timer timer) {
              EasyLoading.showProgress(_progress,
                  status: '${(_progress * 100).toStringAsFixed(0)}%');

              _progress += 0.02;

              if (_progress >= 1) {
                _timer?.cancel();
                EasyLoading.dismiss();
              }
            });*/

      }
    }
  }

}



class _ConnectedItem {
  final Device _device;
  final String? _macAddress;
  final String? _name;

  _ConnectedItem(this._device, this._macAddress, this._name);
}