import 'dart:async';

import 'package:apexdmit/app/data/colors/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splashscreen_controller.dart';

class SplashscreenView extends GetView<SplashscreenController> {
  const SplashscreenView({super.key});
  @override
  Widget build(BuildContext context) {
        Timer(Duration(seconds: 2), () {
      controller.checkLoginStatus();
   

    });
    return Scaffold(
 
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: AppColors.mainBlue),
        child: Center(
          child: Icon(Icons.shield,size: 100,color: Colors.white,),
        ),
      )
    );
  }
}
