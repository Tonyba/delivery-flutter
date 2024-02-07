import 'package:delivery_flutter/models/direccion.dart';
import 'package:delivery_flutter/pages/map_page.dart';
import 'package:delivery_flutter/services/address_service.dart';
import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:delivery_flutter/widgets/my_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../theme/colors.dart';

class CreateAddressPage extends StatefulWidget {
  const CreateAddressPage({super.key});



  @override
  State<CreateAddressPage> createState() => _CreateAddressPageState();
}

class _CreateAddressPageState extends State<CreateAddressPage> {

  static TextEditingController refPositionController = TextEditingController();
  static TextEditingController addressController = TextEditingController();
  static TextEditingController address2Controller = TextEditingController();
  static late Map<String, dynamic>? refPoint;

  late UsuarioService _usuarioService;

  late DireccionService _direccionService;


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final provider = Provider.of<UsuarioService>(context);
    _direccionService = DireccionService(provider);
    _usuarioService = provider;
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   refPositionController.dispose();
  //   address2Controller.dispose();
  //   addressController.dispose();
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva direccion'),
      ),
      body: Column(
        children: [
          _textCompleteData(),
          _TextFieldAddress(),
          _TextFieldAddress2(),
          _TextFieldPointRef()
        ]
      ),
      bottomNavigationBar: _buttonAccept(),
    );
  }


  _createAddress() async {
    String address = addressController.text.trim();
    String address2 = address2Controller.text.trim();
    double lat = refPoint?['lat'] ?? 0;
    double lng = refPoint?['lng'] ?? 0;

    if(address.isEmpty) {
      MySnackbar.show(context, 'La direccion es obligatoria');
      return;
    }

    if(refPositionController.text.trim().isEmpty) {
      MySnackbar.show(context, 'El punto de referencia es obligatorio');
      return;
    }

    Direccion newAddress = Direccion(
      id: '', 
      idUsuario: _usuarioService.usuario?.id ?? '', 
      direccion: address, 
      direccion2: address2, 
      lat: lat, 
      lng: lng
    );
    
    final resp = await _direccionService.createAddress(newAddress, context);

    if(!context.mounted) return;

    if(resp['success'] == true) {
      newAddress.id = resp['data'];

      await _direccionService.saveSelectedAddress(newAddress);

      Fluttertoast.showToast(msg: 'Direccion agregada correctamente');
      Navigator.pop(context, true);
    } else {
      MySnackbar.show(context, resp);
    }

  }

  _textCompleteData() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: const Text(
        'Completa estos datos',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  _TextFieldAddress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: addressController,
        decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Colors.grey
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: MyColors.primaryColor
            ),
          ),
          labelText: 'Direccion',
          suffixIcon: Icon(
            Icons.location_on,
            color: MyColors.primaryColor,
            
          )
        ),
      ),
    );
    
  }

  _TextFieldAddress2() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: address2Controller,
        decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Colors.grey
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: MyColors.primaryColor
            ),
          ),
          labelText: 'Barrio',
          suffixIcon: Icon(
            Icons.location_city,
            color: MyColors.primaryColor,
          )
        ),
      ),
    );
    
  }

  _openMap() async {
    refPoint = await showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const FractionallySizedBox(heightFactor: 1, child: MapPage(),)
    );

    if(refPoint != null) {
      refPositionController.text = refPoint?['address'];
      setState(() {
        
      });
    }
  }

  _TextFieldPointRef() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: refPositionController,
        onTap: () => _openMap(),
        autofocus: false,
        focusNode: AlwaydisabledFocus(),
        decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Colors.grey
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: MyColors.primaryColor
            ),
          ),
          labelText: 'Punto de referencia',
          suffixIcon: Icon(
            Icons.map,
            color: MyColors.primaryColor,
          )
        ),
      ),
    );
    
  }

    _buttonAccept() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: ElevatedButton(
        onPressed: () => _createAddress(),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          backgroundColor: MyColors.primaryColor
        ),
        child: const Text(
          'CREAR DIRECCION',
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
    );
  }
}

class AlwaydisabledFocus extends FocusNode {
  @override
  bool get hasFocus => false;
}