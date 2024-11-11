import 'dart:io';

import 'package:admin_flutter/common/http_util.dart';

class TopicApi {

  // 获取题目列表
  static Future<dynamic> topicList({
    String? page,
    String? pageSize,
    String? search,
    String? cate,
    String? majorId, required Map<String, String> params,
  }) async {
    Map<String, dynamic> params = {
      'page': page ?? '1', // 默认值为 '1'
      'pageSize': pageSize ?? '20', // 默认值为 '20'
      'search': search ?? '', // 默认值为空字符串
      'cate': cate ?? '', // 默认值为空字符串
      'major_id': majorId ?? '', // 默认值为空字符串
    };

    return await HttpUtil.get("/admin/topic/topic/list", params: params);
  }

  // 创建题目
  static Future<dynamic> topicCreate(Map<String, dynamic> params) async {
    // 必传字段校验
    List<String> requiredFields = ['title', 'author', 'content', 'answer', 'cate', 'major_id'];
    for (var field in requiredFields) {
      if (!params.containsKey(field) || params[field] == null) {
        throw ArgumentError('Missing required field: $field');
      }
    }

    return await HttpUtil.post("/admin/topic/topic/create", params: params);
  }

  // 查看题目详细
  static Future<dynamic> topicDetail(String id) async {
    return await HttpUtil.get("/admin/topic/topic/$id");
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
    Map<String, dynamic> params = {
      'title': title,
      'content': content,
      'category': category,
      'difficulty': difficulty,
      'options': options,
      'answer': answer,
    };
    return await HttpUtil.put("/admin/topic/topic/$id", params: params);
  }

  // 删除题目
  static Future<dynamic> topicDelete(String id) async {
    return await HttpUtil.delete("/admin/topic/topic/$id");
  }

  // 导入题目
  static Future<dynamic> topicBatchImport(File file) async {
    Map<String, dynamic> params = {
      'file': file,
    };
    return await HttpUtil.post("/admin/topic/topic/batch-import", params: params);
  }

  // 导出题目为 CSV
  static Future<dynamic> topicExport({
    required String page,
    required String pageSize,
    required String search,
    required String cate,
    required String major_id,
  }) async {
    Map<String, dynamic> params = {
      'page': page,
      'pageSize': pageSize,
      'search': search,
      'cate': cate,
      'major_id': major_id,
    };
    return await HttpUtil.get("/admin/topic/topic/export", params: params);
  }
}
