import 'dart:typed_data';
import 'package:admin_flutter/common/app_data.dart';
import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:dio/dio.dart';

class HttpUtil {
  static const String baseUrl = "http://127.0.0.1:8888";
  static const authorization = "Authorization";

  static final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Request [${options.method}] => PATH: ${options.path}, DATA: ${options.data}');
        return handler.next(options); // 调用下一步
      },
      onResponse: (response, handler) {
        print('Response [${response.statusCode}] => DATA: ${response.data}');
        return handler.next(response); // 调用下一步
      },
      onError: (DioError e, handler) {
        print('Error [${e.response?.statusCode}] => MESSAGE: ${e.message}');
        return handler.next(e); // 调用下一步
      },
    ));

  static Future<dynamic> get(String url,
      {Map<String, dynamic>? params, bool showMsg = true}) async {
    var map = await header();
    Response response = await dio.get(url,
        queryParameters: params, options: Options(headers: map));
    return verify(response.data, showMsg);
  }

  static Future<dynamic> post(String url,
      {Map<String, dynamic>? params, bool showMsg = true}) async {
    var map = await header();
    Response response = await dio.post(url,
        data: params,
        options: Options(contentType: Headers.jsonContentType, headers: map));
    return verify(response.data, showMsg);
  }

  static Future<dynamic> put(String url,
      {Map<String, dynamic>? params, bool showMsg = true}) async {
    var map = await header();
    Response response = await dio.put(url,
        data: params,
        options: Options(contentType: Headers.jsonContentType, headers: map));
    return verify(response.data, showMsg);
  }

  static Future<dynamic> delete(String url,
      {Map<String, dynamic>? params, bool showMsg = true}) async {
    var map = await header();
    Response response = await dio.delete(url,
        queryParameters: params, options: Options(headers: map));
    return verify(response.data, showMsg);
  }

  /// 全局请求头
  static Future<Map<String, dynamic>> header() async {
    var data = await AppData.read();
    return {authorization: data.token};
  }

  /// 上传文件处理
  static Future<dynamic> upload(String url, Uint8List file, String name,
      {bool showMsg = true, Function(int count, int total)? onSendProgress}) async {
    var map = await header();
    var formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(file, filename: name),
    });
    Response response = await dio.post(url,
        data: formData,
        options: Options(headers: map),
        onSendProgress: onSendProgress);
    return verify(response.data, showMsg);
  }

  /// 验证结果
  static dynamic verify(dynamic data, bool showMsg) {
    if (data["code"] == 0) {
      return data["data"];
    } else {
      if (showMsg) {
        data["msg"].toString().toHint();
      }
      return Future.error(data["msg"]);
    }
  }
}
