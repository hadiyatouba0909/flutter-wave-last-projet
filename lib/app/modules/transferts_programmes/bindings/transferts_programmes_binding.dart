// scheduled_transfer_binding.dart
import 'package:get/get.dart';
import 'package:vendredi/app/modules/transferts_programmes/controllers/transferts_programmes_controller.dart';

class TransfertsProgrammesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransfertsProgrammesController>(
      () => TransfertsProgrammesController(),
    );
  }
}