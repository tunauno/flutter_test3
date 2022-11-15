import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:untitled/main_page/BottomNavigation.dart';
import 'package:untitled/MQTT/mqtt_connect.dart';

import 'package:shared_preferences/shared_preferences.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

//確認帳號密碼是否正確
postData(String username,String password,BuildContext context) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();

  var response = await http.post(
      Uri.parse("https://yun.dae.tw/api/mqtt1.0/?a=Login&b=Process"),
      body: {"Username":username,"Password":password});
  var res = json.decode(response.body);

  if(res["Result"] == true)
  {
    Fluttertoast.showToast(
        msg: "登入成功",  // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.BOTTOM,    // location
        timeInSecForIosWeb: 2               // duration
    );

    connect(username,password);
    prefs.setBool("first_login",false);
    prefs.setString("username", username);
    prefs.setString("password", password);
    Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavigation()));

  }
  else
  {
    Fluttertoast.showToast(
        msg: "帳號密碼輸入錯誤，請重新輸入",  // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.BOTTOM,    // location
        timeInSecForIosWeb: 2               // duration
    );
  }

  print(response.body);
}

class _LoginPageState extends State {
  //焦點
  FocusNode _focusNodeUserName = new FocusNode();
  FocusNode _focusNodePassWord = new FocusNode();
  //使用者名稱輸入框控制器，此控制器可以監聽使用者名稱輸入框操作
  TextEditingController _userNameController = new TextEditingController();
  //表單狀態
  final _formKey = GlobalKey<FormState>();
  var _password = '';//使用者名稱
  var _username = '';//密碼
  var _isShowPwd = false;//是否顯示密碼
  var _isShowClear = false;//是否顯示輸入框尾部的清除按鈕
  @override
  void initState() {
    // TODO: implement initState
    //設定焦點監聽
    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);

    //監聽使用者名稱框的輸入改變
    _userNameController.addListener((){
      print(_userNameController.text);
      // 監聽文字框輸入變化，當有內容的時候，顯示尾部清除按鈕，否則不顯示
      if (_userNameController.text.length > 0) {
        _isShowClear = true;
      }else{
        _isShowClear = false;
      }
      setState(() {

      });
    });
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    // 移除焦點監聽
    _focusNodeUserName.removeListener(_focusNodeListener);
    _focusNodePassWord.removeListener(_focusNodeListener);
    _userNameController.dispose();
    super.dispose();
  }
  // 監聽焦點
  Future _focusNodeListener() async{
    if(_focusNodeUserName.hasFocus){
      print("使用者名稱框獲取焦點");
      // 取消密碼框的焦點狀態
      _focusNodePassWord.unfocus();
    }
    if (_focusNodePassWord.hasFocus) {
      print("密碼框獲取焦點");
      // 取消使用者名稱框焦點狀態
      _focusNodeUserName.unfocus();
    }
  }
  /**
   * 驗證使用者名稱
   */
  String? validateUserName(value){
    if (value.isEmpty) {
      return '使用者名稱不能為空!';
    }
    return null;
  }
  /**
   * 驗證密碼
   */
  String? validatePassWord(value){
    if (value.isEmpty) {
      return '密碼不能為空';
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width:750,height:1334)..init(context);
    print(ScreenUtil().scaleHeight);
    // logo 圖片區域
    Widget logoImageArea = Container(
      alignment: Alignment.topCenter,
      // 設定圖片為圓形
      child: ClipOval(
        child: Image.asset(
          "assets/images/icon.png",
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );

    //輸入文字框區域
    Widget inputTextArea = Container(
      margin: const EdgeInsets.only(left: 20,right: 20),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.white
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _userNameController,
              focusNode: _focusNodeUserName,
              //設定鍵盤型別,
              decoration: InputDecoration(
                labelText: "使用者名稱",
                hintText: "請輸入電子郵件信箱",
                prefixIcon: Icon(Icons.person),
                //尾部新增清除按鈕
                suffixIcon:(_isShowClear)
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: (){
                    // 清空輸入框內容
                    _userNameController.clear();
                  },
                )
                    : null ,
              ),
              //驗證使用者名稱
          validator: validateUserName,
              //儲存資料
              onSaved: (String? value){
                _username = value!;
              },
            ),
            TextFormField(
              focusNode: _focusNodePassWord,
              decoration: InputDecoration(
                  labelText: "密碼",
                  hintText: "請輸入密碼",
                  prefixIcon: Icon(Icons.lock),
                  // 是否顯示密碼
                  suffixIcon: IconButton(
                    icon: Icon((_isShowPwd) ? Icons.visibility : Icons.visibility_off),
                    // 點選改變顯示或隱藏密碼
                    onPressed: (){
                      setState(() {
                        _isShowPwd = !_isShowPwd;
                      });
                    },
                  )
              ),
              obscureText: !_isShowPwd,
              //密碼驗證
              validator:validatePassWord,
              //儲存資料
              onSaved: (String? value){
                _password = value!;
              },
            )
          ],
        ),
      ),
    );
    // 登入按鈕區域
    Widget loginButtonArea = Container(
      margin: EdgeInsets.only(left: 20,right: 20),
      height: 45.0,
      child: ElevatedButton(
        child: Text("登入"),
        onPressed: (){
          //點選登入按鈕，解除焦點，回收鍵盤
          _focusNodePassWord.unfocus();
          _focusNodeUserName.unfocus();
          if (_formKey.currentState!.validate()) {
            //只有輸入通過驗證，才會執行這裡
            _formKey.currentState!.save();
            //todo 登入操作
            postData(_username,_password,context);
            print("使用者名稱:$_username ; 密碼: $_password");
          }
        },
      ),
    );

    //忘記密碼  立即註冊
    Widget bottomArea = Container(
      margin: EdgeInsets.only(right: 20,left: 30),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: Text(
              "忘記密碼?",
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.0,
              ),
            ),
            //忘記密碼按鈕，點選執行事件
            onPressed: (){

            },
          ),
          TextButton(
            child: Text(
              "快速註冊",
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 16.0,
              ),
            ),
            //點選快速註冊、執行事件
            onPressed: (){
            },
          )
        ],
      ),
    );
    return WillPopScope(
        onWillPop: () async {

      return null!;
    },child: Scaffold(
      backgroundColor: Colors.white,
      // 外層新增一個手勢，用於點選空白部分，回收鍵盤
      body: GestureDetector(
        onTap: (){
          // 點選空白區域，回收鍵盤
          print("點選了空白區域");
          _focusNodePassWord.unfocus();
          _focusNodeUserName.unfocus();
        },
        child: ListView(
          children: [
            SizedBox(height: ScreenUtil().setHeight(80),),
            logoImageArea,
            SizedBox(height: ScreenUtil().setHeight(70),),
            inputTextArea,
            SizedBox(height: ScreenUtil().setHeight(80),),
            loginButtonArea,
            SizedBox(height: ScreenUtil().setHeight(60),),
            bottomArea,
          ],
        ),
      ),
    )
    );
  }
}