// To parse this JSON data, do
//
//     final pedido = pedidoFromJson(jsonString);

import 'dart:convert';

import 'package:delivery_flutter/models/direccion.dart';
import 'package:delivery_flutter/models/producto.dart';
import 'package:delivery_flutter/models/usuario.dart';

Pedido pedidoFromJson(String str) => Pedido.fromJson(json.decode(str));

String pedidoToJson(Pedido data) => json.encode(data.toJson());

class Pedido {
    String? id;
    String? idUsuario;
    String? idRepartidor;
    String? idDireccion;
    String? estado;
    int? timestamp;
    double? total;
    double? lat;
    double? lng;
    Usuario? cliente;
    Direccion? direccion;
    Usuario? repartidor;

    List<Producto>? productos = [];
    List<Pedido> toList = [];

    Pedido({
        this.id,
        required this.idUsuario,
        this.idRepartidor,
        required this.idDireccion,
        this.estado,
        this.timestamp,
        this.total,
        this.lat,
        this.lng,
        this.productos,
        this.cliente,
        this.direccion,
        this.repartidor
    });

    factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
        id: json["id"] is int ? json['id'].toString() : json['id'],
        idUsuario: json["id_usuario"] is int ? json['id_usuario'].toString() : json['id_usuario'],
        idRepartidor: json["id_repartidor"] is int ? json['id_repartidor'].toString() : json['id_repartidor'],
        idDireccion: json["id_direccion"] is int ? json['id_direccion'].toString() : json['id_direccion'],
        estado: json["estado"],
        timestamp: json["timestamp"] is String ? int.parse(json["timestamp"]) : json['timestamp'],
        total: json["total"]?.toDouble(),
        lat: json["lat"] is String ? double.parse(json["lat"]) : json['lat'],
        lng: json["lng"] is String ? double.parse(json["lng"]) : json['lng'],
        productos: json['productos'] is List ? List<Map<String, dynamic>>.from(json['productos']).map((prod) => Producto.fromJson(prod)).toList() : [],
        cliente: json['cliente'] != null ? Usuario.fromJson(json['cliente']) : json['cliente'],
        repartidor: json['repartidor'] != null ? Usuario.fromJson(json['repartidor']) : json['repartidor'],
        direccion: json['direccion'] != null ? Direccion.fromJson(json['direccion']) : json['direccion']
    );

    Pedido.fromJsonList(List<dynamic>? jsonList) {
      if(jsonList == null) return;

      jsonList.forEach((order) { 
        Pedido pedido = Pedido.fromJson(order);
        toList.add(pedido);
      });
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "id_usuario": idUsuario,
        "id_repartidor": idRepartidor,
        "id_direccion": idDireccion,
        "estado": estado,
        "timestamp": timestamp,
        "total": total,
        "lat": lat,
        "lng": lng,
        "productos": productos,
        "cliente": cliente,
        "direccion": direccion,
        "repartidor": repartidor
    };
}
