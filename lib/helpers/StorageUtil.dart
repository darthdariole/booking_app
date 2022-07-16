import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static StorageUtil? _storageUtil;
  static SharedPreferences? _preferences;

  static Future<StorageUtil> getInstance() async {
    if (_storageUtil == null) {
      var secureStorage = StorageUtil._();
      await secureStorage._init();
      _storageUtil = secureStorage;
    }
    return Future.value(_storageUtil);
  }

  StorageUtil._();
  Future _init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static String getString(String key, {String defValue = ''}) {
    if (_preferences == null) return defValue;
    return _preferences!.getString(key) ?? defValue;
  }

  static Future<bool> putString(String key, String value) {
    if (_preferences == null) return Future.value(false);
    return _preferences!.setString(key, value);
  }

  static int getInt(String key, {int defValue = 0}) {
    if (_preferences == null) return defValue;
    return _preferences!.getInt(key) ?? defValue;
  }

  static Future<bool> putInt(String key, int value) {
    if (_preferences == null) return Future.value(false);
    return _preferences!.setInt(key, value);
  }

  static Future<bool> removeKey(String key) {
    if (_preferences == null) return Future.value(false);
    return _preferences!.remove(key);
  }

  static Future<void> clearPrefs() async {
    SharedPreferences? prefs = _preferences;
    prefs?.clear();
  }
}
