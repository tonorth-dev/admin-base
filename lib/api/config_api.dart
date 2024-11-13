import 'package:admin_flutter/common/http_util.dart';

class ConfigApi {

  static Future<dynamic> configList() async {
    try {
      return await HttpUtil.get("/admin/major/major/list");
    } catch (e) {
      print('Error in configList: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }
}
