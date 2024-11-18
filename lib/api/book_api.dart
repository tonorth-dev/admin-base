import 'dart:io';

import 'package:admin_flutter/common/http_util.dart';
import 'package:dio/dio.dart';

class BookApi {

  static Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // 获取题目列表
  static Future<dynamic> bookList(Map<String, String?> params) async {
    try {
      // 构建最终参数，并确保 null 值替换为 ''
      final Map<String, String> finalParams = {
        'page': params['page'] ?? '1', // 默认值为 '1'
        'pageSize': params['size'] ?? '15', // 重命名并设置默认值
        'keyword': handleNullOrEmpty(params['keyword']),
        'level': handleNullOrEmpty(params['level']),
        'major_id': handleNullOrEmpty(params['major_id']),
      };

      return await HttpUtil.get("/admin/book/book/list", params: finalParams);
    } catch (e) {
      print('Error in bookList: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  static String handleNullOrEmpty(String? value) {
    if (value == null || value == 'null') {
      return '';
    }
    return value;
  }


  // 创建题目
  static Future<dynamic> bookCreate(Map<String, dynamic> params) async {
    try {
      // 必传字段校验
      List<String> requiredFields = ['title', 'author', 'content', 'answer', 'cate', 'major_id'];
      for (var field in requiredFields) {
        if (!params.containsKey(field) || params[field] == null) {
          throw ArgumentError('Missing required field: $field');
        }
      }

      return await HttpUtil.post("/admin/book/book/create", params: params);
    } catch (e) {
      print('Error in bookCreate: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 查看题目详细
  static Future<dynamic> bookDetail(String id) async {
    try {
      return await HttpUtil.get("/admin/book/book/$id");
    } catch (e) {
      print('Error in bookDetail: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 更新题目
  static Future<dynamic> bookUpdate({
    required String id,
    required String title,
    required String content,
    required String category,
    required int difficulty,
    required List<String> options,
    required String answer,
  }) async {
    try {
      Map<String, dynamic> params = {
        'title': title,
        'content': content,
        'category': category,
        'difficulty': difficulty,
        'options': options,
        'answer': answer,
      };
      return await HttpUtil.put("/admin/book/book/$id", params: params);
    } catch (e) {
      print('Error in bookUpdate: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 删除题目
  static Future<dynamic> bookDelete(String id) async {
    try {
      return await HttpUtil.delete("/admin/book/book/$id");
    } catch (e) {
      print('Error in bookDelete: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 导入题目
  static Future<dynamic> bookBatchImport(File file) async {
    try {
      Map<String, dynamic> params = {
        'file': file,
      };
      return await HttpUtil.post("/admin/book/book/batch-import", params: params);
    } catch (e) {
      print('Error in bookBatchImport: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 导出题目为 CSV
  static Future<dynamic> bookExport({
    required String page,
    required String pageSize,
    required String search,
    required String cate,
    required String major_id,
  }) async {
    try {
      Map<String, dynamic> params = {
        'page': page,
        'pageSize': pageSize,
        'search': search,
        'cate': cate,
        'major_id': major_id,
      };
      return await HttpUtil.get("/admin/book/book/export", params: params);
    } catch (e) {
      print('Error in bookExport: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }
}
