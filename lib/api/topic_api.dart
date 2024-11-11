import 'dart:io';

import 'package:admin_flutter/common/http_util.dart';
import 'package:dio/dio.dart';

class TopicApi {

  static Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // 获取题目列表
  static Future<dynamic> topicList({
    String? page,
    String? pageSize,
    String? search,
    String? cate,
    String? majorId, required Map<String, String> params,
  }) async {
    try {
      Map<String, dynamic> params = {
        'page': page ?? '1', // 默认值为 '1'
        'pageSize': pageSize ?? '20', // 默认值为 '20'
        'search': search ?? '', // 默认值为空字符串
        'cate': cate ?? '', // 默认值为空字符串
        'major_id': majorId ?? '', // 默认值为空字符串
      };
      return await HttpUtil.get("/admin/topic/topic/list", params: params);
    } catch (e) {
      print('Error in topicList: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 创建题目
  static Future<dynamic> topicCreate(Map<String, dynamic> params) async {
    try {
      // 必传字段校验
      List<String> requiredFields = ['title', 'author', 'content', 'answer', 'cate', 'major_id'];
      for (var field in requiredFields) {
        if (!params.containsKey(field) || params[field] == null) {
          throw ArgumentError('Missing required field: $field');
        }
      }

      return await HttpUtil.post("/admin/topic/topic/create", params: params);
    } catch (e) {
      print('Error in topicCreate: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 查看题目详细
  static Future<dynamic> topicDetail(String id) async {
    try {
      return await HttpUtil.get("/admin/topic/topic/$id");
    } catch (e) {
      print('Error in topicDetail: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 更新题目
  static Future<dynamic> topicUpdate({
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
      return await HttpUtil.put("/admin/topic/topic/$id", params: params);
    } catch (e) {
      print('Error in topicUpdate: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 删除题目
  static Future<dynamic> topicDelete(String id) async {
    try {
      return await HttpUtil.delete("/admin/topic/topic/$id");
    } catch (e) {
      print('Error in topicDelete: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 导入题目
  static Future<dynamic> topicBatchImport(File file) async {
    try {
      Map<String, dynamic> params = {
        'file': file,
      };
      return await HttpUtil.post("/admin/topic/topic/batch-import", params: params);
    } catch (e) {
      print('Error in topicBatchImport: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 导出题目为 CSV
  static Future<dynamic> topicExport({
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
      return await HttpUtil.get("/admin/topic/topic/export", params: params);
    } catch (e) {
      print('Error in topicExport: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }
}