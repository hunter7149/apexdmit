import 'dart:async';
import 'dart:ui';

import 'package:apexdmit/app/data/api/repository/api_repo.dart';
import 'package:apexdmit/app/data/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomeController extends GetxController {
  final TextEditingController search = TextEditingController();
  final TextEditingController item = TextEditingController();
  final TextEditingController store = TextEditingController();
  final TextEditingController runnersName = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController date = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxList<dynamic> purchaseList = <dynamic>[].obs;
  final RxList<dynamic> filteredPurchaseList = <dynamic>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxBool hasMore = true.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
    search.addListener(onSearchChanged);
  }

  @override
  void onClose() {
    search.removeListener(onSearchChanged);
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), filterPurchases);
  }

  void filterPurchases() {
    final query = search.text.toLowerCase();
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

  Future<void> requestSubmitItem() async {
    if (item.text.isEmpty) {
      Get.snackbar("Warning", "Item name is required", backgroundColor: Colors.white);
    } else if (store.text.isEmpty) {
      Get.snackbar("Warning", "Store is required", backgroundColor: Colors.white);
    } else if (runnersName.text.isEmpty) {
      Get.snackbar("Warning", "Runner's name is required", backgroundColor: Colors.white);
    } else if (amount.text.isEmpty) {
      Get.snackbar("Warning", "Amount is required", backgroundColor: Colors.white);
    } else if (cardNumber.text.isEmpty) {
      Get.snackbar("Warning", "Card number is required", backgroundColor: Colors.white);
    } else if (date.text.isEmpty) {
      Get.snackbar("Warning", "Date is required", backgroundColor: Colors.white);
    } else {
      try {
        final customItem = [
          {
            "line_item_name": item.text,
            "store": store.text,
            "runners_name": runnersName.text,
            "amount": int.tryParse(amount.text) ?? 0,
            "card_number": int.tryParse(cardNumber.text) ?? 0,
            "transaction_date": date.text
          }
        ];
        final value = await ComsRepo().addToPurchaseList(item: customItem);
        if (value != null && value.isNotEmpty) {
          if (value["status_code"] == "1") {
            item.clear();
            store.clear();
            runnersName.clear();
            amount.clear();
            cardNumber.clear();
            date.clear();
            Get.back();
            fetchPurchases();
            Get.snackbar("Success", value['status_message'], colorText: Colors.white, backgroundColor: Colors.greenAccent);
          } else {
            Get.back();
            Get.snackbar("Failed", value['status_message'], backgroundColor: Colors.red, colorText: Colors.white);
          }
        }
      } catch (e) {
        Get.snackbar("Ops", "Couldn't add item, try again later!", backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  Future<void> fetchPurchases({bool isLoadMore = false}) async {
    if (isLoading.value || (!hasMore.value && isLoadMore)) return;

    try {
      isLoading(true);
      final value = await ComsRepo().requestPurchaseList(page: currentPage.value);
      if (value != null && value['status_code'] == "1") {
        final data = value['material_purchase_list'];
        final newItems = data['data'];
        lastPage.value = data['last_page'];

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
        filterPurchases();
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      isLoading(false);
    }
  }

  void addItemWindow() {
    Get.generalDialog(
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
        child: FadeTransition(child: child, opacity: anim1),
      ),
      pageBuilder: (ctx, anim1, anim2) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(1.0)),
        child: AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Container(
            height: MediaQuery.of(Get.context!).size.height / 2,
            width: MediaQuery.of(Get.context!).size.width / 1.3,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.mainBlue,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text("Material Purchase", style: GoogleFonts.roboto(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
                customRow(tcontroller: item, title: "Item*"),
                customRow(tcontroller: store, title: "Store*"),
                customRow(tcontroller: runnersName, title: "Runner's Name*"),
                customRow(tcontroller: amount, title: "Amount*", textInputType: TextInputType.number),
                customRow(tcontroller: cardNumber, title: "Card No*", textInputType: TextInputType.number),
                customRow(tcontroller: date, title: "Date*", suffixIcon: Icon(Icons.calendar_month, color: Colors.grey.shade400)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ZoomTapAnimation(
                        onTap: requestSubmitItem,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppColors.mainBlue, borderRadius: BorderRadius.circular(5)),
                          child: Center(child: Text("Save", style: TextStyle(color: Colors.white))),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customRow({
    required TextEditingController tcontroller,
    required String title,
    Widget? suffixIcon,
    TextInputType? textInputType,
  }) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(title, style: GoogleFonts.roboto(color: Colors.grey.shade700)),
          ),
          SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: TextField(
              controller: tcontroller,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: BorderSide(width: 0.4, color: Colors.grey.shade700),
                ),
                filled: true,
                suffixIcon: suffixIcon ?? InkWell(
                  onTap: () => tcontroller.clear(),
                  child: Icon(Icons.close, color: Colors.grey.shade400, size: 10),
                ),
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: BorderSide(width: 0.4, color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: BorderSide(width: 0.4, color: Colors.blue.shade700),
                ),
              ),
              keyboardType: textInputType ?? TextInputType.text,
            ),
          )
        ],
      ),
    );
  }
}
