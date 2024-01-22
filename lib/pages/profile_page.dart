import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:delivery_flutter/models/authResponse.dart';
import 'package:delivery_flutter/models/usuario.dart';
import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:delivery_flutter/widgets/my_snackbar.dart';
import 'package:delivery_flutter/widgets/submit_btn.dart';


import 'package:delivery_flutter/theme/colors.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();



  XFile? pickedFile;

  File? imageFile;

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    UsuarioService usuarioService = Provider.of<UsuarioService>(context);

    nameController.text = usuarioService.usuario?.nombre ?? '';
    surnameController.text = usuarioService.usuario?.apellido ?? '';
    phoneController.text = usuarioService.usuario?.telefono ?? '';

    return Scaffold(
     appBar: _appbar(),
     body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: double.infinity,
             child: Column(
                children: [
                   const SizedBox(height: 50,),
                  _imageUserProfile(),
                  const SizedBox(height: 30,),
                  _inputs(),
                  
                ],
              ),
        ),
      ),
      bottomNavigationBar: _submitBtn(),
    );
  }

  _submitBtn() {
    UsuarioService usuarioService = Provider.of<UsuarioService>(context);
    return SubmitBtn(
          text: 'EDITAR PERFIL',
          onPressed: usuarioService.autenticando ? null : _updateUser,
      );
  }

  _appbar() {
    return AppBar(
      title: Text('Editar Perfil'),
    );
  }

  _updateUser() async {
      final usuarioService = Provider.of<UsuarioService>(context, listen: false);

      String surname = surnameController.text.trim();
      String name = nameController.text.trim(); 
      String phone = phoneController.text.trim();


      final processDialog = ProgressDialog(context: context);

      if(
         name.isEmpty || surname.isEmpty 
        || phone.isEmpty 
        
        ) {
          MySnackbar.show(context, 'Debes ingresar todos los campos');
          return;
      }


      processDialog.show(max: 100, msg: 'Espere un momento...');

      Usuario user = Usuario(
        nombre: name,
        apellido: surname,
        telefono: phone,
        roles: []
      );


    final registerOk = await usuarioService.updateWithImage(user, imageFile);
    registerOk?.listen((res) {
      processDialog.close();
      
      final responseApi = authResponseFromJson(res);
      Fluttertoast.showToast(msg: responseApi.msg ?? '');

      if(responseApi.success) {
        Navigator.pushNamedAndRemoveUntil(context, 'products', (route) => false);
      }
      
    });

    if(!context.mounted) return;
    // if(registerOk == true) {
 
    // } else {
    //   MySnackbar.show(context, 'error');
    // }
  }

  _imageUserProfile() {
    UsuarioService usuarioService = Provider.of<UsuarioService>(context);
    return GestureDetector(
      onTap: (){ _showAlertDialog(context);},
      child: Container(
        child: CircleAvatar(
          radius: 60,
          backgroundImage: imageFile != null 
            ? FileImage(imageFile!)
            : usuarioService.usuario?.imagen != null 
              ? NetworkImage(usuarioService.usuario!.imagen!) 
              : const AssetImage('assets/img/user_profile_2.png') as ImageProvider,
          backgroundColor: Colors.grey[200],
        ),
      ),
    );
  }

  _inputs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
           Container(
             margin: const EdgeInsets.symmetric(vertical: 10),
             decoration: BoxDecoration(
              color: MyColors.primaryOpacityColor,
              borderRadius: BorderRadius.circular(30)
             ),
            child:  TextField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: MyColors.primaryColor,),
                  hintText: 'Nombre',
              ),
              onChanged: (value) {
                setState(() {
                  nameController.text = value;
                });
              },
            ),
          ),
           Container(
             margin: const EdgeInsets.symmetric(vertical: 10),
             decoration: BoxDecoration(
              color: MyColors.primaryOpacityColor,
              borderRadius: BorderRadius.circular(30)
             ),
            child:  TextField(
                controller: surnameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline, color: MyColors.primaryColor,),
                  hintText: 'Apellido',
              ),
               onChanged: (value) {
                setState(() {
                  surnameController.text = value;
                });
              },
            ),
          ),
           Container(
             margin: const EdgeInsets.symmetric(vertical: 10),
             decoration: BoxDecoration(
              color: MyColors.primaryOpacityColor,
              borderRadius: BorderRadius.circular(30)
             ),
            child:  TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,  
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: MyColors.primaryColor,),
                  hintText: 'Telefono',
              ),
               onChanged: (value) {
                setState(() {
                  phoneController.text = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future _selectImage(ImageSource imageSource) async {
    pickedFile = await ImagePicker().pickImage(source: imageSource);
    if(pickedFile != null) {
      imageFile = File(pickedFile!.path);
    }
    if(!context.mounted) return;
    setState(() {
      
    });
    Navigator.pop(context);
  }

  _showAlertDialog(context) {


   Widget galleryButton = ElevatedButton(
      onPressed: () => _selectImage(ImageSource.gallery), 
      child: const Text('GALERIA', style: TextStyle(color: Colors.white),)

    );

   Widget cameraButton = ElevatedButton(
      onPressed: () => _selectImage(ImageSource.camera), 
      child: const Text('CAMARA', style: TextStyle(color: Colors.white))
    );

   AlertDialog alertDialog = AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Selecciona tu imagen'),
      actions: [
        galleryButton,
        cameraButton
      ],
    );

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return alertDialog;
      }
    );
  }
}