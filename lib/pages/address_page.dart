import 'package:delivery_flutter/models/direccion.dart';
import 'package:delivery_flutter/services/address_service.dart';
import 'package:delivery_flutter/services/pedido_service.dart';
import 'package:delivery_flutter/services/producto_service.dart';
import 'package:flutter/material.dart';
import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:delivery_flutter/theme/colors.dart';
import 'package:delivery_flutter/widgets/noData.dart';

import '../models/pedido.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});



  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {

  late DireccionService _direccionService;
  late UsuarioService _usuarioService;
  late ProductoService _productoService;
  late PedidoService _pedidoService;
  List<Direccion> addressList = [];
  int radioValue = 0;
  bool _submitting = false;

  var isCreated;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _usuarioService = Provider.of<UsuarioService>(context);
    _direccionService = DireccionService(_usuarioService);
    _productoService = Provider.of<ProductoService>(context);
    _pedidoService = PedidoService(_usuarioService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direcciones'),
        actions: [_iconAdd(context)],
      ),
      body: Stack(
        children: [
           Positioned(
            top: 0,
            child: _textSelectAddress()
          ),     
          Container(
            margin: const EdgeInsets.only(top: 50),
            child:  _listAddress(),
          )      
         
        ],
      ),
      bottomNavigationBar: _buttonAccept(),
    );
  }

  _buttonNewAddress(BuildContext context) {
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
           Navigator.pushNamed(context, 'client/address/create');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
          )
        ),
        child: const Text(
          'Nueva Direccion',
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
    );
  }

  _radioSelectorAddress(Direccion? direccion, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20) ,
      child: Column(
        children: [
          Row(
            children: [
              Radio(
                value: index, 
                groupValue: radioValue, 
                onChanged: _handleRadioValueChange
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    direccion?.direccion ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    direccion?.direccion2 ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            
            ],
          ),
          Divider(color: Colors.grey[400],)
        ],
      ),
    );
  }

  void _handleRadioValueChange(int? value) async {
    radioValue = value ?? 0;
    await _direccionService.saveSelectedAddress(addressList[value ?? 0]);

    

    setState(() {
      
    });
    print('Selected val: $radioValue');
  }

  Future<List<Direccion>> getAddress() async {
    addressList = await _direccionService.getUserAddresses(_usuarioService.usuario?.id ?? '', context);
    Direccion? a = await _direccionService.getLastSelectedAddress();

    if(a != null) {
      int index = addressList.indexWhere((ad) => ad.id == a.id);
      if(index != -1) {
        radioValue = index;
      }
    }

    return addressList;
  }

  _noAddress() {
    return Column(
      children: [
        const NoData(text: 'Agrega una nueva direccion'),
        _buttonNewAddress(context)
      ],
    );
  }

  _listAddress() {
    return FutureBuilder(
        future: getAddress(),
        builder: (_, snapshot) {
          if(snapshot.hasData) {
            if(snapshot.data!.isEmpty) return _noAddress();
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemBuilder: (_, index) {
                return _radioSelectorAddress(snapshot.data?[index], index);
              }
            );
          } else {
            return _noAddress();

          }

        },
      );
  }

  _buttonAccept() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: ElevatedButton(
        onPressed: _submitting ? null : () => _createOrder(),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          backgroundColor: MyColors.primaryColor
        ),
        child: const Text(
          'ACEPTAR',
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
    );
  }

  _createOrder() async {

    setState(() {
      _submitting = true;
    });
    

    Pedido pedido = Pedido(
      idUsuario: _usuarioService.usuario?.id ?? '', 
      idDireccion: addressList[radioValue].id, 
      productos: _productoService.selectedProds,
    );

    final resp = await _pedidoService.createOrder(pedido);

    if(resp == true) {
      Fluttertoast.showToast(msg: 'Pedido creado');
    }

    setState(() {
      _submitting = false;
    });
  
  }

  _textSelectAddress() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: const Text(
        'Elige donde recibir tus compras',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  _iconAdd(BuildContext context) {
    return IconButton(
      onPressed: () => _goToNewAddress(), 
      icon: const Icon(Icons.add, color: Colors.white,)
    );
  }

  _goToNewAddress() async {
    isCreated = await Navigator.pushNamed(context, 'client/address/create');

    if(isCreated != null) {
      if(isCreated) {
        setState(() {
          
        });
      }
    }
  }
}