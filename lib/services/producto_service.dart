import 'dart:convert';
import 'dart:io';
import 'package:delivery_flutter/models/categoria.dart';
import 'package:delivery_flutter/services/categoria_service.dart';
import 'package:path/path.dart' as p;

import 'package:delivery_flutter/models/producto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:delivery_flutter/global/enviroment.dart';

class ProductoService extends ChangeNotifier {
  final UsuarioService? _usuarioService;

  bool _submitting = false;
  bool get submitting => _submitting;
    set submitting(bool valor) {
      _submitting = valor;
      notifyListeners();
  }


  ProductoService(this._usuarioService);

  Future<List<Producto>?> findByCat(String catId) async {

    try {
       var url = Uri.parse('${Environment.apiUrl}/product/all/$catId');
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
        
        final prodRes = Producto.fromJsonList(data['data']);

        return prodRes.toList;

    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future createProd(Producto producto, List<File> images) async {
      submitting = true;
    try {
      var url = Uri.parse('${Environment.apiUrl}/product/create');

      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = _usuarioService?.usuario?.sessionToken ?? '';

      for (int i = 0; i < images.length; i++) {
        request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(images[i].openRead().cast()),
          await images[i].length(),
          filename: p.basename(images[i].path)
        ));
      }


       request.fields['producto'] = jsonEncode(producto);

       final response = await request.send();

       return response.stream.transform(utf8.decoder);

    } catch (e) {
      print('Error $e');
    } finally {
      submitting = false;
    }
  }

  
}