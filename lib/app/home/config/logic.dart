import 'package:get/get.dart';

import '../../../api/config_api.dart';


class ConfigLogic extends GetxController {
  static Map<String, dynamic>? configData;

  @override
  void onInit() async {
    try {
      final response = await ConfigApi.configList();
      if (response['code'] == 0) {
        configData = response['data'];
        print("load config");
        print(configData);
      } else {
        throw Exception("Failed to load config: ${response['msg'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Failed to load config: $e");
    }
    super.onInit();
  }

}
