import 'package:admin_flutter/common/http_util.dart';

class ClassApi {

  static Future<dynamic> classList({Map<String, dynamic>? params}) async {
    return await HttpUtil.get("/class/list", params: params);
  }

  static Future<dynamic> classInsert({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/class/insert", params: params);
  }

  static Future<dynamic> classDelete({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/class/delete", params: params);
  }

  static Future<dynamic> classUpdate({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/class/update", params: params);
  }

  static Future<dynamic> classSearch({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/class/list", params: params);
  }
}
