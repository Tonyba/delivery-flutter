import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delivery_flutter/routes/routes.dart';
import 'package:delivery_flutter/theme/theme.dart';
import 'package:delivery_flutter/services/usuario_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Delivery App',
        routes: appRoutes,
        initialRoute: 'products',
        theme: appTheme,
      ),
    );
  }
}

