import 'package:admin_flutter/app/home/pages/admin/view.dart';
import 'package:admin_flutter/app/home/pages/demo/view.dart';
import 'package:admin_flutter/app/home/pages/empty/view.dart';
import 'package:admin_flutter/app/home/pages/rich_text/view.dart';
import 'package:admin_flutter/app/home/pages/user/view.dart';
import 'package:admin_flutter/app/home/system/about/view.dart';
import 'package:admin_flutter/app/home/system/analysis/view.dart';
import 'package:admin_flutter/app/home/system/settings/view.dart';
import 'package:admin_flutter/ex/ex_int.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SidebarLogic extends GetxController {
  static var selectName = "".obs;
  var animName = "".obs;
  var expansionTile = <String>[].obs;

  /// 面包屑列表
  static var breadcrumbList = <SidebarTree>[].obs;

  static List<SidebarTree> treeList = [
    AnalysisPage.newThis(),
    SidebarTree(
      name: "示例页面",
      icon: Icons.expand,
      children: demoList,
    ),
    AboutPage.newThis(),
    SettingsPage.newThis(),
  ];

  static List<SidebarTree> demoList = [
    AdminPage.newThis(),
    RichTextPage.newThis(),
    DemoPage.newThis(),
    UserPage.newThis(),
    SidebarTree(
      name: "嵌套页面",
      icon: Icons.extension,
      children: demo2List,
    ),
  ];

  static List<SidebarTree> demo2List = [
    newThis("示例1"),
    newThis("示例2"),
    newThis("示例3"),
    newThis("示例4"),
  ];

  /// 面包屑和侧边栏联动
  static void selSidebarTree(SidebarTree sel) {
    if (breadcrumbList.isNotEmpty && breadcrumbList.last.name == sel.name) {
      return;
    }
    breadcrumbList.clear();
    32.toDelay(() {
      for (var item in treeList) {
        if (item.name == sel.name) {
          breadcrumbList.add(item);
          break;
        }
        for (var child in item.children) {
          if (child.name == sel.name) {
            breadcrumbList.add(item);
            breadcrumbList.add(child);
            break;
          }
        }
      }
    });
  }
}

class SidebarTree {
  final String name;
  final IconData icon;
  final List<SidebarTree> children;
  var isExpanded = false.obs;
  final Widget page;

  SidebarTree({
    required this.name,
    this.icon = Icons.ac_unit,
    this.children = const [],
    this.page = const EmptyPage(),
  });
} 

SidebarTree newThis(String name) {
  return SidebarTree(
    name: name,
    icon: Icons.supervised_user_circle,
  );
}
