
import '../provider/provider.dart';
import '../service/api_service.dart';
import '../service/app_url.dart';


class ComsRepo extends Providers {


  Future<dynamic> requestLogin({required Map<String, dynamic> map} ) async =>
      await commonApiCall(
     
          endPoint: AppUrl.login,
          method: Method.POST,
          map: map);
   Future<dynamic> requestPurchaseList({required int page}) async {
   return  await tokenBaseApi(
      endPoint: "auth/interview/material-purchase/",
      method: Method.GET, // Ensure the API supports POST for fetching data
      map: {"page": page},
    );
  }
}
