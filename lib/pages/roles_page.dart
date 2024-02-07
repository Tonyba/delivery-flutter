import 'package:delivery_flutter/models/rol.dart';
import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  static late UsuarioService _usuarioService;

  @override
  Widget build(BuildContext context) {

    _usuarioService = Provider.of<UsuarioService>(context);

    final isEmpty = _usuarioService.usuario?.roles!.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona un rol'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.14),
        child: ListView(
          children: 
             isEmpty != null && !isEmpty ? _usuarioService.usuario!.roles!.map(
              (rol) => _cardRol(context, rol)
              ).toList() 
              : [] 
        ),
      ),
    );
  }


  Widget _cardRol(BuildContext context, Rol rol) {

  return GestureDetector(
    onTap: () {
      Navigator.pushNamedAndRemoveUntil(context, rol.ruta, (route) => false);
    },
    child: Column(
      children: [
        Container(
          height: 100,
          child: FadeInImage(
            placeholder: const AssetImage('assets/img/no-image.png'), 
            image: rol.imagen != null 
            ? NetworkImage(rol.imagen!) 
            : const AssetImage('assets/img/no-image.png') as ImageProvider,
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 50),
          ),
        ),
        const SizedBox(height: 15,),
        Text(
          rol.nombre,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black
          ),
        ),
        const SizedBox(height: 15,),
      ],
    ),
  );
}

}

