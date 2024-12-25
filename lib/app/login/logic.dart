import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:admin_flutter/app/home/view.dart';
import 'package:admin_flutter/common/app_data.dart';

class LoginLogic extends GetxController {
  var accountText = TextEditingController(text: "admin");
  var passwordText = TextEditingController(text: "admin123");
  var captchaText = TextEditingController();
  var selectedRole = '超级管理员'.obs;

  var captchaId = ''.obs;

  void login() async {
    if (accountText.text.isEmpty) {
      Get.snackbar('错误', '账号不能为空');
      return;
    }
    if (passwordText.text.isEmpty) {
      Get.snackbar('错误', '密码不能为空');
      return;
    }
    if (captchaText.text.isEmpty) {
      Get.snackbar('错误', '验证码不能为空');
      return;
    }

    try {
      final url = Uri.parse('http://127.0.0.1:8888/base/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Apifox/1.0.0 (https://apifox.com)',
        },
        body: jsonEncode({
          "username": accountText.text,
          "password": passwordText.text,
          "captcha": captchaText.text,
          "captchaId": captchaId.value,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['code'] == 0) {
        // 登录成功，保存数据并跳转
        final token = data['data']['token'];
        final role = data['data']['user']['authority']['authorityName'];

        LoginData.easySave((p0) {
          p0.token = token;
          p0.role = role;
        });

        Get.offAll(() => HomePage());
      } else {
        // 登录失败，显示错误信息
        Get.snackbar('登录失败', data['msg'] ?? '未知错误');
      }
    } catch (e) {
      // 网络请求或其他错误
      Get.snackbar('错误', '登录时发生错误: $e');
    }
  }

  void fetchCaptcha() async {
    // 请求获取验证码ID
    try {
      final url = Uri.parse('http://127.0.0.1:8888/base/captcha');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        captchaId.value = data['data']['captchaId'];
      }
    } catch (e) {
      Get.snackbar('错误', '获取验证码失败: $e');
    }
  }
}
