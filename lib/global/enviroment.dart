import 'dart:io';

// class Environment {
//   static String apiUrl = Platform.isAndroid
//       ? 'https://e55f-206-62-174-129.ngrok-free.app/api'
//       : 'https://e55f-206-62-174-129.ngrok-free.app/api';

//   static String socketUrl = Platform.isAndroid
//       ? 'https://e55f-206-62-174-129.ngrok-free.app'
//       : 'https://e55f-206-62-174-129.ngrok-free.app';
// }

class Environment {
  static String apiUrl = Platform.isAndroid
      ? 'http://192.168.10.7:3000/api'
      : 'http://192.168.10.7:3000/api';

  static String socketUrl = Platform.isAndroid
      ? 'http://192.168.10.7:3000'
      : 'http://192.168.10.7:3000';
}
