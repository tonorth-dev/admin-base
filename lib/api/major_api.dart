import 'package:admin_flutter/common/http_util.dart';
import 'dart:async';

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

      // 最多重试3次
      const maxRetries = 3;
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          // 发起请求
          final response = await HttpUtil.get("/admin/major/major/list", params: finalParams);
          return response;
        } catch (e) {
          if (attempt < maxRetries) {
            // 如果不是最后一次尝试，等待一段时间后重试
            await Future.delayed(Duration(seconds: 2));
            print('Attempt $attempt failed, retrying...');
          } else {
            // 最后一次尝试失败，抛出异常
            print('All attempts failed: $e');
            throw e;
          }
        }
      }
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
