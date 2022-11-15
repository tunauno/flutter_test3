//內建涵式庫
import 'dart:collection';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
//引入的涵式庫
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
//專案涵式庫
import 'package:untitled/MQTT/user_commend.dart';
import 'package:untitled/database/GlobalVariable.dart' as globals;

Random random = new Random();

//ssl://yun.dae.tw:8883
const url = 'yun.dae.tw';
const port = 1883;
String Username = "";
var clientID = 'clientID${random.nextInt(100000000).toString()}';

final client = MqttServerClient(url, clientID);

Future<MqttServerClient> connect(String username,String password) async {
  client.port = port;
  client.setProtocolV311();
  client.logging(on: true);

  Username = username;

  await client.connect(username, password);
  if (client.connectionStatus.state == MqttConnectionState.connected) {
    print('client connected');
  } else {
    print(
        'client connection failed - disconnecting, state is ${client.connectionStatus.state}');
    client.disconnect();
  }

  //訂閱主題
  client.subscribe("DAE/$username/read", MqttQos.atLeastOnce);

  client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final message = c[0].payload as MqttPublishMessage;
    //final MqttPublishMessage message = c[0].payload;
    final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

    print('${c[0].topic}:$payload');

    ///以下解析回傳訊息
    var res = json.decode(payload);
    var resMap = HashMap.from(res as Map);

    if(res["command"] == "GetInformation")
    {
      await prefs.setString("name",res["values"]["name"]);
      await prefs.setString("cellphone",res["values"]["cellphone"]);
    }
    if(res["command"] == "DeviceBind")
    {
      globals.DeviceBind_message = res["result"].toString();
      print("globals.DeviceBind_message");
      print(globals.DeviceBind_message);
    }
    if(res["command"] == "DeviceSearch")
    {
      var value = resMap["values"];
      print(value[0]["MAC"]);
      print(value[0]["Name"]);
      print(value[1]["MAC"]);
      print(value[1]["Name"]);
    }
    ///
  });

  var resBody = {};
  resBody["\"product\""] = "\"USER\"";
  resBody["\"command\""] = "\"DeviceBind\"";
  resBody["\"mac\""] = "\"94:3C:C6:10:0A:EC\"";
  resBody["\"name\""] = "\"未定義\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";

  var data = Map<String, dynamic>.from(resBody).toString();
  var data2 = "{\"product\": \"USER\",\"command\": \"DeviceBind\",\"mac\": \"94:3C:C6:10:0A:EC\",\"name\": \"abc\",\"id\": \"0.61586dd1cad6e\"}";
  var data3 = "{\"product\": \"USER\", \"command\": \"DeviceBind\", \"mac\": \"94:3C:C6:10:0A:EC\", \"name\": \"\u623f\", \"id\": \"6564646\"}";
  //publish(get_json_basic_information());
  print(data);
  print(data.runtimeType);

  publish(get_json_DeviceSearch());
  //publish(data2);
/*
  List<int> payloadInt = {} as List<int>;

  for (final item in paload.codeUnits) {
    print(item.toRadixString(16));
    payloadInt.add(item.toRadixString(16) as int);
  }*/

  publish(get_json_DeviceBind("94:3C:C6:10:0A:EC", "房間你好棒abc"));
  print(get_json_DeviceSearch());
  print("66${data}66");

print(get_json_basic_information());
  return client;
}

void publish(String paload){
  final builder = MqttClientPayloadBuilder();
  builder.addString(paload);
  print("publish:");
  print(builder.payload);
  print((builder.payload).runtimeType);

  client.publishMessage("DAE/$Username/write", MqttQos.atLeastOnce, builder.payload);
}

// The unsolicited disconnect callback
void Disconnected() {
  client.disconnect();
  print('client disconnect!!!');
}

