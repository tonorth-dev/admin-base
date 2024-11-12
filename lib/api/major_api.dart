import 'package:admin_flutter/common/http_util.dart';

class MajorApi {

  static Future<dynamic> majorList({Map<String, dynamic>? params}) async {
    try {
      // 设置默认参数
      final defaultParams = {
        'page': '1',
        'pageSize': '15',
        'search': '',
      };

      // 合并默认参数和传入的参数
      final finalParams = {...defaultParams, ...?params};

      return await HttpUtil.get("/admin/major/major/list", params: finalParams);
    } catch (e) {
      print('Error in majorList: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
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
