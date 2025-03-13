import 'dart:async';
import 'dart:ui';

import 'package:apexdmit/app/data/api/repository/api_repo.dart';
import 'package:apexdmit/app/data/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomeController extends GetxController {
  TextEditingController search = TextEditingController();
  TextEditingController item = TextEditingController();
  TextEditingController store = TextEditingController();
  TextEditingController runners_name = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController card_number = TextEditingController();
  TextEditingController date = TextEditingController();

   RxBool isLoading = false.obs;
  RxList<dynamic> purchaseList = <dynamic>[].obs;
  RxList<dynamic> filteredPurchaseList = <dynamic>[].obs; // New reactive variable
  RxInt currentPage = 1.obs;
  RxInt lastPage = 1.obs;
  RxBool hasMore = true.obs;

  Timer? _debounce;
 void onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      filterPurchases();
    });
  }

  void filterPurchases() {
    String query = search.text.toLowerCase();
    if (query.isEmpty) {
      filteredPurchaseList.assignAll(purchaseList);
    } else {
      filteredPurchaseList.assignAll(
        purchaseList.where((item) {
          return item['line_item_name'].toLowerCase().contains(query) ||
                 item['store'].toLowerCase().contains(query) ||
                 item['runners_name'].toLowerCase().contains(query) ||
                 item['transaction_date'].toLowerCase().contains(query) ||
                 item['amount'].toString().contains(query) ||
                 item['card_number'].toString().contains(query);
        }).toList(),
      );
    }
  }
  requestSubmitItem() async{
    if (item.text.isEmpty) {
      Get.snackbar("Warning", "Item name is required",
          backgroundColor: Colors.white);
    } else if (store.text.isEmpty) {
      Get.snackbar("Warning", "Store  is required",
          backgroundColor: Colors.white);
    } else if (runners_name.text.isEmpty) {
      Get.snackbar("Warning", "Runner's name is required",
          backgroundColor: Colors.white);
    } else if (amount.text.isEmpty) {
      Get.snackbar("Warning", "Amount  is required",
          backgroundColor: Colors.white);
    } else if (card_number.text.isEmpty) {
      Get.snackbar("Warning", "Card number  is required",
          backgroundColor: Colors.white);
    } else if (date.text.isEmpty) {
      Get.snackbar("Warning", "Date is required",
          backgroundColor: Colors.white);
    } else {
      try {
        List<Map<String, dynamic>> customItem = [
          {
            "line_item_name": "${item.text}",
            "store": "${store.text}",
            "runners_name": "${runners_name.text}",
            "amount": int.tryParse(amount.text) ?? 0,
            "card_number": int.tryParse(card_number.text) ?? 0,
            "transaction_date": "${date.text}"
          }
       
        ];
           await ComsRepo().addToPurchaseList(item: customItem).then((value){
            if(value!=null && value!={}){
              if(value["status_code"]=="1"){
                item.clear();
                store.clear();
                runners_name.clear();
                amount.clear();
                card_number.clear();
                date.clear();
                Get.back();
                fetchPurchases();
                Get.snackbar("Success", value['status_message'],colorText: Colors.white,backgroundColor: Colors.greenAccent);
                
              }
              else{
                  Get.back();
                Get.snackbar("Failed", value['status_message'], backgroundColor: Colors.red,colorText: Colors.white);
              }
            }
           });
      } on Exception catch (e) {
        Get.snackbar("Ops", "Couldn't add item,Try again later!", backgroundColor: Colors.red,colorText: Colors.white);
      }
    }
  }
   Future<void> fetchPurchases({bool isLoadMore = false}) async {
    if (isLoading.value || (!hasMore.value && isLoadMore)) return;

    try {
      isLoading(true);
      print("Fetching page: ${currentPage.value}");

      await ComsRepo()
          .requestPurchaseList(page: currentPage.value)
          .then((value) {
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
          filterPurchases(); // Update filtered list after fetching new data
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

  addItemWindow() {
    return Get.generalDialog(
      // barrierDismissible: true,
      // barrierLabel: 'Dismiss',
            transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4 * anim1.value,
              sigmaY: 4 * anim1.value,
            ),
            child: FadeTransition(
              child: child,
              opacity: anim1,
            ),
          ),
      pageBuilder: (ctx, anim1, anim2) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(1.0)),
          child: AlertDialog(
              backgroundColor: Colors.white,
              // insetPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              // title: Container(

              //   height: 60,
              //   color: AppColors.mainBlue,
              // ),

              content: Container(
                height: MediaQuery.of(Get.context!).size.height / 2,
                width: MediaQuery.of(Get.context!).size.width / 1.3,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Container(
                      // height: 60,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                          color: AppColors.mainBlue,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                      child: Center(
                        child: Text(
                          "Material Purchase",
                          style: GoogleFonts.roboto(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    customRow(tcontroller: item, title: "Item*"),
                    customRow(tcontroller: store, title: "Store*"),
                    customRow(
                        tcontroller: runners_name, title: "Runner's Name*"),
                    customRow(
                        tcontroller: amount,
                        title: "Amount*",
                        textInputType: TextInputType.number),
                    customRow(
                        tcontroller: card_number,
                        title: "Card No*",
                        textInputType: TextInputType.number),
                    customRow(
                        tcontroller: date,
                        title: "Date*",
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: Colors.grey.shade400,
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ZoomTapAnimation(
                            onTap: () {
                              requestSubmitItem();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: AppColors.mainBlue,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Center(
                                child: Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ))),
    );
  }

  customRow(
      {required TextEditingController tcontroller,
      required String title,
      Widget? suffixIcon,
      TextInputType? textInputType}) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: EdgeInsets.symmetric(horizontal: 10),
      // width: double.maxFinite,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(
                "${title}",
                style: GoogleFonts.roboto(color: Colors.grey.shade700),
              )),
          SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: tcontroller,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide:
                      BorderSide(width: 0.4, color: Colors.grey.shade700),
                ),
                filled: true,
                suffixIcon: suffixIcon ??
                    InkWell(
                      onTap: () {
                        tcontroller.text = "";
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade400,
                        size: 10,
                      ),
                    ),
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide:
                      BorderSide(width: 0.4, color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide:
                      BorderSide(width: 0.4, color: Colors.blue.shade700),
                ),
              ),
              keyboardType: textInputType ?? TextInputType.text,
            ),
          )
        ],
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
     search.addListener(onSearchChanged); 
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
      search.removeListener(onSearchChanged);
    _debounce?.cancel();
    super.onClose();
  }
}
