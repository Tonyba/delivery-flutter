import 'dart:async';

import 'package:delivery_flutter/helpers/map_handler.dart';
import 'package:delivery_flutter/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  CameraPosition initPosition =
      const CameraPosition(target: LatLng(10.5452639, -71.6808962), zoom: 14);

  final Completer<GoogleMapController?> _mapController = Completer();

  late Position? _position;

  String addressName = '';
  late LatLng adressLatLng;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkGPS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SafeArea(child: Text('Ubica tu direccion en el mapa')),
      ),
      body: Stack(
        children: [
          _googleMaps(),
          Container(
            alignment: Alignment.center,
            child: _iconMyLocation(),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30),
            alignment: Alignment.topCenter,
            child: _cardAddress(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: _buttonAccept(),
          ),
        ],
      ),
    );
  }

  _selectRefPoint() {
    Map<String, dynamic> data = {
      'address': addressName,
      'lat': adressLatLng.latitude,
      'lng': adressLatLng.longitude
    };

    Navigator.pop(context, data);
  }

  _googleMaps() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: initPosition,
      onMapCreated: _onMapCreate,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      onCameraMove: (position) {
        initPosition = position;
      },
      onCameraIdle: () async {
        await setLocationDraggableInfo();
      },
    );
  }

  _buttonAccept() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 70),
      child: ElevatedButton(
        onPressed: () => _selectRefPoint(),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: MyColors.primaryColor),
        child: const Text(
          'SELECCIONAR ESTE PUNTO',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> setLocationDraggableInfo() async {
    double lat = initPosition!.target.latitude;
    double lng = initPosition!.target.longitude;

    List<Placemark> address = [];

    try {
      address = await placemarkFromCoordinates(lat, lng);
    } catch (e) {}

    if (address.isNotEmpty) {
      String? direccion = address[0].thoroughfare;
      String? street = address[0].subThoroughfare;
      String? city = address[0].locality;
      String? deparment = address[0].administrativeArea;
      // String? country = address[0].country;

      addressName = '$direccion #$street, $city, $deparment';
      adressLatLng = LatLng(lat, lng);

      setState(() {});
    }
  }

  _cardAddress() {
    return Container(
      child: Card(
        color: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            addressName,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  _onMapCreate(GoogleMapController controller) {
    if (_mapController.isCompleted) return;
    controller.setMapStyle(
        '[{"elementType":"geometry","stylers":[{"color":"#f5f5f5"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},{"featureType":"road.arterial","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9c9c9"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]}]');
    _mapController.complete(controller);
  }

  _iconMyLocation() {
    return Image.asset(
      'assets/img/my_location.png',
      width: 65,
      height: 65,
    );
  }

  Future<void> updateLocation() async {
    try {
      final currentPos = await LocationHandler.getCurrentPosition();

      if (currentPos != null) {
        _position = currentPos;
      } else {
        _position = await Geolocator.getLastKnownPosition();
      }

      if (_position != null) {
        await _animateCameraToPosition(
            _position!.latitude, _position!.longitude);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _checkGPS() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationServiceEnabled) {
      await updateLocation();
    } else {
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        await updateLocation();
      }
    }
  }

  Future _animateCameraToPosition(double lat, double lng) async {
    GoogleMapController? controller = await _mapController.future;

    if (controller != null) {
      await controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 13, bearing: 0)));
    }
  }
}
