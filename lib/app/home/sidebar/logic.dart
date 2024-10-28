import 'package:admin_flutter/app/home/pages/admin/view.dart';
import 'package:admin_flutter/app/home/pages/chat/view.dart';
import 'package:admin_flutter/app/home/pages/demo/view.dart';
import 'package:admin_flutter/app/home/pages/demo2/view.dart';
import 'package:admin_flutter/app/home/pages/demo3/view.dart';
import 'package:admin_flutter/app/home/pages/empty/view.dart';
import 'package:admin_flutter/app/home/pages/play/view.dart';
import 'package:admin_flutter/app/home/pages/rich_text/view.dart';
import 'package:admin_flutter/app/home/pages/user/view.dart';
import 'package:admin_flutter/app/home/system/settings/view.dart';
import 'package:admin_flutter/ex/ex_int.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:admin_flutter/app/home/pages/job/view.dart';
import 'package:admin_flutter/app/home/pages/major/view.dart';
import 'package:admin_flutter/app/home/pages/corres/view.dart';

import '../pages/class/view.dart';
import '../pages/institution/view.dart';
import '../pages/student/view.dart';

class SidebarLogic extends GetxController {
  static var selectName = "".obs;
  var animName = "".obs;
  var expansionTile = <String>[].obs;

  /// 面包屑列表
  static var breadcrumbList = <SidebarTree>[].obs;

  static List<SidebarTree> treeList = [
    SidebarTree(
      name: "岗位管理",
      icon: Icons.expand,
      children: jobList,
    ),
    SidebarTree(
      name: "学员管理",
      icon: Icons.expand,
      children: studentList,
    ),
    SidebarTree(
      name: "试题计划",
      icon: Icons.expand,
      children: demoList,
    ),
    SidebarTree(
      name: "心理测试",
      icon: Icons.expand,
      children: demoList,
    ),
    SidebarTree(
      name: "讲义管理",
      icon: Icons.expand,
      children: demoList,
    ),
    SettingsPage.newThis(),
  ];

  static List<SidebarTree> jobList = [
    JobPage.newThis(),
    MajorPage.newThis(),
    CorresPage.newThis(),
  ];

  static List<SidebarTree> studentList = [
    InstitutionPage.newThis(),
    ClassPage.newThis(),
    StudentPage.newThis(),
  ];

  static List<SidebarTree> demoList = [
    AdminPage.newThis(),
    RichTextPage.newThis(),
    DemoPage.newThis(),
    Demo2Page.newThis(),
    Demo3Page.newThis(),
    UserPage.newThis(),
    ChatPage.newThis(),
    PlayPage.newThis(),
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
      findSidebarTree(sel,treeList);
    });
  }

  /// 递归查找面包屑
  static bool findSidebarTree(SidebarTree sel, List<SidebarTree> list) {
    for (var item in list) {
      if (item.name == sel.name) {
        breadcrumbList.add(item);
        return true;
      }
      if (item.children.isNotEmpty) {
        /// 递归查找，当找到时，将当前节点插入到面包屑列表中，并返回true
        if (findSidebarTree(sel, item.children)) {
          breadcrumbList.insert(0, item);
          return true;
        }
      }
    }
    return false;
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
