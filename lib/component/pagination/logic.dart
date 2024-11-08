import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:get/get.dart';


class PaginationLogic extends GetxController {
  var size = 15.obs;
  var current = 1.obs;
  var totalPage = 0.obs;
  int total = 0;
  Function(int size, int page) changed  = (size, page) {};
  void prev() {
    if (current.value == 1) {
      "已经是第一页了".toHint();
      return;
    }
    current.value--;
    reload();
  }

  void next() {
    if (current.value == totalPage.value) {
      "已经是最后一页了".toHint();
      return;
    }
     current.value++;
    reload();
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPage.value) {
      "页码超出范围".toHint();
      return;
    }
    current.value = page;
    reload();
  }

  void reload() {
    totalPage.value =
        total ~/ size.value + (total % size.value != 0 ? 1 : 0);
    changed(size.value, current.value);
  }
}
