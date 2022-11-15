//內建涵式庫
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';


//引入的涵式庫
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:wifi_iot/wifi_iot.dart';
//專案涵式庫
import 'package:untitled/MQTT/mqtt_connect.dart';
import 'package:untitled/MQTT/user_commend.dart';
import 'package:untitled/main_page/BottomNavigation.dart';
import 'package:untitled/database/GlobalVariable.dart' as globals;

List<String> ssid_list = <String>[];
List<String> ble_data_list = <String>[];
int ble_data_list_count = 0;
var ssid = "請選擇附近wifi名稱",pass = "密碼";
var serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
var characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

class DeviceControl extends StatefulWidget{
  final String? _macAddress;
  final String? _name;
  final Device _device;

  const DeviceControl(this._name, this._macAddress, this._device, {Key? key})
      : super(key: key);

  @override
  State<DeviceControl> createState() => _DeviceControlState([]);
}

class _DeviceControlState extends State<DeviceControl> {
  final List<_ServiceListItem> _serviceInfos;
  final TextEditingController _sendDataTextController = TextEditingController();
  late DeviceState _deviceState;
  final List<_LogItem> _logs = [];
  late int _mtu;
  late StreamSubscription<BleService> _serviceDiscoveryStream;
  late StreamSubscription<DeviceState> _stateStream;
  late StreamSubscription<DeviceSignalResult> _deviceSignalResultStream;

  bool timerStop = false;

  String asciiToHex(String asciiStr) {
    List<int> chars = asciiStr.codeUnits;
    StringBuffer hex = StringBuffer();
    for (int ch in chars) {
      hex.write(ch.toRadixString(16).padLeft(2, '0'));
    }
    return hex.toString();
  }
  //把原字串切成，每長度20的字串陣列
  void Stringtolist(String str){
    ble_data_list.clear();
    int length = str.length;
    int endIndex = length%20;
    if(length >= 20)
      {
        ble_data_list_count = length~/20;
      }
    else
      {
        ble_data_list_count = 0;
      }

    for(int i = 0;i <= ble_data_list_count;i++)
    {
      if(i == ble_data_list_count)
        {
          ble_data_list.add(str.substring(i*20,i*20+endIndex));
        }
      else
        {
          ble_data_list.add(str.substring(i*20,i*20+20));
        }

     }
    print("ble_data_list:");
    print(ble_data_list);
    print("count:");
    print(ble_data_list_count);
    print("length:");
    print(length);
    print("endIndex:");
    print(endIndex);
  }

  _DeviceControlState(this._serviceInfos);

