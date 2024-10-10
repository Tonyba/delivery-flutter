import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

bool _hasInternet = false;
ConnectivityResult _connectionStatus = ConnectivityResult.none;
final Connectivity _connectivity = Connectivity();

Future<bool> checkInternet() async {
  await _checkConectivity();

  if (_connectionStatus == ConnectivityResult.none) {
    return false;
  }

  await _checkInternetAccess();

  if (!_hasInternet) {
    return false;
  }

  return true;
}

Future<void> _checkConectivity() async {
  try {
    _connectionStatus = await _connectivity.checkConnectivity();
    await _checkInternetAccess();
  } catch (e) {
    print(e);
  }
}

Future<void> _checkInternetAccess() async {
  try {
    final result = await http.get(Uri.parse('https://www.google.com'));
    _hasInternet = result.statusCode == 200;
  } catch (e) {
    _hasInternet = false;
  }
}
