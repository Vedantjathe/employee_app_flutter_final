
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  static Future<bool> hasConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
  }
}