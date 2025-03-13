import 'package:apexdmit/app/data/colors/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ZoomTapAnimation(
          onTap: (){
            Get.back();
          },
          child: Container(
            margin: EdgeInsets.all(10),
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: AppColors.mainBlue,
              borderRadius: BorderRadius.circular(100)
          
            ),
            child: Center(child: Icon(Icons.arrow_back,color: Colors.white,),),
          ),
        ),
        title:  Text('Material Purchase'),
        centerTitle: true,
        actions: [
          Icon(Icons.more_vert,color: AppColors.mainBlue,size: 40,),
          SizedBox(width: 20,),
        ],
      ),
      body:Container(
        height: MediaQuery.of(context).size.height,
        width:  MediaQuery.of(context).size.width,
        child: Column(
          children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 16),
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
              if (controller.isLoading.value && controller.purchaseList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: controller.purchaseList.length + 1, // +1 for pagination
                itemBuilder: (context, index) {
                  if (index < controller.purchaseList.length) {
                    final item = controller.purchaseList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const Icon(Icons.shopping_cart, color: Colors.blue),
                        title: Text(
                          item['line_item_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Store: ${item['store']}"),
                            Text("Runner: ${item['runners_name']}"),
                            Text(
                              "Date: ${item['transaction_date'].split(' ')[0]}",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("\$${item['amount']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Card: ${item['card_number']}", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Visibility(
                      visible: controller.hasMore.value,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => controller.fetchPurchases(isLoadMore: true),
                            child: const Text("Load More"),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            }),
          ),  ],
        ),
      )
    );
  }
}
