import 'package:admin_flutter/common/http_util.dart';

class TopicApi {

  // 获取题目列表
  static Future<dynamic> topicList({Map<String, dynamic>? params}) async {
    return await HttpUtil.get("/admin/topic/topic/list", params: params);
  }

  // 创建题目
  static Future<dynamic> topicCreate({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/admin/topic/topic/create", params: params);
  }

  // 查看题目详细
  static Future<dynamic> topicDetail({String? id}) async {
    return await HttpUtil.get("/admin/topic/topic/$id");
  }

  // 更新题目
  static Future<dynamic> topicUpdate({Map<String, dynamic>? params}) async {
    String id = params!['id'];
    params.remove('id');
    return await HttpUtil.put("/admin/topic/topic/$id", params: params);
  }

  // 删除题目
  static Future<dynamic> topicDelete({String? id}) async {
    return await HttpUtil.delete("/admin/topic/topic/$id");
  }

  // 导入题目
  static Future<dynamic> topicBatchImport({Map<String, dynamic>? params}) async {
    return await HttpUtil.post("/admin/topic/topic/batch-import", params: params);
  }

  // 导出题目为 CSV
  static Future<dynamic> topicExport({Map<String, dynamic>? params}) async {
    return await HttpUtil.get("/admin/topic/topic/export", params: params);
  }
}
