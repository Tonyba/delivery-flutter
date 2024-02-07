import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as p;

import 'package:delivery_flutter/models/producto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:delivery_flutter/global/enviroment.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductoService extends ChangeNotifier {
  final UsuarioService? _usuarioService;

  static const _storage = FlutterSecureStorage();
  static const _keyStorage = 'selectedProds';

  double _total = 0;

  bool _submitting = false;
  bool get submitting => _submitting;
    set submitting(bool valor) {
      _submitting = valor;
      notifyListeners();
  }


  List<Producto> _selectedProds = [];
  List<Producto> get selectedProds => _selectedProds;

  
  double get total {
    _total = 0;
    _selectedProds.forEach((prod) { 
      _total += (prod.quantity ?? 1) * prod.precio;
    });

    return _total;
  }


  ProductoService(this._usuarioService) {
    initSelectedProds();
  }

  void initSelectedProds() async {
    final savedProds = await getSelected();
    _selectedProds = savedProds;
   // await clearBag();

    notifyListeners(); 
  }

  int getProdQuantity(String id)  {
    final prod = _selectedProds.firstWhereOrNull((element) => element.id == id);
    return prod?.quantity ?? 1;
  } 

  Future<void> selectProd(Producto prod) async {

    final prodExist = _selectedProds.indexWhere((element) => element.id == prod.id);

    if(prodExist != -1) {
      await updateProd(prod.quantity ?? 1, prod);
      return;
    }

    Fluttertoast.showToast(msg: 'Producto agregado');
    _selectedProds.add(prod);
    await saveSelected(productoListToJson(_selectedProds));
    notifyListeners();
  }

  Future updateProd(int qty, Producto prod) async {

    if((prod.quantity ?? 1) > 1) {
      final prodExist = _selectedProds.indexWhere((element) => element.id == prod.id);
      _selectedProds[prodExist].quantity = qty;
      
      print(_selectedProds[prodExist].quantity);

      await saveSelected(productoListToJson(_selectedProds));
    }

    notifyListeners();
  }

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

  Future saveSelected(List<Map<String, dynamic>> prods) async {
    return await _storage.write(key: _keyStorage, value: jsonEncode(prods));
  }

  Future<List<Producto>> getSelected() async {
    final selectedProds = await _storage.read(key: _keyStorage);
    if(selectedProds == null) return [];
    final decoded = jsonDecode(selectedProds);

    final prods = Producto.fromJsonList(decoded);

    return prods.toList;
  }
  
  Future<void> removeFromBag(String id) async {
    _selectedProds.removeWhere((prod) => prod.id == id );
    await saveSelected(productoListToJson(_selectedProds));
    notifyListeners();
  }

  Future<void> clearBag() async {
    await _storage.delete(key: _keyStorage);
  }

}