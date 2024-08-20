import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GetX扩展
extension ExWidget on Widget {
  /// 去往页面
  void to() {
    Get.to(() => this);
  }
  /// 去到新页面并关闭当前页面
  void toOff(){
    Get.off(() => this);
  }
  /// 去到新页面并关闭所有页面
  void toOffAll(){
    Get.offAll(() => this);
  }

  /// 事件包裹，适合短代码的简易方法
  Widget toInkWell({Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: this,
    );
  }

}