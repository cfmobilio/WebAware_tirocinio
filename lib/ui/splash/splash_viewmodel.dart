import 'package:shared_preferences/shared_preferences.dart';

class SplashViewModel {
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirst) {
      prefs.setBool('isFirstLaunch', false);
    }
    return isFirst;
  }
}