  @override
  void dispose() {
    _serviceDiscoveryStream.cancel();
    _stateStream.cancel();
    _deviceSignalResultStream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();



    _deviceState = widget._device.state;

    timerStop = true;
    widget._device.disConnect();
    Timer.periodic(const Duration(seconds:2), (timer){

      if(timerStop)
        {
          timer.cancel();
        }
      if(globals.DeviceBind_message == "false")
        {
          _showBLEAlert(context,"不是認證裝置，請重新新增裝置");
          timer.cancel();
        }



        if(_deviceState != DeviceState.connected)
        {
          _showBLEAlert(context,"藍芽斷線，請重新新增裝置");
          timer.cancel();
        }
    });

    _mtu = widget._device.mtu;
    _serviceDiscoveryStream =
        widget._device.serviceDiscoveryStream.listen((event) {
          setState(() {
            _serviceInfos.add(_ServiceListItem(event, false));
          });
        });

    if (_deviceState == DeviceState.connected) {
      if (!widget._device.isWatchingRssi) widget._device.startWatchRssi();
      widget._device.discoveryService();
    }


    _stateStream = widget._device.stateStream.listen((event) {
      if (event == DeviceState.connected) {
        if (!widget._device.isWatchingRssi) widget._device.startWatchRssi();
        setState(() {
          _mtu = widget._device.mtu;
          _serviceInfos.clear();
        });
        widget._device.discoveryService();
      }
      setState(() {
        _deviceState = event;
      });
    });
    _deviceSignalResultStream =
        widget._device.deviceSignalResultStream.listen((event) {
          String? data;
          if (event.data != null && event.data!.isNotEmpty) {
            data = "0x";
            for (int i = 0; i < event.data!.length; i++) {
              String currentStr = event.data![i].toRadixString(16).toUpperCase();
              if (currentStr.length < 2) {
                currentStr = "0" + currentStr;
              }
              data = data! + currentStr;
            }
          }
          if (event.type == DeviceSignalType.characteristicsRead ||
              event.type == DeviceSignalType.unKnown) {
            setState(() {
              _logs.insert(
                  0,
                  _LogItem(
                      event.uuid,
                      (event.isSuccess
                          ? "read data success signal and data:"
                          : "read data failed signal and data:") +
                          (data ?? "none"),
                      DateTime.now().toString()));
            });
          } else if (event.type == DeviceSignalType.characteristicsWrite) {
            setState(() {
              _logs.insert(
                  0,
                  _LogItem(
                      event.uuid,
                      (event.isSuccess
                          ? "write data success signal and data:"
                          : "write data success signal and data:") +
                          (data ?? "none"),
                      DateTime.now().toString()));
            });
          } else if (event.type == DeviceSignalType.characteristicsNotify) {
            setState(() {
              _logs.insert(0,
                  _LogItem(event.uuid, data ?? "none", DateTime.now().toString()));
            });
          } else if (event.type == DeviceSignalType.descriptorRead) {
            setState(() {
              _logs.insert(
                  0,
                  _LogItem(
                      event.uuid,
                      (event.isSuccess
                          ? "read descriptor data success signal and data:"
                          : "read descriptor data failed signal and data:") +
                          (data ?? "none"),
                      DateTime.now().toString()));
            });
          }
        });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device control"),
        actions:[
          TextButton(
            child: Text(
                _deviceState == DeviceState.connected
                    ? "Disconnect"
                    : "connect",
                style: const TextStyle(color: Colors.white)),
            onPressed: () {
              if (_deviceState == DeviceState.connected) {
                print("666666666666666666666666666666666666666666:");
                print(get_json_DeviceBind(globals.mac_address, "未定義"));
                publish(get_json_DeviceBind(globals.mac_address, "未定義"));
                //publish(get_json_basic_information());
                timerStop = true;
                widget._device.disConnect();
                print("7777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777:");
                print(globals.DeviceBind_message);

              } else {
                widget._device.connect(connectTimeout: 10000);
              }
            },
          ),

        ]
    ),
      body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () async {
                  loadWifiList();

                  await EasyLoading.show(
                    status: '搜尋附近wifi...',
                    maskType: EasyLoadingMaskType.black,
                  );

                  Timer.periodic(const Duration(microseconds:1), (timer) {
                    if (ssid_list.isNotEmpty) {
                      _showWifiListAlert(context);
                      EasyLoading.dismiss();
                      timer.cancel();
                     }
                    }
                  );
              },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: ssid.toString(),
                    ),

                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '請輸入密碼',
                  ),
                  onChanged: (text) {
                    pass = text.toString();
                  },
                ),
              ),
              ElevatedButton(
                child: const Text('確認連接'),
                onPressed: () async {
                  await EasyLoading.show(
                    status: '驗證裝置...',
                    maskType: EasyLoadingMaskType.black,
                  );



                  var data = {'ssid': ssid.toString(), 'pass': pass.toString()};
                  String jsonString = jsonEncode(data);

                  print(jsonString);
                  Stringtolist(jsonString);
                  print(ble_data_list);

                  {
                    String dataStr =
                    asciiToHex(ble_data_list_count.toString());
                    Uint8List data = Uint8List(dataStr.length ~/ 2);

                    for (int i = 0;
                    i < dataStr.length ~/ 2;
                    i++) {
                      data[i] = int.parse(
                          dataStr.substring(
                              i * 2, i * 2 + 2),
                          radix: 16);
                    }
                    widget._device.writeData(
                        serviceUuid,
                        characteristicUuid,
                        true,
                        data);
                    _sendDataTextController.clear();
                    await Future.delayed(const Duration(milliseconds: 500));
                  }

                  for(int i = 0;i <= ble_data_list_count;i++)
                    {
                      String dataStr =
                      asciiToHex(ble_data_list[i]);
                      Uint8List data =
                      Uint8List(dataStr.length ~/ 2);

                      for (int i = 0;
                      i < dataStr.length ~/ 2;
                      i++) {
                        data[i] = int.parse(
                            dataStr.substring(
                                i * 2, i * 2 + 2),
                            radix: 16);

                      }
                      widget._device.writeData(
                          serviceUuid,
                          characteristicUuid,
                          true,
                          data);
                      _sendDataTextController.clear();
                      await Future.delayed(const Duration(milliseconds: 500));
                    }

                  timerStop = true;
                  widget._device.disConnect();

                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ExampleApp()));
                },
              ),

            ],
          )
      ,
      ),
    );
  }

  _showWifiListAlert(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: const Text("請選擇裝置要連上的Wifi名稱"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildListItem(context).map((Widget item)=> item).toList(),
          ),
        ),
        actions: <Widget>[
          BasicDialogAction(
            title: Text("取消"),
            onPressed: () {
              publish(get_json_DeviceBind(globals.mac_address, "未定義"));
              Navigator.of(context,rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  _showBLEAlert(BuildContext context,String str) {
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text(str),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text("確定"),
            onPressed: () {
              Navigator.of(context,rootNavigator: true).pop();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                    return const BottomNavigation();
                  }));
            },
          ),
        ],
      ),
    );
  }



