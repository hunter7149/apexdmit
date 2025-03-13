import 'package:apexdmit/app/data/api/repository/api_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  TextEditingController search = TextEditingController();
  
  RxBool isLoading = false.obs;
  RxList<dynamic> purchaseList = <dynamic>[].obs;
  RxInt currentPage = 1.obs;
  RxInt lastPage = 1.obs;
  RxBool hasMore = true.obs;

Future<void> fetchPurchases({bool isLoadMore = false}) async {
  if (isLoading.value || (!hasMore.value && isLoadMore)) return;

  try {
    isLoading(true);
    print("Fetching page: ${currentPage.value}");

    await ComsRepo().requestPurchaseList(page: currentPage.value).then((value){
          if (value != null && value['status_code'] == "1") {
      final data = value['material_purchase_list'];
      final newItems = data['data'];
      lastPage.value = data['last_page'];

      print("New items received: ${newItems.length}");

      if (newItems.isNotEmpty) {
        if (isLoadMore) {
          purchaseList.addAll(newItems);
        } else {
          purchaseList.assignAll(newItems);
        }

        currentPage.value++;
        hasMore.value = currentPage.value <= lastPage.value;
      } else {
        hasMore.value = false;
      }
    } else {
      print("API returned an empty list or an error");
    }
    });
    


  } catch (e) {
    print("Error fetching data: $e");
  } finally {
    isLoading(false);
  }
}
 @override
  void onInit() {
    super.onInit();
    fetchPurchases();
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
