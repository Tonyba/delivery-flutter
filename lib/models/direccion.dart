// To parse this JSON data, do
//
//     final direccion = direccionFromJson(jsonString);

import 'dart:convert';

Direccion direccionFromJson(String str) => Direccion.fromJson(json.decode(str));

String direccionToJson(Direccion data) => json.encode(data.toJson());

class Direccion {
    late String id;
    late String? idUsuario;
    late String direccion;
    late String? direccion2;
    late double lat;
    late double lng;

    List<Direccion> toList = [];

    Direccion({
        required this.id,
        required this.idUsuario,
        required this.direccion,
        this.direccion2,
        required this.lat,
        required this.lng,
    });

    factory Direccion.fromJson(Map<String, dynamic> json) => Direccion(
        id: json["id"] is int ? json['id'].toString() : json['id'],
        idUsuario: json["id_usuario"] is int ? json['id_usuario'].toString() : json['id_usuario'],
        direccion: json["direccion"],
        direccion2: json["direccion2"],
        lat: json['lat'] is String ? double.parse(json["lat"]) : json["lat"],
        lng: json["lng"] is String ? double.parse(json["lng"]) : json["lng"],
    );

    Direccion.fromJsonList(List<dynamic>? jsonList) {
      if(jsonList == null) return;
      jsonList.forEach((element) { 
        Direccion direccion = Direccion.fromJson(element);
        toList.add(direccion);
      });
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "id_usuario": idUsuario,
        "direccion": direccion,
        "direccion2": direccion2,
        "lat": lat,
        "lng": lng,
    };
}
