import 'dart:convert';

import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:delivery_flutter/global/enviroment.dart';
import 'package:delivery_flutter/models/categoria.dart';

class CategoriaService extends ChangeNotifier {

   final UsuarioService? _usuarioService;

   List<Categoria> _categorias = [];

   bool _submitting = false;
   bool get submitting => _submitting;
    set submitting(bool valor) {
      _submitting = valor;
      notifyListeners();
    }

    List<Categoria> get categorias => _categorias;

    set categorias(List<Categoria> valor) {
      _categorias = valor;
      notifyListeners();
    }


    CategoriaService(this._usuarioService) {
      if(_usuarioService != null) {
        print('usuario services started');
        getAll();
      }
    }

    

  Future createCat(String nombre, String descripcion, BuildContext context) async {
    submitting = true;
    try {
     var url = Uri.parse('${Environment.apiUrl}/category/create');

     final data = {
          'nombre': nombre,
          'descripcion': descripcion
      };

      final resp = await http.post(url, 
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': _usuarioService?.usuario?.sessionToken ?? ''
          }
      );

      if(resp.statusCode == 401 ) {
        if(!context.mounted) return;
        await _usuarioService?.logout();
        return;
      }

      if(resp.statusCode == 201) {
          return true;
        } else {
          final respBody =  jsonDecode(resp.body);
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
      
    } finally  {
      submitting = false;
    }
  } 

  Future getAll() async {
    try {
      var url = Uri.parse('${Environment.apiUrl}/category/all');

      final resp = await http.get(url, 
          headers: {
            'Content-Type': 'application/json',
            'Authorization': _usuarioService?.usuario?.sessionToken ?? ''
          }
      );

      if(resp.statusCode == 200) {
        final registerResp = jsonDecode(resp.body)['categorias'];
        Categoria categoria = Categoria.fromJsonList(registerResp);

        categorias = categoria.toList;

        return true;
       
      } else {
        return null;
      }

    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

}