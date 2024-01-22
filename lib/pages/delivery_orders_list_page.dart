import 'package:flutter/material.dart';
import 'package:delivery_flutter/widgets/drawer.dart';

class DeliveryOrdersList extends StatelessWidget {
  const DeliveryOrdersList({super.key});

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
        child: Text('delivery'),
      ),
    );

  }
}