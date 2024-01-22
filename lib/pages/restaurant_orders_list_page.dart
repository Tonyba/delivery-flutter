import 'package:flutter/material.dart';
import 'package:delivery_flutter/widgets/drawer.dart';

class RestaurantOrdersList extends StatelessWidget {
  const RestaurantOrdersList({super.key});

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
        child: Text('restarurant'),
      ),
    );
  }
}