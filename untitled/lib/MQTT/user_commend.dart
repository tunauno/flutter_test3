import 'dart:core';
import 'dart:math';

Random random = new Random();

get_json_change_pass(var pass){
  return "${"${"{\n" +
      "   \"product\": \"USER\",\n" +
      "   \"command\": \"ChangePassword\",\n" +
      "   \"password\": \""+pass}\",\n   \"id\": \""+random.nextInt(10000000).toString()}\"\n}";

  var resBody = {};
  resBody["\"product\""] = "\"USER\"";
  resBody["\"command\""] = "\"GetInformation\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";
  return Map<String, dynamic>.from(resBody).toString();
}
get_json_basic_information(){
  var resBody = {};
  resBody["\"product\""] = "\"USER\"";
  resBody["\"command\""] = "\"GetInformation\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";
  return Map<String, dynamic>.from(resBody).toString();
}
get_json_change_basic_information(String name,String cellphone){
  return "${"${"{\n" +
      "   \"product\": \"USER\",\n" +
      "   \"command\": \"UpdateInformation\",\n" +
      "   \"values\": {\n" +
      "      \"name\": \""+name+"\",\n" +
      "      \"cellphone\": \""+cellphone}\"\n   },\n   \"id\": \""+random.nextInt(10000000).toString()}\"\n}";

  var resBody = {};
  resBody["\"product\""] = "\"USER\"";
  resBody["\"command\""] = "\"GetInformation\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";
  return Map<String, dynamic>.from(resBody).toString();
}
get_json_share_device(String username,String devices ){//測試
  return "${"${"{\n" +
      "   \"product\": \"USER\",\n" +
      "   \"command\": \"Share\",\n" +
      "   \"username\": \""+username+"\",\n" +
      "   \"devices\": ["+devices}],\n   \"id\": \"Share${random.nextInt(10000000)}"}\"\n}";

  var resBody = {};
  resBody["\"product\""] = "\"USER\"";
  resBody["\"command\""] = "\"GetInformation\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";
  return Map<String, dynamic>.from(resBody).toString();
}
get_json_DeviceBind(String macAddress,String name){
  /*List<int> payloadInt = {} as List<int>;

  for (final item in paload.codeUnits) {
    print(item.toRadixString(16));
    payloadInt.add(item.toRadixString(16) as int);
  }*/
  var str = "";
  int i = 0;
  for (final item in name.codeUnits) {

    print(item.toRadixString(10));
    print(item.toRadixString(16).runtimeType);
    if(int.parse(item.toRadixString(10)) >= 255)
      {
        str += String.fromCharCode(92);
        str += String.fromCharCode(117);
        str += item.toRadixString(16);
      }
    else
      {
        str += name[i].toString();
      }
    i++;
  }
  print(str);

  var resBody = {};
  resBody["\"product\""] = "\"USER\"";
  resBody["\"command\""] = "\"DeviceBind\"";
  resBody["\"mac\""] = "\"$macAddress\"";
  resBody["\"name\""] = "\"$str\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";
  return Map<String, dynamic>.from(resBody).toString();
}
get_json_DeviceUnbind(var macAddress){
  return "${"${"{\n" +
      "   \"product\": \"USER\",\n" +
      "   \"command\": \"DeviceUnbind\",\n" +
      "   \"mac\": \""+macAddress}\",\n   \"id\": \"DeviceUnbind"+random.nextInt(10000000).toString()}\"\n}";

  var resBody = {};
  resBody["\"product\""] = "\"USER\"";
  resBody["\"command\""] = "\"GetInformation\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";
  return Map<String, dynamic>.from(resBody).toString();
}
get_json_UpdateDevice(var macAddress,var name){
  return "${"${"{\n" +
      "   \"product\": \"USER\",\n" +
      "   \"command\": \"UpdateDevice\",\n" +
      "   \"name\": \""+name+"\",\n" +
      "   \"mac\": \""+macAddress}\",\n   \"id\": \"send"+random.nextInt(10000000).toString()}\"\n}";

  var resBody = {};
  resBody["\"product\""] = "\"USER\"";
  resBody["\"command\""] = "\"GetInformation\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";
  return Map<String, dynamic>.from(resBody).toString();
}
get_json_DeviceSearch(){
  var resBody = {};
  resBody["\"product\""] = "\"USER\"";
  resBody["\"command\""] = "\"DeviceSearch\"";
  resBody["\"ver\""] = "1";
  resBody["\"mac\""] = "\"\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";
  return Map<String, dynamic>.from(resBody).toString();
}
get_json_ToDevice(var macAddress,var values) {
  var resBody = {};
  resBody["\"product\""] = "\"ESP\"";
  resBody["\"command\""] = "\"ToDevice\"";
  resBody["\"mac\""] = "\"$macAddress\"";
  resBody["\"id\""] = "\"${random.nextInt(10000000)}\"";
  return Map<String, dynamic>.from(resBody).toString();
}