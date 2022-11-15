import 'package:shared_preferences/shared_preferences.dart';

/*
Key first_login,username,password,name,cellphone










//實體化
  SharedPreferences prefs = await SharedPreferences.getInstance();
 //字串資料
  await prefs.setString(key, value);

//布林資料
  await prefs.setBool(key, value);

//浮點數資料
  await prefs.setDouble(key, value);

//整數資料
  await prefs.setInt(key, value);

//字串列表資料
  await prefs.setStringList(key, value);

  //字串資料
  prefs. getString(key);

//布林資料
  prefs.getBool(key);

//浮點數資料
  prefs.getDouble(key);

//整數資料
  prefs.getInt(key);

//字串列表資料
  prefs.getStringList(key);
 */

void save_int_data(String key,int value) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value);
}

void save_string_data(String key,String value) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

void save_bool_data(String key,var value) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

void save_Double_data(String key,var value) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(key, value);
}

Future<int?> get_int_data(String key) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

Future<String?> get_string_data(String key) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<bool?> get_bool_data(String key) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getBool(key) ?? true);
}

Future<double?> get_Double_data(String key) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getDouble(key);
}