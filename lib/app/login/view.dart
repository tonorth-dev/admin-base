import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/theme_util.dart';
import '../../theme/ui_theme.dart';
import 'logic.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final logic = Get.put(LoginLogic());

  @override
  Widget build(BuildContext context) {
    // 初始化加载验证码
    logic.fetchCaptcha();

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '红师教育登录入口',
                style: TextStyle(fontSize: 32),
              ),
              ThemeUtil.height(height: 18),
              Obx(() => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '选择角色',
                  border: OutlineInputBorder(),
                ),
                value: logic.selectedRole.value,
                onChanged: (String? newValue) {
                  logic.selectedRole.value = newValue!;
                },
                items: <String>[
                  '超级管理员',
                  '题库管理',
                  '考生管理',
                  '岗位管理',
                  '讲义和心理管理'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )),
              ThemeUtil.height(),
              textInput(logic.accountText,
                  hintText: '请输入账号', labelText: '账号'),
              ThemeUtil.height(),
              textInput(logic.passwordText,
                  hintText: '请输入密码', labelText: '密码', password: true),
              ThemeUtil.height(),
              Row(
                children: [
                  Expanded(
                    child: textInput(logic.captchaText,
                        hintText: '请输入验证码', labelText: '验证码'),
                  ),
                  Obx(() => logic.captchaId.isEmpty
                      ? Container()
                      : Image.network(
                    'http://127.0.0.1:8888/base/captcha/${logic.captchaId.value}',
                    height: 50,
                    width: 100,
                    fit: BoxFit.cover,
                  )),
                ],
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  logic.login();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: ThemeUtil.boxDecoration(
                      color: UiTheme.primary()),
                  child: Center(
                      child: Text(
                        '登入',
                        style:
                        TextStyle(color: UiTheme.onPrimary(), fontSize: 16),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textInput(TextEditingController text,
      {String? hintText, String? labelText, bool password = false}) {
    return TextField(
      controller: text,
      obscureText: password,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: UiTheme.primary(),
          ),
        ),
      ),
    );
  }
}
