import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import 'package:delivery_flutter/models/authResponse.dart';
import 'package:delivery_flutter/models/usuario.dart';
import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:delivery_flutter/widgets/my_snackbar.dart';
import 'package:delivery_flutter/widgets/submit_btn.dart';


import 'package:delivery_flutter/theme/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  XFile? pickedFile;
  File? imageFile;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final usuarioService = Provider.of<UsuarioService>(context);

    return Scaffold(
     body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: double.infinity,
          child: Stack(
            children: [
              _circleRegister(),
              _iconBack(),
              _textRegister(),
              Column(
                children: [
                  _imageUserProfile(),
                  const SizedBox(height: 30,),
                  _inputs(),
                  SubmitBtn(
                    text: 'REGISTRARSE',
                    onPressed: usuarioService.autenticando ? null : _registerUser,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  _registerUser() async {
      final usuarioService = Provider.of<UsuarioService>(context, listen: false);

      String email = emailController.text.trim();
      String surname = surnameController.text.trim();
      String name = nameController.text.trim(); 
      String phone = phoneController.text.trim();
      String password = passController.text.trim();
      String confirmPass = confirmPassController.text.trim();

      final processDialog = ProgressDialog(context: context);

      if(
        email.isEmpty || name.isEmpty || surname.isEmpty 
        || phone.isEmpty || password.isEmpty || confirmPass.isEmpty
        
        ) {
          MySnackbar.show(context, 'Debes ingresar todos los campos');
          return;
      }

      if(confirmPass != password) {
        MySnackbar.show(context, 'Las contraseñas no coinciden');
        return;
      }

      if(password.length < 6) {
        MySnackbar.show(context, 'La contraseña debe tener al menos 6 caracteres');
        return;
      }

      if(imageFile == null) {
        MySnackbar.show(context, 'Por favor seleccione una imagen');
        return;
      }

      processDialog.show(max: 100, msg: 'Espere un momento...');

      Usuario user = Usuario(
        correo: email,
        nombre: name,
        apellido: surname,
        telefono: phone,
        password: password,
        roles: []
      );


    final registerOk = await usuarioService.registerWithImage(user, imageFile);
    
    registerOk?.listen((res) {
      processDialog.close();
      
      final responseApi = authResponseFromJson(res);

      if(responseApi.success) {
        MySnackbar.show(context, 'Registro completado correctamente');
        usuarioService.usuario = responseApi.usuario;
        Navigator.pushNamedAndRemoveUntil(context, 'products', (route) => false);
      } else {
        MySnackbar.show(context, responseApi.msg ?? '');
      }
      
    });

    if(!context.mounted) return;
    // if(registerOk == true) {
 
    // } else {
    //   MySnackbar.show(context, 'error');
    // }
  }

  _circleRegister() {
    return Positioned(
      top: -80,
      left: -100,
      child: Container(
        width: 240,
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: MyColors.primaryColor,
        ),
      ),
    );
  }

  _iconBack() {
    return Positioned(
      top: 48,
      left: -7,
      child: IconButton(
        onPressed: (){
          Navigator.pop(context);
        }, 
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white,)
      ),
    );
  }

  _textRegister() {
      return Positioned(
        top: 60,
        left: 25,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Text('REGISTRO', style: TextStyle(
            color: Colors.white, 
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
          ),
        )
      );
  }

  _imageUserProfile() {
    return GestureDetector(
      onTap: (){ _showAlertDialog(context);},
      child: Container(
        margin: const EdgeInsets.only(top: 150),
        child: CircleAvatar(
          radius: 60,
          backgroundImage: imageFile != null 
          ? FileImage(imageFile!)
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
             child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: MyColors.primaryColor,),
                  hintText: 'Correo electronico'
              ),
            ),
           ),
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
            ),
          ),
           Container(
             margin: const EdgeInsets.symmetric(vertical: 10),
             decoration: BoxDecoration(
              color: MyColors.primaryOpacityColor,
              borderRadius: BorderRadius.circular(30)
             ),
            child:  TextField(
                controller: passController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: MyColors.primaryColor,),
                  hintText: 'Contraseña',
              ),
            ),
          ),  
           Container(
             margin: const EdgeInsets.symmetric(vertical: 10),
             decoration: BoxDecoration(
              color: MyColors.primaryOpacityColor,
              borderRadius: BorderRadius.circular(30)
             ),
            child:  TextField(
                controller: confirmPassController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_open, color: MyColors.primaryColor,),
                  hintText: 'Confirmar Contraseña',
              ),
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