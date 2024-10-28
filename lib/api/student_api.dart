import 'package:admin_flutter/common/http_util.dart';

class StudentApi {

  static Future<dynamic> studentList({Map<String, dynamic>? params}) async {
    return await HttpUtil.get("/student/list", params: params);
  }

  static Future<dynamic> studentInsert({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/student/insert", params: params);
  }

  static Future<dynamic> studentDelete({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/student/delete", params: params);
  }

  static Future<dynamic> studentUpdate({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/student/update", params: params);
  }

  static Future<dynamic> studentSearch({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/student/list", params: params);
  }
}
