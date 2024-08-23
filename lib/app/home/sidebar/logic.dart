import 'dart:math';

import 'package:admin_flutter/app/home/pages/about/view.dart';
import 'package:admin_flutter/app/home/pages/admin/view.dart';
import 'package:admin_flutter/app/home/pages/analysis/view.dart';
import 'package:admin_flutter/app/home/pages/rich_text/view.dart';
import 'package:admin_flutter/app/home/pages/settings/view.dart';
import 'package:admin_flutter/app/home/pages/user/view.dart';
import 'package:admin_flutter/common/assets_util.dart';
import 'package:admin_flutter/component/upload/view.dart';
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
      children: testTree,
    ),
    UserPage.newThis(),
    AboutPage.newThis(),
    SettingsPage.newThis(),
  ];


  static void selSidebarTree(SidebarTree sel){
    if(breadcrumbList.isNotEmpty && breadcrumbList.last.name == sel.name){
      return;
    }
    breadcrumbList.clear();
    32.toDelay((){
      for(var item in treeList){
        if (item.name == sel.name) {
          breadcrumbList.add(item);
          break;
        }
        for(var child in item.children){
          if(child.name == sel.name){
            breadcrumbList.add(item);
            breadcrumbList.add(child);
            break;
          }
        }
      }
    });
  }


  static List<SidebarTree> testTree = [
    AdminPage.newThis(),
    RichTextPage.newThis(),
    SidebarTree(
      name: "上传组件",
      icon: Icons.home,
      page: Center(
        child: Column(
          children: [
            const Text(
              "当前限制只能上传10张图片",
              style: TextStyle(fontSize: 28),
            ),
            SizedBox(
                width: 500,
                child: UploadPage(
                  limit: 10,
                  multiple: true,
                  type: AssetsUtil.image(),
                )),
          ],
        ),
      ),
    ),
  ];
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
    this.page = const SizedBox(
      child: Center(
          child: Text(
            "空",
            style: TextStyle(fontSize: 26),
          )),
    ),
  });
}
