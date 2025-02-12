import 'package:flutter/material.dart';

import 'package:delivery_flutter/pages/delivery_orders_list_page.dart';
import 'package:delivery_flutter/pages/products_list_page.dart';
import 'package:delivery_flutter/pages/restaurant_orders_list_page.dart';
import 'package:delivery_flutter/pages/register_page.dart';
import 'package:delivery_flutter/pages/login_page.dart';
import 'package:delivery_flutter/pages/roles_page.dart';
import 'package:delivery_flutter/pages/profile_page.dart';
import 'package:delivery_flutter/pages/category_create_page.dart';
import 'package:delivery_flutter/pages/category_list_page.dart';
import 'package:delivery_flutter/pages/address_page.dart';
import 'package:delivery_flutter/pages/cart_page.dart';
import 'package:delivery_flutter/pages/create_address_page.dart';
import 'package:delivery_flutter/pages/orders_list_page.dart';
import 'package:delivery_flutter/pages/product_create_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'login': (_) => LoginPage(),
  'register': (_) => const RegisterPage(),
  'profile': (_) => ProfilePage(),
  'products': (_) => const ProductListPage(),
  'roles': (_) => const RolesPage(),
  'cart': (_) => const CartPage(),
  'orders': (_) => const OrdersListPage(),
  'delivery/orders/list': (_) => const DeliveryOrdersList(),
  'restaurant/orders/list': (_) => const RestaurantOrdersList(),
  'restaurant/category/create': (_) => CategoryCreatePage(),
  'restaurant/category/list': (_) => const CategoryListPage(),
  'restaurant/product/create': (_) => const ProductCreatePage(),
  'client/address/create': (_) => const CreateAddressPage(),
  'client/address/list': (_) => const AddressPage(),
};
