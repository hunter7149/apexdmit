import 'package:get_storage/get_storage.dart';

class Pref {
  static final box = GetStorage('apex_dmit');

  //global variables
  static var login_token = "apex_dmit_login_token";

  static void writeData({required String key, required dynamic value}) =>
      box.write(key, value);

  static dynamic readData({required String key}) => box.read(key);

  static void removeData({required String key}) => box.remove(key);
}
