import 'package:apexdmit/app/data/api/service/prefrences.dart';
import 'package:apexdmit/app/data/colors/app_colors.dart';
import 'package:apexdmit/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: ZoomTapAnimation(
            onTap: () {
              Get.back();
            },
            child: Container(
              margin: EdgeInsets.all(10),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: AppColors.mainBlue,
                  borderRadius: BorderRadius.circular(100)),
              child: Center(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          title: Text('Material Purchase'),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == "logout") {
                  Pref.removeData(key: Pref.login_token);
                  Get.offAllNamed(Routes.LOGINSCREEN);
                }
              },
              icon: Icon(
                Icons.more_vert,
                color: AppColors.mainBlue,
                size: 40,
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  height: 40,
                  padding: EdgeInsets.zero,
                  value: "logout",
                  child: Container(
                    height: 40,
                    color: AppColors.mainBlue,
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        Text("logout", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: ZoomTapAnimation(
          onTap: () {
            controller.addItemWindow();
          },
          child: Container(
            height: 54,
            width: 54,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.mainBlue,
                borderRadius: BorderRadius.circular(27)),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24)),
              child: Center(
                  child: Icon(
                Icons.add,
                color: AppColors.mainBlue,
                size: 21,
              )),
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: TextField(
                  controller: controller.search,
                  decoration: InputDecoration(
                    labelText: "Search",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    suffixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.purchaseList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          headingRowColor: WidgetStateProperty.all(
                              AppColors.mainBlue), // Header color
                          headingTextStyle: GoogleFonts.roboto(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          columns: const [
                            DataColumn(label: Text('SL')),
                            DataColumn(label: Text('User Role')),
                            DataColumn(label: Text('Store')),
                            DataColumn(label: Text('Runner')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Card Number')),
                          ],
                          rows: controller.filteredPurchaseList.isEmpty
                              ? controller.purchaseList
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    int index = entry.key;
                                    var item = entry.value;
                                    return DataRow(
                                        color: WidgetStateColor.resolveWith(
                                          (Set<WidgetState> states) {
                                            if (index % 2 == 0) {
                                              return Colors.white; // even rows
                                            } else {
                                              return AppColors
                                                  .tableGreyBody; // odd rows
                                            }
                                          },
                                        ),
                                        cells: [
                                          DataCell(Text("${index + 1}")),
                                          DataCell(Text(item['line_item_name'])),
                                          DataCell(Text(item['store'])),
                                          DataCell(Text(item['runners_name'])),
                                          DataCell(Text(item['transaction_date']
                                              .split(' ')[0])),
                                          DataCell(Text("\$${item['amount']}")),
                                          DataCell(Text(item['card_number'])),
                                        ]);
                                  }).toList()
                              : controller.filteredPurchaseList
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    int index = entry.key;
                                    var item = entry.value;
                                    return DataRow(
                                        color: WidgetStateColor.resolveWith(
                                          (Set<WidgetState> states) {
                                            if (index % 2 == 0) {
                                              return Colors.white; // even rows
                                            } else {
                                              return AppColors
                                                  .tableGreyBody; // odd rows
                                            }
                                          },
                                        ),
                                        cells: [
                                          DataCell(Text("${index + 1}")),
                                          DataCell(Text(item['line_item_name'])),
                                          DataCell(Text(item['store'])),
                                          DataCell(Text(item['runners_name'])),
                                          DataCell(Text(item['transaction_date']
                                              .split(' ')[0])),
                                          DataCell(Text("\$${item['amount']}")),
                                          DataCell(Text(item['card_number'])),
                                        ]);
                                  }).toList(),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ));
  }
}
