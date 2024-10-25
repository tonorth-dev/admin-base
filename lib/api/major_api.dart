import 'package:admin_flutter/common/http_util.dart';

class MajorApi {

  static Future<dynamic> majorList({Map<String, dynamic>? params}) async {
    return await HttpUtil.get("/major/list", params: params);
  }

  static Future<dynamic> majorInsert({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/major/insert", params: params);
  }

  static Future<dynamic> majorDelete({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/major/delete", params: params);
  }

  static Future<dynamic> majorUpdate({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/major/update", params: params);
  }

  static Future<dynamic> majorSearch({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/major/list", params: params);
  }
}
