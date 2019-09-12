import 'package:shared_preferences/shared_preferences.dart';

const _TOKEN = 'TOKEN';

class StoreInteractor {
  SharedPreferences _prefs;

  Future<void> initSharedPreference() async{
    _prefs =  await SharedPreferences.getInstance();
  }

  String get token => _prefs.getString(_TOKEN);

  Future<void> setToken(String token) async {
    await _prefs.setString(_TOKEN, token);
  }
}