List<Widget> _buildListItem(BuildContext context) {
  var userGroup = <Widget>[];

  for(int i = 0;i <= ssid_list.length-1;i++)
    {
      userGroup.add(Column(
        children: [
          Container(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.wifi),
                //Expanded(child: Text(title)),
                TextButton(onPressed:() {
                  setState(() {
                    ssid = ssid_list[i];
                  });
                  Navigator.of(context,rootNavigator: true).pop();
                },
                    child:Text(ssid_list[i].toString()))

           ],
          ),
      ),
        const Divider(height: 0.5),
         ],
        )
        );
      }
  return userGroup;
}



}
//"4fafc201-1fb5-459e-8fcc-c5c9c331914b",
//"beb5483e-36e1-4688-b7f5-ea07361b26a8"

Future<List<String>> loadWifiList() async {
  final wifis = await WiFiForIoTPlugin.loadWifiList();
  print("${wifis.map((e) => e.ssid).toList()}");

  ssid_list.clear();

  for(int i = 0;i <= wifis.map((e) => e.ssid).toList().length-1;i++)
    {
      ssid_list.add(wifis.map((e) => e.ssid).toList()[i].toString());
    }
  return ssid_list;
}

class _ServiceListItem {
  final BleService _serviceInfo;
  bool _isExpanded;

  _ServiceListItem(this._serviceInfo, this._isExpanded);
}

class _LogItem {
  final String _characteristic;
  final String _data;
  final String _dateTime;

  _LogItem(this._characteristic, this._data, this._dateTime);
}
/*
ListView(children: [
ExpansionPanelList(
expansionCallback: (int index, bool isExpanded) {
setState(() {
_serviceInfos[index]._isExpanded = !isExpanded;
});
},
children: _serviceInfos.map((service) {
String serviceTitle = "Unknow Service";

return ExpansionPanel(
headerBuilder: (context, isExpanded) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(serviceTitle,
style: const TextStyle(
fontSize: 16, fontWeight: FontWeight.bold)),
],
);
},
body: Column(
children: service._serviceInfo.characteristics
    .map((characteristic) {
String properties = "";
List<ElevatedButton> buttons = [];

if (characteristic.properties
    .contains(CharacteristicProperties.write) ||
characteristic.properties.contains(
CharacteristicProperties.writeNoResponse)) {
buttons.add(ElevatedButton(
child: const Text("Write"),
onPressed: () {
showDialog<void>(
context: context,
builder: (BuildContext dialogContext) {
return SimpleDialog(
title: const Text('Write'),
children: <Widget>[
TextField(
autofocus: true,
controller: _sendDataTextController,
decoration: const InputDecoration(
hintText:
"Enter hexadecimal,such as ",
),
),
TextButton(
child: const Text("Send"),
onPressed: () {
String dataStr =
"3233333733393932";
Uint8List data =
Uint8List(dataStr.length ~/ 2);

for (int i = 0;
i < dataStr.length ~/ 2;
i++) {
data[i] = int.parse(
dataStr.substring(
i * 2, i * 2 + 2),
radix: 16);

}
widget._device.writeData(
service._serviceInfo.serviceUuid,
characteristic.uuid,
true,
data);
_sendDataTextController.clear();
Navigator.pop(dialogContext);
},
)
],
);
},
);
},
));
}

return FittedBox(
fit: BoxFit.contain,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: buttons,
),
],
),
);
}).toList(),
),
isExpanded: service._isExpanded);
}).toList())
]),
);*/


