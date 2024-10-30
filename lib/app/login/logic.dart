import 'package:admin_flutter/app/home/view.dart';
import 'package:admin_flutter/common/app_data.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginLogic extends GetxController {
  var accountText = TextEditingController(text: "vben");
  var passwordText = TextEditingController(text: "123456");
  var selectedRole = '超级管理员'.obs;

  void login() async {
    if (accountText.text.isEmpty) {
      Get.snackbar('错误', '账号不能为空');
      return;
    }
    if (passwordText.text.isEmpty) {
      Get.snackbar('错误', '密码不能为空');
      return;
    }

    // 这里应该是调用登录API的地方
    // 为了演示，我们直接使用本地存储和导航
    AppData.easySave((p0) {
      p0.token = "login";
      p0.role = selectedRole.value;
      Get.offAll(() => HomePage());
    });

    // 如果你有登录API，可以这样使用：
    // try {
    //   var response = await LoginApi.login(
    //     username: accountText.text,
    //     password: passwordText.text,
    //     role: selectedRole.value
    //   );
    //   if (response.success) {
    //     AppData.easySave((p0) {
    //       p0.token = response.token;
    //       p0.role = selectedRole.value;
    //       Get.offAll(() => HomePage());
    //     });
    //   } else {
    //     Get.snackbar('登录失败', response.message);
    //   }
    // } catch (e) {
    //   Get.snackbar('错误', '登录时发生错误');
    // }
  }
}