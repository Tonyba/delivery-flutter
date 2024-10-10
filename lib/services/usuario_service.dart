import 'dart:convert';
import 'dart:io';

import 'package:delivery_flutter/helpers/check_internet.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:delivery_flutter/models/usuario.dart';
import 'package:delivery_flutter/global/enviroment.dart';
import 'package:delivery_flutter/models/authResponse.dart';

import 'package:delivery_flutter/main.dart';

class UsuarioService extends ChangeNotifier {
  Usuario? _usuario;
  bool _autenticando = false;

  String _selectedRole = 'CLIENTE';

  static const _storage = FlutterSecureStorage();
  static const _keyStorage = 'usuario';

  bool get isRepartidor =>
      _usuario?.roles?.indexWhere((rol) => rol.nombre == 'REPARTIDOR') != -1;
  bool get isRestaurant =>
      _usuario?.roles?.indexWhere((rol) => rol.nombre == 'RESTAURANTE') != -1;

  String get selectedRole {
    final roleLen = _usuario?.roles?.length;

    switch (roleLen) {
      case 2:
        _selectedRole = 'REPARTIDOR';
        break;

      case 3:
        _selectedRole = "RESTAURANTE";

      default:
        _selectedRole = 'CLIENTE';
    }

    return _selectedRole;
  }

  UsuarioService() {
    _initUser();
  }

  void _initUser() async {
    String? savedUser = await getUser();
    if (savedUser != null && _usuario == null) {
      usuario = Usuario.fromJson(json.decode(savedUser));
      await checkToken();
    }
  }

  bool get autenticando => _autenticando;
  set autenticando(bool valor) {
    _autenticando = valor;
    notifyListeners();
  }

  Usuario? get usuario => _usuario;
  set usuario(Usuario? user) {
    _usuario = user;
    if (user != null) _saveUser(usuario!.toJson());
    notifyListeners();
  }

  Future getRepartidores() async {
    try {
      var url = Uri.parse('${Environment.apiUrl}/user/deliverymen');

      final resp = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': _usuario?.sessionToken ?? ''
      });

      if (resp.statusCode == 200) {
        final data = Usuario.fromJsonList(jsonDecode(resp.body));

        return data.toList;
      } else {
        final respBody = jsonDecode(resp.body);
        print('Error: $respBody');

        return respBody['msg'];
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future checkToken() async {
    autenticando = true;
    var url = Uri.parse('${Environment.apiUrl}/user/checkToken');

    final resp = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': _usuario?.sessionToken ?? ''
    });

    autenticando = false;

    if (resp.statusCode == 200) {
      if (usuario != null) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
            usuario!.roles!.length > 1 ? 'roles' : 'products',
            (route) => false);
      }

      return true;
    } else {
      await logout();
      final respBody = jsonDecode(resp.body);
      print('Error: $respBody');
      return respBody['msg'];
    }
  }

  Future login(String correo, String password) async {
    final hasInternet = await checkInternet();
    if (!hasInternet) return 'No internet';

    autenticando = true;
    var url = Uri.parse('${Environment.apiUrl}/user/login');

    final data = {'correo': correo, 'password': password};

    try {
      final resp = await http.post(url,
          body: jsonEncode(data),
          headers: {'Content-Type': 'application/json'});

      if (resp.statusCode == 200) {
        final registerResp = authResponseFromJson(resp.body);
        usuario = registerResp.usuario;

        return true;
      } else {
        final respBody = jsonDecode(resp.body);

        return respBody['msg'];
      }
    } catch (e) {
      print(e);
      return 'NETWORK ERROR';
    } finally {
      autenticando = false;
    }
  }

  Future getById(String id) async {
    late var resp;

    try {
      var url = Uri.parse('${Environment.apiUrl}/user/findById/$id');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': usuario?.sessionToken ?? ''
      };

      final res = await http.get(url, headers: headers);

      final data = json.decode(res.body);

      if (!data['success']) resp = data['msg'];

      Usuario user = Usuario.fromJson(data['usuario']);
      usuario = user;

      if (res.statusCode == 401) {
        return 'Sesion Expirada';
      }

      return true;
    } catch (e) {
      print('Error: $e');
      return resp;
    }
  }

  static Future<String?> getUser() async {
    const storage = FlutterSecureStorage();
    final user = await storage.read(key: _keyStorage);
    return user;
  }

  static Future<void> deleteUser() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: _keyStorage);
  }

  Future _saveUser(Map<String, dynamic> user) async {
    return await _storage.write(key: _keyStorage, value: jsonEncode(user));
  }

  Future<Stream?> registerWithImage(Usuario user, File? imagen) async {
    autenticando = true;
    try {
      var url = Uri.parse('${Environment.apiUrl}/user/register');
      final request = http.MultipartRequest('POST', url);

      if (imagen != null) {
        request.files.add(http.MultipartFile('image',
            http.ByteStream(imagen.openRead().cast()), await imagen.length(),
            filename: p.basename(imagen.path)));
      }

      request.fields['user'] = json.encode(user);
      final response = await request.send();

      autenticando = false;

      return response.stream.transform(utf8.decoder);
    } catch (e) {
      print('Error aca: $e');
      autenticando = false;
      return null;
    }
  }

  Future<Stream?> updateWithImage(Usuario user, File? imagen) async {
    autenticando = true;
    try {
      var url = Uri.parse('${Environment.apiUrl}/user/update');
      final request = http.MultipartRequest('PUT', url);

      request.headers['Authorization'] = usuario?.sessionToken ?? '';

      if (imagen != null) {
        request.files.add(http.MultipartFile('image',
            http.ByteStream(imagen.openRead().cast()), await imagen.length(),
            filename: p.basename(imagen.path)));
      }

      request.fields['user'] = json.encode(user);
      final response = await request.send();

      autenticando = false;

      if (response.statusCode == 401) {
        await logout();
      }

      return response.stream.transform(utf8.decoder);
    } catch (e) {
      print('Error aca: $e');
      autenticando = false;
      return null;
    }
  }

  Future register(String nombre, String apellido, String telefono, String email,
      String password) async {
    autenticando = true;

    var url = Uri.parse('${Environment.apiUrl}/user/register');
    final data = {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'correo': email,
      'password': password
    };

    final resp = await http.post(url,
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    autenticando = false;

    if (resp.statusCode == 201) {
      final registerResp = authResponseFromJson(resp.body);
      print(registerResp);
      usuario = registerResp.usuario;

      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      print('Error: $respBody');
      return respBody['msg'];
    }
  }

  Future logout() async {
    if (usuario == null) return;
    Fluttertoast.showToast(msg: 'Sesion Expirada');
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('login', (route) => false);

    try {
      var url = Uri.parse('${Environment.apiUrl}/user/logout');

      String body = json.encode({'id': usuario?.id});

      usuario = null;

      await http
          .post(url, body: body, headers: {'Content-Type': 'application/json'});

      await _storage.delete(key: _keyStorage);
    } catch (e) {
      print('Error: $e');
    }
  }
}
