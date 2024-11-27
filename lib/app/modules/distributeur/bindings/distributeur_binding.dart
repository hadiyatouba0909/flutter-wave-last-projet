import 'package:get/get.dart';

import '../controllers/distributeur_controller.dart';

class DistributeurBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DistributeurController>(
      () => DistributeurController(),
    );
  }
}
