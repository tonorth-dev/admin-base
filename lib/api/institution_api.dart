import 'package:admin_flutter/common/http_util.dart';

class InstitutionApi {

  static Future<dynamic> institutionList({Map<String, dynamic>? params}) async {
    return await HttpUtil.get("/institution/list", params: params);
  }

  static Future<dynamic> institutionInsert({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/institution/insert", params: params);
  }

  static Future<dynamic> institutionDelete({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/institution/delete", params: params);
  }

  static Future<dynamic> institutionUpdate({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/institution/update", params: params);
  }

  static Future<dynamic> institutionSearch({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/institution/list", params: params);
  }
}
