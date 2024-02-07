import 'dart:convert';

import 'package:delivery_flutter/models/rol.dart';

Usuario usuarioFromJson(String str) => Usuario.fromJson(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
    String? id;
    String? nombre;
    String? apellido;
    String? correo;
    String? telefono;
    String? imagen;
    String? password;
    bool? disponible;
    String? sessionToken;
    List<Rol>? roles = [];

    List<Usuario> toList = [];
    
    Usuario({
        this.id = '',
        this.nombre = '',
        this.apellido = '',
        this.correo = '',
        this.telefono = '',
        this.imagen,
        this.password = '',
        this.disponible = false,
        this.sessionToken ,
        required this.roles
    });

    factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json["id"] is int ? json['id'].toString() : json['id'],
        nombre: json["nombre"],
        apellido: json["apellido"],
        correo: json["correo"],
        telefono: json["telefono"],
        imagen: json["imagen"],
        disponible: json["disponible"] == null ? null : json['disponible'],
        sessionToken: json["session_token"],
        roles: json['roles'] == null ? [] : List<Rol>.from(json['roles'].map( (model) => Rol.fromJson(model) ))
    );

    Usuario.fromJsonList(List<dynamic>? jsonList) {
      if(jsonList == null) return;

      jsonList.forEach((item) { 
        Usuario usuario = Usuario.fromJson(item);
        toList.add(usuario);
      });

    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "apellido": apellido,
        "correo": correo,
        "telefono": telefono,
        "imagen": imagen,
        "password": password,
        "disponible": disponible,
        "session_token": sessionToken,
        "roles": roles
    };
}
