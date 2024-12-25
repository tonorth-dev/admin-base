import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LoginData {
  String token = "";
  String themeName = "";
  String role = "";
  String user = "";


  // toJson
  String toJson() {
    return jsonEncode({
      "token": token,
      "themeName": themeName,
    });
  }

  // fromJson
  static LoginData fromJson(Map<String, dynamic> map) {
    var data = LoginData();
    data.token = map["token"] ?? "";
    data.themeName = map["themeName"] ?? "";
    return data;
  }

  static String saveKey = "app_data";

  static Future<LoginData> read() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(saveKey);
    if (data == null) {
      return LoginData();
    }
    return LoginData.fromJson(jsonDecode(data));
  }

  // 保存数据
  Future<void> save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(saveKey, toJson());
  }

  /// 更简单的数据保存
  static Future<void> easySave(Function(LoginData) dg) async {
    var data = await read();
    dg(data);
    await data.save();
  }
}
