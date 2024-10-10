import 'package:delivery_flutter/main.dart';
import 'package:delivery_flutter/services/producto_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'package:delivery_flutter/theme/colors.dart';
import 'package:delivery_flutter/models/producto.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatefulWidget {
  final Producto producto;

  const ProductPage({super.key, required this.producto});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int cantidad = 1;
  final _productService =
      Provider.of<ProductoService>(navigatorKey.currentContext!);

  @override
  void initState() {
    // TODO: implement initState
    final prodInCart = _productService.getProduct(widget.producto);

    if (prodInCart != null) {
      int current = prodInCart.quantity ?? 1;
      current++;
      widget.producto.quantity = current;
    } else {
      widget.producto.quantity ??= cantidad;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prodImgs = [widget.producto.imagen!, ...widget.producto.imagenes];

    return Scaffold(
      body: Column(
        children: [
          _imageSlideShow(context, prodImgs),
          _textName(),
          _textDescription(),
          const Spacer(),
          _addOrRemoveItem(),
          _standardDelivery(),
          _buttonShopingBag()
        ],
      ),
    );
  }

  _buttonShopingBag() {
    return Container(
      margin: const EdgeInsets.only(right: 30, left: 30, top: 20, bottom: 30),
      child: ElevatedButton(
        onPressed: () => _addProduct(),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Stack(
          children: [
            Align(
              child: Container(
                alignment: Alignment.center,
                height: 50,
                child: const Text(
                  'AGREGAR AL CARRITO',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  margin: const EdgeInsets.only(left: 50, top: 6),
                  height: 30,
                  child: Image.asset(
                    'assets/img/bag.png',
                  )),
            )
          ],
        ),
      ),
    );
  }

  _standardDelivery() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Image.asset(
            'assets/img/delivery.png',
            height: 17,
          ),
          const SizedBox(
            width: 7,
          ),
          const Text(
            'Envio estandar',
            style: TextStyle(fontSize: 12, color: Colors.green),
          )
        ],
      ),
    );
  }

  _addOrRemoveItem() {
    return Container(
      margin: const EdgeInsets.only(left: 19, right: 30),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                cantidad++;
                int currentQuantity = widget.producto.quantity ?? 1;
                currentQuantity++;

                widget.producto.quantity = currentQuantity;

                print('new qty');
                print(widget.producto.quantity);
              });
            },
            icon: const Icon(
              Icons.add_circle_outline,
              size: 30,
            ),
            color: Colors.grey,
          ),
          Text(
            '$cantidad',
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (cantidad - 1 < 1) return;
                cantidad--;

                int currentQuantity = widget.producto.quantity ?? 1;
                currentQuantity--;

                widget.producto.quantity = currentQuantity;

                print('new qty');
                print(widget.producto.quantity);
              });
            },
            icon: const Icon(
              Icons.remove_circle_outline,
              size: 30,
            ),
            color: Colors.grey,
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Text(
              '${(widget.producto.precio * cantidad).toStringAsFixed(2)}\$',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  _textName() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
      child: Text(
        widget.producto.nombre,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  _textDescription() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 15, left: 30, right: 30),
      child: Text(
        widget.producto.descripcion,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }

  _imageSlideShow(context, List<String> imgs) {
    return Stack(
      children: [
        ImageSlideshow(
            width: double.infinity,
            initialPage: 0,
            indicatorColor: MyColors.primaryColor,
            indicatorBackgroundColor: Colors.grey,
            height: MediaQuery.of(context).size.height * 0.4,
            autoPlayInterval: 30000,
            children: imgs
                .map((img) => FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: const AssetImage('assets/img/no-image.png'),
                    image: NetworkImage(img)))
                .toList()),
        Positioned(
            left: 10,
            top: 5,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios, color: MyColors.primaryColor),
            ))
      ],
    );
  }

  _addProduct() async {
    await _productService.selectProd(widget.producto);
    Navigator.pushNamedAndRemoveUntil(
        context, 'cart', (Route<dynamic> route) => false);
  }
}
