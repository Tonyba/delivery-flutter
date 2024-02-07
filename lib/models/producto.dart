// To parse this JSON data, do
//
//     final producto = productoFromJson(jsonString);

import 'dart:convert';

Producto productoFromJson(String str) => Producto.fromJson(json.decode(str));

String productoToJson(Producto data) => json.encode(data.toJson());

List<Map<String, dynamic>> productoListToJson(List<Producto> data) => data.map((Producto e) => e.toJson()).toList();

class Producto {
    String? id;
    String nombre = '';
    String descripcion = '';
    String? imagen;
    double precio = 0.0;
    double? precioDescuento;
    int? idCategoria = 0;
    int? quantity = 1;
    List<String> imagenes = [];


    List<Producto> toList = [];

    Producto({
        this.id,
        required this.nombre,
        required this.descripcion,
        this.imagen,
        required this.precio,
        this.precioDescuento,
        required this.idCategoria,
        this.quantity = 1,
        required this.imagenes
    });

    factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json["id"] is int ? json['id']?.toString() : json['id'],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        imagen: json["imagen"],
        precio: json["precio"] is String ? double.parse(json['price']) : isInteger(json['precio']) ? json['precio']?.toDouble() : json['precio'],
        precioDescuento: json["precio_descuento"]?.toDouble(),
        idCategoria: json["id_categoria"] is String ? int.parse(json['id_categoria']) : json['id_categoria'],
        imagenes: json['imagenes'] != null ? List<String>.from(json["imagenes"].map((x) => x)) : [],
        quantity: json['quantity']
    );

    static bool isInteger(num? value) => value is int || value == value?.roundToDouble();

    Producto.fromJsonList(List<dynamic>? jsonList) {
      if(jsonList == null) return;
      jsonList.forEach((item) { 
        Producto prod = Producto.fromJson(item);
        toList.add(prod);
      });
    } 

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "descripcion": descripcion,
        "imagen": imagen,
        "precio": precio,
        "precio_descuento": precioDescuento,
        "id_categoria": idCategoria,
        "quantity": quantity,
        "imagenes": List<dynamic>.from(imagenes.map((x) => x)),
    };
}
