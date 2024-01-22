import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:delivery_flutter/models/usuario.dart';
import 'package:delivery_flutter/global/enviroment.dart';
import 'package:delivery_flutter/models/authResponse.dart';


class UsuarioService  extends ChangeNotifier {
    Usuario? _usuario;
    bool _autenticando = false;

    static const _storage = FlutterSecureStorage();
    static const _keyStorage = 'usuario';

    UsuarioService()  {
      _initUser();
    }

    void _initUser() async {
      String? savedUser = await getUser();
      print(savedUser);
      if(savedUser != null && _usuario == null) {
        usuario = Usuario.fromJson(json.decode(savedUser));
      }
    }


    bool get autenticando => _autenticando;
    set autenticando(bool valor) {
      _autenticando = valor;
      notifyListeners();
    }

    Usuario? get usuario => _usuario;
    set usuario(Usuario? user)  {
      _usuario = user;
      if(user != null) _saveUser(usuario!.toJson());
      notifyListeners();
    }



    Future login (String correo, String password) async {
        autenticando = true;
        var url = Uri.parse('${Environment.apiUrl}/user/login');

        final data = {
          'correo': correo,
          'password': password
        };

        final resp = await http.post(url, 
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json'
          }
        );

        autenticando = false;

        if(resp.statusCode == 200) {


          final registerResp = authResponseFromJson(resp.body);
          usuario = registerResp.usuario;
                  
          return true;
        } else {
         
          final respBody =  jsonDecode(resp.body);
           print('Error: $respBody');
          return respBody['msg'];
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

        if(imagen != null) {
          request.files.add(http.MultipartFile(
            'image',
             http.ByteStream(imagen.openRead().cast()),
             await imagen.length(),
             filename: p.basename(imagen.path)
          ));
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

        if(imagen != null) {
          request.files.add(http.MultipartFile(
            'image',
             http.ByteStream(imagen.openRead().cast()),
             await imagen.length(),
             filename: p.basename(imagen.path)
          ));
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

    Future register(
        String nombre, 
        String apellido, 
        String telefono,
        String email, 
        String password
      ) async {
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
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json'
          }
        );

        autenticando = false;

        if(resp.statusCode == 201) {

          final registerResp = authResponseFromJson(resp.body);
          print(registerResp);
          usuario = registerResp.usuario;
 
          return true;
          
        } else {
          final respBody =  jsonDecode(resp.body);
          print('Error: $respBody');
          return respBody['msg'];
        }
      }

    Future logout(BuildContext context) async {
      usuario = null;
      await _storage.delete(key: _keyStorage);
      if(!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
    }
}