import 'package:flutter/material.dart';

import 'package:delivery_flutter/pages/delivery_orders_list_page.dart';
import 'package:delivery_flutter/pages/products_list_page.dart';
import 'package:delivery_flutter/pages/restaurant_orders_list_page.dart';
import 'package:delivery_flutter/pages/register_page.dart';
import 'package:delivery_flutter/pages/login_page.dart';
import 'package:delivery_flutter/pages/roles_page.dart';
import 'package:delivery_flutter/pages/profile_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'login': (_) => LoginPage(),
  'register': (_) => const RegisterPage(),
  'profile': (_) => ProfilePage(),
  'products': (_) => const ProductListPage(),
  'roles': (_) => const RolesPage(),
  'delivery/orders/list': (_) => const DeliveryOrdersList(),
  'restaurant/orders/list': (_) => const RestaurantOrdersList()
};