import 'package:app_template/app/login/view.dart';
import 'package:app_template/common/app_data.dart';
import 'package:get/get.dart';

import 'state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  void logout() {
     AppData.easySave((p0) => {
       p0.token = "",
       Get.offAll(() => LoginPage())
     });
  }
}
