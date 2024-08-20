import 'package:app_template/app/home/view.dart';
import 'package:app_template/common/app_data.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';


class LoginLogic extends GetxController {

  var accountText = TextEditingController(text: "vben");
  var passwordText = TextEditingController(text: "123456");

  void login() async {
    AppData.easySave(
        (p0) => {p0.token = "login", Get.offAll(() => HomePage())});
  }
}
