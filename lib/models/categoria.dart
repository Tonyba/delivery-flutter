// To parse this JSON data, do
//
//     final categoria = categoriaFromJson(jsonString);

import 'dart:convert';

Categoria categoriaFromJson(String str) => Categoria.fromJson(json.decode(str));

String categoriaToJson(Categoria data) => json.encode(data.toJson());

class Categoria {
    String id = '';
    String nombre = '';
    String descripcion = '';
    DateTime? createdAt;
    DateTime? updatedAt;

    List<Categoria> toList = [];

    Categoria({
        required this.id,
        required this.nombre,
        required this.descripcion,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: json["id"] is int ? json['id'].toString() : json['id'],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Categoria.fromJsonList(List<dynamic>? jsonList) {
      if(jsonList == null) return;

      jsonList.forEach((item) { 
        Categoria categoria = Categoria.fromJson(item);
        toList.add(categoria);
      });

    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "descripcion": descripcion,
        "created_at": createdAt != null ? createdAt?.toIso8601String() : '',
        "updated_at": updatedAt != null ? updatedAt?.toIso8601String() : '',
    };
}
