
import 'package:delivery_flutter/pages/product_page.dart';
import 'package:delivery_flutter/widgets/noData.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:delivery_flutter/models/producto.dart';
import 'package:delivery_flutter/services/producto_service.dart';
import 'package:delivery_flutter/models/categoria.dart';

import 'package:delivery_flutter/services/categoria_service.dart';
import 'package:delivery_flutter/theme/colors.dart';
import 'package:delivery_flutter/widgets/drawer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProductListPage extends StatelessWidget  {


  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {

    GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
    final categoriaService = Provider.of<CategoriaService>(context);
  
    return DefaultTabController(
      length: categoriaService.categorias.length,
      child: Scaffold(
          key: key,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(170),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              actions: [_shoppingBag(context)],
              flexibleSpace: Column(
                children: [
                  const SizedBox(height: 40,),
                  AppDrawer.menuDrawer(key),
                  const SizedBox(height: 40,),
                  _textFieldSearch(),
                ],
              ),
              bottom: _tabs(context)
            ),
            
          ),
        
          drawer: const AppDrawer(),
          body: TabBarView(
            children: categoriaService.categorias.map((Categoria cat) {
              return FutureBuilder(
                future: _getProds(context, cat.id),
                builder: (_, snapshot) {
                  if(snapshot.hasData) {
                    return AlignedGridView.count(
                      crossAxisCount: 2,
                      itemCount: snapshot.data?.length ?? 0,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      itemBuilder: (context, index) {
                        return snapshot.data != null ? _cardProduct(snapshot.data![index], context) : const SizedBox();
                      },
                    );
                  } else {
                    return const NoData(text: 'No se encontraron productos');
                  }

                },
              );
            }).toList(),
          )
        ),
    );

  }


  Future<List<Producto>?> _getProds(BuildContext context, String catId) async {
    final productoService = Provider.of<ProductoService>(context);
    return await productoService.findByCat(catId);

  } 


  _tabs(context) {
    final categoriaService = Provider.of<CategoriaService>(context);

    return TabBar(
              tabAlignment: TabAlignment.start ,
              indicatorColor: MyColors.primaryColor,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[400],
              isScrollable: true,
              tabs:  List<Widget>.generate(categoriaService.categorias.length, (index) {
                return Tab(
                  child: Text(categoriaService.categorias[index].nombre),
                );
              })
     );
  }

  _textFieldSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
          hintText: 'Buscar',
          hintStyle: TextStyle(color: Colors.grey[500]),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey[300]!
            )
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey[300]!
            )
          )
        ),
      ),
    );
  }

 void openBottomSheet(BuildContext context, Producto prod) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(heightFactor: 0.9, child: ProductPage(producto: prod,))
    );
  }


  Widget _cardProduct(Producto prod, context) {
    return GestureDetector(
      onTap: () {
        openBottomSheet(context, prod);
      },
      child: Container(
        height: 250,
        child: Card(
          color: Colors.white,
          elevation: 0,
          child: Material(
            elevation: 3,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: MyColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        topRight: Radius.circular(20)
                      )
                    ),
                    child: const Icon(Icons.add, color: Colors.white,),
                  )
                  
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      margin: const EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width * 0.45,
                      padding: const EdgeInsets.all(20),
                      child: FadeInImage(
                        placeholder: const AssetImage('assets/img/no-image.png'), 
                        image:  NetworkImage(prod.imagen ?? ''),
                        fit: BoxFit.contain,
                        fadeInDuration: const Duration(milliseconds: 50),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        prod.nombre,
                        style: const TextStyle(
                          fontSize: 15,
                          overflow: TextOverflow.clip
                        ),
                      ),    
                    ),
                    Container(
                      margin:const  EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '${prod.precio}\$',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    
                    )
            
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _shoppingBag(context) {
    return  GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'cart');
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: const  Icon(
              Icons.shopping_bag_outlined, 
              color: Colors.black,
            ),
          ),
          Positioned(
            right: 16,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(30))
              ),
            )
          ),
      
        ],
      ),
    );
  }
}