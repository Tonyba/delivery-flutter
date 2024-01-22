import 'package:delivery_flutter/widgets/my_snackbar.dart';
import 'package:delivery_flutter/widgets/submit_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'package:delivery_flutter/theme/colors.dart';
import 'package:delivery_flutter/services/usuario_service.dart';


class LoginPage extends StatelessWidget {

  LoginPage({super.key});
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
              _circleLogin(),
              _textLogin(),
              Column(
                children: [
                  _imageBanner(context),
                  _inputs(),
                  SubmitBtn(
                    text: 'Ingresar',
                    onPressed: usuarioService.autenticando ? null : () async {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      final loginOk = await usuarioService.login(email, password);
                      
                      if(!context.mounted) return;

                      if(loginOk == true) {
                        MySnackbar.show(context, 'logeado correctamente');
                        if(usuarioService.usuario!.roles.length > 1) {
                            Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
                        } else {
                            Navigator.pushNamedAndRemoveUntil(context, 'products', (route) => false);
                        }
                      } else {
                        MySnackbar.show(context, loginOk);
                      }
                    },
                  ),
                  _text(context)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _circleLogin() {
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

  _textLogin() {
      return const Positioned(
        top: 60,
        left: 25,
        child: Text('LOGIN', style: TextStyle(
          color: Colors.white, 
          fontSize: 22,
          fontWeight: FontWeight.bold
        ),
        )
      );
  }

  _imageBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 150, 
        bottom: MediaQuery.of(context).size.height * 0.07
      ),
      child: _lottieAnimation(),
    );

  }

  _lottieAnimation() {
    return Lottie.asset(
      'assets/json/delivery.json',
      width: 350,
      height: 200,
      fit: BoxFit.fill
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
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: MyColors.primaryColor,),
                  hintText: 'Contraseña',
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  _text(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta?',
          style: TextStyle(
            color: MyColors.primaryColor
          ),
        ),
        const SizedBox(width: 7,),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'register');
          },
          child: Text('Registrate', 
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: MyColors.primaryColor
            ),
          ),
        ),
      ],
    );
  }


}