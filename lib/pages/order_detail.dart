import 'package:delivery_flutter/helpers/relative_time_util.dart';
import 'package:delivery_flutter/models/pedido.dart';
import 'package:delivery_flutter/models/usuario.dart';
import 'package:delivery_flutter/services/pedido_service.dart';
import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:delivery_flutter/theme/colors.dart';
import 'package:delivery_flutter/widgets/noData.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../models/producto.dart';

class OrderDetail extends StatefulWidget {

  final Pedido pedido;
  const OrderDetail({super.key, required this.pedido});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {

  double total = 0.0;
  late PedidoService _pedidoService;
  late UsuarioService _usuarioService;
  List<Producto> _selectedProds = [];

  String? _idRepartidor;

  List<Usuario> usuarios = [];

  bool _submitting = false;


  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _usuarioService = Provider.of<UsuarioService>(context);
    total = _selectedProds.fold(0.0, (previousValue, prod) => previousValue + ((prod.quantity ?? 1 ) * prod.precio) );
    _pedidoService = PedidoService(_usuarioService);
    
    usuarios = await _usuarioService.getRepartidores();
    usuarios.removeWhere((user) => user.id == _usuarioService.usuario?.id);

    setState(() {
      
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedProds = widget.pedido.productos ?? [];
  }


  @override
  Widget build(BuildContext context) {  

    return Scaffold(
      appBar:  _appBar(),
      body: _selectedProds.isNotEmpty 
      ? ListView(
        children: _selectedProds.map((Producto prod){
          return _cardProduct(prod);
        }).toList()
      ) :const Center(child:  NoData(text: 'Ningun producto agregado')),
      bottomNavigationBar: _selectedProds.isNotEmpty 
      ? Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Divider(
                color: Colors.grey[400],
                endIndent: 30,
                indent: 30,
              ),
               _adminWidget(),
              _usuarioService.selectedRole == 'RESTAURANTE' && widget.pedido.estado == 'PAGADO' ?   _confirmOrder() : const SizedBox(), 
            ],
          ),
        ),
      )
      : const SizedBox()
      ,
    );
  }


  _repartidorData() {
    return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                width: 40,
                height: 40,
                child: FadeInImage(
                  image: widget.pedido.repartidor?.imagen != null
                    ? NetworkImage(widget.pedido.repartidor!.imagen!)
                    : const AssetImage('assets/img/no-image.png') as ImageProvider,
                  placeholder: const AssetImage('assets/img/no-image.png') ,
                ),
              ),
              Text('${widget.pedido.repartidor?.nombre} ${widget.pedido.repartidor?.apellido}')
            ]
        );
  }

  
  List<DropdownMenuItem<String>> _dropdownItems(List<Usuario> users) {
    List<DropdownMenuItem<String>> list = [];

    users.forEach((user) { 
      list.add(
        DropdownMenuItem(
          value: user.id,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                child: FadeInImage(
                  image: user.imagen != null
                    ? NetworkImage(user.imagen!)
                    : const AssetImage('assets/img/no-image.png') as ImageProvider,
                  placeholder: const AssetImage('assets/img/no-image.png') ,
                ),
              ),
              const SizedBox(width: 5,),
              Text('${user.nombre} ${user.apellido}'),
            ],
          ),
        )
      );
    });

    return list;
  }
 
  _dropdownUser(List<Usuario> users) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Material(
        elevation: 2,
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        child: Container(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton(
                  underline: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_drop_down_circle,
                      color: MyColors.primaryColor,
                    ),
                  ),
                  elevation: 3,
                  isExpanded: true,
                  hint: const Text('Repartidores', style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16
                  ),),
                  onChanged: (e){
                    setState(() {
                      _idRepartidor = e;
                    });
                  },
                  items: _dropdownItems(users),
                  value: _idRepartidor,
                
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _adminWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         _textDesc(),
        widget.pedido.repartidor?.nombre != null ?  _repartidorData() : const SizedBox(),
        _usuarioService.selectedRole == 'RESTAURANTE' && widget.pedido.estado == 'PAGADO' ? _dropdownUser(usuarios) : const SizedBox(),
          const SizedBox(height: 10,),
        _textData('Cliente:', '${widget.pedido.cliente?.nombre} ${widget.pedido.cliente?.apellido} feqfqwe fqwfwq fwqfwqfwqfwqfwqfwqf'),
        _textData('Entregar En:', '${widget.pedido.direccion?.direccion} ${widget.pedido.direccion?.direccion2}'),
        _textData('Fecha de pedido;', RelativeTimeUtil.getRelativeTime(widget.pedido.timestamp ?? 0)),
      ],
    );
  }

  _textDesc() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        widget.pedido.estado == 'PAGADO' 
          ?
           _usuarioService.selectedRole == 'RESTAURANTE' ? 'Asignar Repartidor' : ''
           
          : 'Repartidor Asignado' 
        ,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: MyColors.primaryColor,
          fontSize: 16
        ),
      ),
    );
  }

  _textData(String title, String content){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child:  ListTile(
        title: Text(title),
        subtitle: Text(content, maxLines: 2,),
      )
      
    );
  }

  Widget _cardProduct(Producto prod) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _imageProduct(prod),
          const SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prod.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 10,),
              Text('Cantidad: ${prod.quantity}',
              style: const TextStyle(
                fontSize: 13
                )
              )
            ],
          ),
          
        ],
      ),
    );
  }



  _textTotalPrice(double total) {
    return Container(
      margin: const EdgeInsets.only(top: 5, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total: ',
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)}\$',
            style:  const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18
            ),
          ),
        ],
      ),
    );
  }

  _imageProduct(Producto prod) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.grey[200]
      ),
      child: FadeInImage(
        fit: BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 50),
        placeholder: const AssetImage('assets/img/no-image.png'), 
        image: NetworkImage(prod.imagen!)
      ),
    );
  }

  _dispatchPedido() async {

      if(_idRepartidor != null) {
      setState(() {
        _submitting = true;
      });

      widget.pedido.idRepartidor = _idRepartidor;

      final resp = await _pedidoService.despacharPedido(widget.pedido);

      if(resp == true) {
        Fluttertoast.showToast(msg: 'Pedido Despachado', toastLength: Toast.LENGTH_LONG);
        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(msg: resp);
      }

      setState(() {
        _submitting = false;
      });
    } else {
      Fluttertoast.showToast(msg: 'Selecciona un Repartidor');
    }

    


  }

  _confirmOrder() {
    return Container(
      margin: const EdgeInsets.only(right: 30,left: 30, top: 15, bottom: 20),
      child: ElevatedButton(
        onPressed: _submitting ? null : () => _dispatchPedido(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          )
        ),
        child: Stack(
          children: [
            Align(
              child: Container(
                alignment: Alignment.center,
                height: 40,
                child: const Text( 
                  'DESPACHAR ORDEN',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 50, top: 4),
                height: 30,
                child: const Icon(
                  Icons.check_circle, 
                  color: Colors.white, 
                  size: 30
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  _appBar() {
    return AppBar(
      title: Text('Orden #${widget.pedido.id}'),
      actions: [_textTotalPrice(total)],
    );
  }
}