// auth_binding.dart
import 'package:get/get.dart';
import 'package:vendredi/app/services/auth_service.dart';
import '../controllers/auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(AuthController());
  }
}