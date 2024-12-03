import 'dart:io';

import 'package:admin_flutter/common/http_util.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class MajorApi {

  static Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // 获取题目列表
  static Future<dynamic> majorList({Map<String, dynamic>? params}) async {
    try {
      // 设置默认参数
      final defaultParams = {
        'page': '1',
        'pageSize': '15',
        'keyword': handleNullOrEmpty(''),
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

  static String handleNullOrEmpty(String? value) {
    if (value == null || value == 'null') {
      return '';
    }
    return value;
  }


  // 创建题目
  static Future<dynamic> majorCreate(Map<String, dynamic> params) async {
    try {
      // 必传字段校验
      List<String> requiredFields = ['first_level_category', 'second_level_category', 'major_name',];
      for (var field in requiredFields) {
        if (!params.containsKey(field) || params[field] == null) {
          throw ArgumentError('Missing required field: $field');
        }
      }

      return await HttpUtil.post("/admin/major/major", params: params);
    } catch (e) {
      print('Error in majorCreate: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 查看题目详细
  static Future<dynamic> majorDetail(String id) async {
    try {
      return await HttpUtil.get("/admin/major/major/$id");
    } catch (e) {
      print('Error in majorDetail: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 更新题目
  static Future<dynamic> majorUpdate(int id, Map<String, dynamic> params) async {
    try {
      // 必传字段校验
      List<String> requiredFields = ['first_level_category', 'second_level_category', 'major_name',];
      for (var field in requiredFields) {
        if (!params.containsKey(field) || params[field] == null) {
          throw ArgumentError('Missing required field: $field');
        }
      }

      return await HttpUtil.put("/admin/major/major/$id?invite=1", params: params);
    } catch (e) {
      print('Error in majorCreate: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 删除题目
  static Future<dynamic> majorDelete(String id) async {
    try {
      return await HttpUtil.delete("/admin/major/major/$id");
    } catch (e) {
      print('Error in majorDelete: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 导入题目
  // static Future<dynamic> majorBatchImport(File file) async {
  //   try {
  //     MultipartFile multipartFile = await MultipartFile.fromFile(
  //       file.path,
  //       filename: basename(file.path),
  //     );
  //
  //     Map<String, dynamic> params = {
  //       'file': multipartFile,
  //     };
  //
  //     return await HttpUtil.post("/admin/major/major/batch-import", params: params);
  //   } catch (e) {
  //     print('调用导入接口错误: $e');
  //     rethrow; // 重新抛出异常以便调用者处理
  //   }
  // }

  static Future<dynamic> majorBatchImport(File file) async {
    try {
      // 构造 MultipartFile 对象
      MultipartFile multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: basename(file.path), // 使用文件名
      );

      // 构造 FormData
      FormData formData = FormData.fromMap({
        'file': multipartFile, // 'file' 对应后端接收的字段名
      });

      // 调用上传接口
      Response response = await Dio().post(
        "http://127.0.0.1:8888/admin/major/major/batch-import",
        data: formData,
        options: Options(
          headers: {
            'User-Agent': 'Apifox/1.0.0 (https://apifox.com)',
          },
          contentType: 'multipart/form-data',
        ),
      );

      return response.data; // 返回接口响应
    } catch (e) {
      print('调用导入接口错误: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 导出题目为 CSV
  static Future<dynamic> majorExport({
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
      return await HttpUtil.get("/admin/major/major/export", params: params);
    } catch (e) {
      print('Error in majorExport: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  static Future<dynamic> auditMajor(int majorId, int status) async {
    try {
      return await  HttpUtil.put('/admin/major/major/$majorId/audit_ret/$status');
    } catch (e) {
      throw Exception('审核请求失败: $e');
    }
  }

}
