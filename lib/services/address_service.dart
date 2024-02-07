import 'dart:convert';


import 'package:flutter/material.dart';


import 'package:http/http.dart' as http;
import 'package:delivery_flutter/models/direccion.dart';
import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:delivery_flutter/global/enviroment.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DireccionService  {

    final UsuarioService? _usuarioService;
    static const _storage = FlutterSecureStorage();
    static const _keyStorage = 'direccion';

    DireccionService(this._usuarioService);


    Future<List<Direccion>> getUserAddresses(String id_user, BuildContext context) async {
      try {
        
         Uri url = Uri.parse('${Environment.apiUrl}/address/get-addresses/$id_user');

         Map<String, String> headers = {
          'Content-type': 'application/json',
          'Authorization': _usuarioService?.usuario?.sessionToken ?? ''
         };

         final resp = await http.get(url, 
            headers: headers
         );

          if(resp.statusCode == 401 ) {
            if(!context.mounted) [];
            await _usuarioService?.logout();
            return [];
          }

          final respBody =  jsonDecode(resp.body);

          final data = Direccion.fromJsonList(respBody['data']);
         
          return data.toList;
 
      } catch (e) {
        print('Error $e');
        return [];
      }
    }


    Future createAddress(Direccion direccion, BuildContext context) async {
      try {
        Uri url = Uri.parse('${Environment.apiUrl}/address/create');
        String bodyParams = json.encode(direccion);

        Map<String, String> headers = {
          'Content-type': 'application/json',
          'Authorization': _usuarioService?.usuario?.sessionToken ?? ''
        };

        final resp = await http.post(url, 
          body: bodyParams,
          headers: headers
        );

        if(resp.statusCode == 401 ) {
          if(!context.mounted) return;
          await _usuarioService?.logout();
          return;
        }

        final respBody =  jsonDecode(resp.body);
        if(resp.statusCode == 201) {
          return respBody;
        } else {
        
          String err = '';

          if(respBody['msg'] != null) {
            err = respBody['msg'];
          } else {
            err = respBody;
          }

          return err;
        }

      } catch (e) {
        print('Error $e');
        return 'Error de servidor';
      }
    }

    Future saveSelectedAddress(Direccion direccion) async {
      await _storage.write(key: _keyStorage, value: direccionToJson(direccion));
    }

    Future<Direccion?> getLastSelectedAddress() async {

      const storage = FlutterSecureStorage();
      final address = await storage.read(key: _keyStorage);

      if(address != null) {
        return Direccion.fromJson(json.decode(address));
      } else {
        return null;
      }

      
    }
    

}