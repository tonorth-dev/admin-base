import 'dart:io';

import 'package:admin_flutter/common/http_util.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';

class StudentApi {

  static Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // 获取题目列表
  static Future<dynamic> studentList({Map<String, dynamic>? params}) async {
    try {
      // 设置默认参数
      final defaultParams = {
        'page': '1',
        'pageSize': '15',
        'keyword': handleNullOrEmpty(''),
        'institution_id': handleNullOrEmpty(''),
        'major_id': handleNullOrEmpty(''),
      };

      // 合并默认参数和传入的参数
      final finalParams = {...defaultParams, ...?params};

      // 最多重试3次
      const maxRetries = 3;
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          // 发起请求
          final response = await HttpUtil.get("/admin/student/student/list", params: finalParams);
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
      print('Error in studentList: $e');
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
  static Future<dynamic> studentCreate(Map<String, dynamic> params) async {
    try {
      // 必传字段校验
      List<String> requiredFields = ['name', 'city', 'leader'];
      for (var field in requiredFields) {
        if (!params.containsKey(field) || params[field] == null) {
          throw ArgumentError('Missing required field: $field');
        }
      }

      return await HttpUtil.post("/admin/student/student", params: params);
    } catch (e) {
      print('Error in studentCreate: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 查看题目详细
  static Future<dynamic> studentDetail(String id) async {
    try {
      return await HttpUtil.get("/admin/student/student/$id");
    } catch (e) {
      print('Error in studentDetail: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 更新题目
  static Future<dynamic> studentUpdate(int id, Map<String, dynamic> params) async {
    try {
      // 必传字段校验
      List<String> requiredFields = ['name', 'city', 'leader'];
      for (var field in requiredFields) {
        if (!params.containsKey(field) || params[field] == null) {
          throw ArgumentError('Missing required field: $field');
        }
      }

      return await HttpUtil.put("/admin/student/student/$id", params: params);
    } catch (e) {
      print('Error in studentCreate: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 删除题目
  static Future<dynamic> studentDelete(String id) async {
    try {
      return await HttpUtil.delete("/admin/student/student/$id");
    } catch (e) {
      print('Error in studentDelete: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  // 导入题目
  // static Future<dynamic> studentBatchImport(File file) async {
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
  //     return await HttpUtil.post("/admin/student/student/batch-import", params: params);
  //   } catch (e) {
  //     print('调用导入接口错误: $e');
  //     rethrow; // 重新抛出异常以便调用者处理
  //   }
  // }

  static Future<dynamic> studentBatchImport(File file) async {
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
        "http://127.0.0.1:8888/admin/student/student/batch-import",
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
  static Future<dynamic> studentExport({
    required String page,
    required String pageSize,
    required String search,
    required String cate,
    required String student_id,
  }) async {
    try {
      Map<String, dynamic> params = {
        'page': page,
        'pageSize': pageSize,
        'search': search,
        'cate': cate,
        'student_id': student_id,
      };
      return await HttpUtil.get("/admin/student/student/export", params: params);
    } catch (e) {
      print('Error in studentExport: $e');
      rethrow; // 重新抛出异常以便调用者处理
    }
  }

  static Future<dynamic> auditStudent(int studentId, int status) async {
    try {
      return await  HttpUtil.put('/admin/student/student/$studentId/audit_ret/$status');
    } catch (e) {
      throw Exception('审核请求失败: $e');
    }
  }

}
