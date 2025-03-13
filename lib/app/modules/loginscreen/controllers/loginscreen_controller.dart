import 'package:apexdmit/app/data/api/repository/api_repo.dart';
import 'package:apexdmit/app/data/api/service/prefrences.dart';
import 'package:apexdmit/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginscreenController extends GetxController {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  RxBool isPassObsecure = true.obs;
  isOldPassObsecureUpdater() {
    isPassObsecure.value = !isPassObsecure.value;
    update();
  }

  RxBool isRemember = true.obs;
  updateIsRememer() {
    isRemember(!isRemember.value);

    update();
    print("isRemmember valu -> ${isRemember.value}");
  }

  RxBool isLoging = false.obs;
  requestLogin() async {
    if (email.text.isEmpty) {
      Get.snackbar("Warning", "Email can't be empty",backgroundColor: Colors.blue.shade200);
    } else if (password.text.isEmpty) {
      Get.snackbar("Warning", "Email can't be empty",backgroundColor: Colors.blue.shade200);
    } else {
      isLoging(true);
      try {
        ComsRepo().requestLogin(map: {
          "email": "${email.text}",
          "password": "${password.text}"
        }).then((value)async{
           if( value!={}){
              if(isRemember.value){
                Pref.writeData(key: Pref.login_token, value: value['access_token'].toString());
                
              }
              print("Here is the token: ${Pref.readData(key: Pref.login_token)}");
              Get.offNamed(Routes.HOME);
           }

        });
      } on Exception catch (e) {
        Get.snackbar("Warning", "Couldn't login",backgroundColor: Colors.red.shade400);
      }
      finally{
        isLoging(false);
      }
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
