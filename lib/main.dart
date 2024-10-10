import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delivery_flutter/routes/routes.dart';
import 'package:delivery_flutter/theme/theme.dart';
import 'package:delivery_flutter/services/usuario_service.dart';

import 'package:delivery_flutter/services/categoria_service.dart';
import 'package:delivery_flutter/services/producto_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioService()),
        ChangeNotifierProvider(create: (_) => CategoriaService(null)),
        ChangeNotifierProvider(create: (_) => ProductoService(null)),
        ChangeNotifierProxyProvider<UsuarioService, CategoriaService>(
          update: (_, usuarioService, categoriaService) =>
              CategoriaService(usuarioService),
          create: (_) => CategoriaService(null),
        ),
        ChangeNotifierProxyProvider<UsuarioService, ProductoService>(
          update: (_, usuarioService, categoriaService) =>
              ProductoService(usuarioService),
          create: (_) => ProductoService(null),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Delivery App',
        routes: appRoutes,
        initialRoute: 'login',
        theme: appTheme,
        navigatorKey: navigatorKey,
      ),
    );
  }
}
