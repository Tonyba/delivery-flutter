import 'package:delivery_flutter/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/producto.dart';
import 'package:delivery_flutter/services/producto_service.dart';

import 'package:delivery_flutter/widgets/noData.dart';


class CartPage extends StatefulWidget {

  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  List<Producto> _selectedProds = [];
  double total = 0.0;
  late ProductoService _prodService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productoService = Provider.of<ProductoService>(context);
    _selectedProds = productoService.selectedProds;
    total = productoService.total;
    _prodService = productoService;
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
        height: MediaQuery.of(context).size.height * 0.255,
        child: Column(
          children: [
            Divider(
              color: Colors.grey[400],
              endIndent: 30,
              indent: 30,
            ),
            _textTotalPrice(total),
            _confirmOrder()
          ],
        ),
      )
      : const SizedBox()
      ,
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
              _addOrRemoveItem(prod)
            ],
          ),
          const Spacer(),
          Column(
            children: [
              _textPrice(prod),
              _iconDelete(prod)
            ],
          )
        ],
      ),
    );
  }

  _iconDelete(Producto prod) {
    return IconButton(
      onPressed: () async {
        await _prodService.removeFromBag(prod.id ?? '');
      }, 
      icon: Icon(Icons.delete, color: MyColors.primaryColor,) 
    );
  }

  _textPrice(Producto prod) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Text(
        '${(prod.precio * (prod.quantity ?? 1)).toStringAsFixed(2)}\$',
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  _textTotalPrice(double total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total:',
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)}\$',
            style:  const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22
            ),
          ),
        ],
      ),
    );
  }

  _imageProduct(Producto prod) {
    return Container(
      width: 90,
      height: 90,
      padding: const EdgeInsets.all(10),
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

  Widget _addOrRemoveItem(Producto prod) {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            if (((prod.quantity ?? 1) - 1) < 1 ) return;
            prod.quantity = (prod.quantity ?? 1) - 1;
            await _prodService.updateProd(prod.quantity ?? 1 - 1, prod);
            setState(() {
             
            });
          },
          child: Container(
            padding:const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8)
              ),
              color: Colors.grey[200]
            ),
            child: const Text('-'),
          ),
        ),
        Container(
            padding:const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          color: Colors.grey[200],
          child: Text('${prod.quantity}'),
        ),
        GestureDetector(
          onTap: () async {
             prod.quantity = (prod.quantity ?? 1) + 1;             
             await _prodService.updateProd(prod.quantity ?? 1  + 1, prod);
             setState(()  { });
          },
          child: Container(
            padding:const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8)
              ),
              color: Colors.grey[200]
            ),
            child: const Text('+'),
          ),
        ),
      ],
    );
  }

  _confirmOrder() {
    return Container(
      margin: const EdgeInsets.only(right: 30,left: 30, top: 20, bottom: 30),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, 'client/address/list');
        },
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
                height: 50,
                child: const Text(
                  'CONTINUAR',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 80, top: 9),
                height: 30,
                child: const Icon(
                  Icons.check_circle, 
                  color: Colors.green, 
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
      title: const Text('Mi Orden'),
    );
  }
}