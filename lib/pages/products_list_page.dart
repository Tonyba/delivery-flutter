import 'package:delivery_flutter/widgets/drawer.dart';
import 'package:flutter/material.dart';

class ProductListPage extends StatelessWidget {

const ProductListPage({super.key});
  @override
  Widget build(BuildContext context) {

    GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  
    return Scaffold(
      key: key,
      appBar: AppBar(
        leading: AppDrawer.menuDrawer(key),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Text('products'),
      ),
    );
  }


}