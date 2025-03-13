import 'package:apexdmit/app/data/api/service/prefrences.dart';
import 'package:apexdmit/app/routes/app_pages.dart';
import 'package:get/get.dart';

class SplashscreenController extends GetxController {
  checkLoginStatus() async {
    String login_token = Pref.readData(key: Pref.login_token) ?? "na";

    if (login_token.toLowerCase()=="na") {
      Get.offNamed(Routes.LOGINSCREEN);
    } else {
      Get.offNamed(Routes.HOME);
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

 
}
