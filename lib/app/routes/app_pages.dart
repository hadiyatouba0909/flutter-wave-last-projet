import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/distributeur/bindings/distributeur_binding.dart';
import '../modules/distributeur/views/distributeur_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/tranfertSimple/bindings/tranfert_simple_binding.dart';
import '../modules/tranfertSimple/views/tranfert_simple_view.dart';
import '../modules/transfers_multiple/bindings/transfers_multiple_binding.dart';
import '../modules/transfers_multiple/views/transfers_multiple_view.dart';
import '../modules/transferts_programmes/bindings/transferts_programmes_binding.dart';
import '../modules/transferts_programmes/views/transferts_programmes_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.AUTH;

  static final routes = [
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.TRANFERT_SIMPLE,
      page: () => const TransferSimpleView(),
      binding: TranfertSimpleBinding(),
    ),
    GetPage(
      name: Routes.DISTRIBUTEUR,
      page: () => const DistributeurView(),
      binding: DistributeurBinding(),
    ),
    GetPage(
      name: Routes.TRANSFERS_MULTIPLE,
      page: () => const TransfersMultipleView(),
      binding: TransfersMultipleBinding(),
    ),
    GetPage(
      name: Routes.TRANSFERTS_PROGRAMMES,
      page: () => const ScheduledTransferView(),
      binding: TransfertsProgrammesBinding(),
    ),
  ];
}
