import 'package:shared_preferences/shared_preferences.dart';

const _TOKEN = 'token';
const _EMAIL = 'email';
const _PASSWORD = 'password';

class StoreInteractor {
  SharedPreferences _prefs;

  Future<void> initSharedPreference() async{
    _prefs =  await SharedPreferences.getInstance();
  }

  String get token => _prefs.getString(_TOKEN);

  Future<void> setToken(String token) async {
    await _prefs.setString(_TOKEN, token);
  }

  String get email => _prefs.getString(_EMAIL);

  Future<void> setEmail(String email) async {
    await _prefs.setString(_EMAIL, email);
  }

  String get password => _prefs.getString(_PASSWORD);

  Future<void> setPassword(String password) async {
    await _prefs.setString(_PASSWORD, password);
  }
}
