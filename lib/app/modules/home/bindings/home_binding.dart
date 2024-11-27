// home_binding.dart
import 'package:get/get.dart';
import 'package:vendredi/app/modules/auth/controllers/auth_controller.dart';
import 'package:vendredi/app/modules/home/controllers/home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(HomeController());
  }
}