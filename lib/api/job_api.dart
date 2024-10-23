import 'package:admin_flutter/common/http_util.dart';

class JobApi {

  static Future<dynamic> jobList({Map<String, dynamic>? params}) async {
    return await HttpUtil.get("/job/list", params: params);
  }

  static Future<dynamic> jobInsert({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/job/insert", params: params);
  }

  static Future<dynamic> jobDelete({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/job/delete", params: params);
  }

  static Future<dynamic> jobUpdate({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/job/update", params: params);
  }
}
