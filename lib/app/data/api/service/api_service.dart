
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
enum Method { POST, GET, PUT, DELETE, PATCH ,PARAMS}
const BASE_URL = 'https://devapi.propsoft.ai/api/';

const Duration CONNECTION_TIMEOUT = Duration(seconds: 30);
class ApiService extends GetxService {
  late Dio _dio;
  static header({String? token}) => {
        "Content-Type": 'application/json',
        "Accept": 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  ApiService({String? token}) {
    _dio = Dio(BaseOptions(
      baseUrl:BASE_URL,
      headers: header(token: token),
      connectTimeout: CONNECTION_TIMEOUT,
      receiveTimeout: CONNECTION_TIMEOUT,
    ));
    // print(BASE_URL2);
    initInterceptors();
  }

  void initInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      print('REQUEST[${options.method}] => PATH: ${options.path} '
          '=> Request Values: ${options.queryParameters}, => HEADERS: ${options.headers}');
      return handler.next(options);
    }, onResponse: (response, handler) {
      print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
      return handler.next(response);
    }, onError: (err, handler) {
      print('ERROR[${err.response?.statusCode}]');
      return handler.next(err);
    }));
  }


 Future<Map<String, dynamic>> request(
  String url,
  Method method,
  Map<String, dynamic>? params,
) async {
  print("Requested params -> $params");

  try {
    Response response;

    switch (method) {
      case Method.POST:
        response = await _dio.post(url, data: params);
        break;
      case Method.DELETE:
        response = await _dio.delete(url);
        break;
      case Method.PATCH:
        response = await _dio.patch(url, data: params);
        break;
      case Method.PUT:
        response = await _dio.put(url, data: params);
        break;
      case Method.PARAMS:
        response = await _dio.post(url, queryParameters: params);
        break;
      default:
        response = await _dio.get(url, queryParameters: params);
    }
    

    print("Response status code -> ${response.statusCode}");

    // Handle successful response (status code 200)
    if (response.statusCode == 200 || response.statusCode ==201) {
      if (response.data is List) {
        return {"data": response.data};
      } else if (response.data is Map) {
        return response.data;
      } else if (response.data is String) {
        return {"stringError": response.data};
      } else {
        throw Exception("Unexpected response format");
      }
    }

    // Handle other status codes
    if (response.statusCode == 422) {
      return response.data;
    } else if (response.statusCode == 400) {
      throw Exception({
        "Error": true,
        "message": response.data,
      });
    }
    else if (response.statusCode == 500) {
      throw Exception("Server Error");
    } else {
      throw Exception("Something Went Wrong");
    }
  } on DioException catch (e) {
  
    throw DioException(requestOptions: e.requestOptions, message: "Unknown Dio error occurred");
  
}
   on SocketException {
    throw Exception("No Internet Connection");
  }
  on FormatException {
    throw Exception("Bad Response Format!");
  } catch (e) {
    // General error handler for unexpected exceptions
    print(e);
    throw Exception({
      "Error": true,
      "message": "An unexpected error occurred",
    });
  }
}

}
