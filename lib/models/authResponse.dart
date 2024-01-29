import 'dart:convert';

import 'package:delivery_flutter/models/usuario.dart';

AuthResponse authResponseFromJson(String str) => AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
    bool success;
    Usuario? usuario;
    String? msg;

    AuthResponse({
        required this.success,
        required this.usuario,
        required this.msg,
    });

    factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        success: json["success"] != null ? true : false,
        usuario: json['usuario'] != null ? Usuario.fromJson(json["usuario"]) : null,
        msg:  json["msg"]
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "usuario": usuario?.toJson(),
    };
}