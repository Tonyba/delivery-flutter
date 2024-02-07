
import 'dart:convert';

import 'package:delivery_flutter/models/pedido.dart';
import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import '../global/enviroment.dart';

import 'package:delivery_flutter/main.dart';

class PedidoService {

  UsuarioService? _usuarioService;

  PedidoService(this._usuarioService);

  Future<List<Pedido>?> findByEstado(String estado) async {

    try {
       var url = Uri.parse('${Environment.apiUrl}/order/getByStatus/$estado');
       Map<String, String> headers = {
          'Content-type': 'application/json',
          'Authorization': _usuarioService?.usuario?.sessionToken ?? ''
       };

        final resp = await http.get(url, headers: headers);

        if(resp.statusCode == 401) {
          await _usuarioService?.logout();
          return null;
        }

        if(resp.statusCode != 200) {
          return null;
        }

        final data = json.decode(resp.body);
        
        final orderRes = Pedido.fromJsonList(data['data']);

        return orderRes.toList;

    } catch (e) {
      print('Error: $e');
      return null;
    }
  }


  Future despacharPedido(Pedido pedido) async {
    try {
      var url = Uri.parse('${Environment.apiUrl}/order/dispatch');

      String bodyParams = json.encode(pedido);

      Map<String, String> headers = {      
            'Content-Type': 'application/json',
            'Authorization': _usuarioService?.usuario?.sessionToken ?? ''         
      };

      final res = await http.put(url, headers: headers, body: bodyParams);

      if(res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion Expirada');
        navigatorKey.currentState?.pushNamedAndRemoveUntil('login', (route) => false);
        return;
      }

      final data = json.decode(res.body);

      if(data['success'] == true) {

        return true;

      } else {
        Fluttertoast.showToast(msg: data['msg']);
      }

    } catch (e) {
    
      print('error: $e');
      return 'Server Error';

    }
  }


  Future createOrder(Pedido pedido) async {
    try {
      var url = Uri.parse('${Environment.apiUrl}/order/create');

      String bodyParams = json.encode(pedido);

      Map<String, String> headers = {      
            'Content-Type': 'application/json',
            'Authorization': _usuarioService?.usuario?.sessionToken ?? ''         
      };

      final res = await http.post(url, headers: headers, body: bodyParams);

      if(res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion Expirada');
        navigatorKey.currentState?.pushNamedAndRemoveUntil('login', (route) => false);
        return;
      }

      final data = json.decode(res.body);

      if(data['success'] == true) {

        return true;

      } else {
        Fluttertoast.showToast(msg: data['msg']);
      }

    } catch (e) {
    
      print('error: $e');
      return 'Server Error';

    }
  }
 

}