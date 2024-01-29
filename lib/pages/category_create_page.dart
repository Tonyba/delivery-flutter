import 'package:delivery_flutter/services/categoria_service.dart';
import 'package:delivery_flutter/widgets/my_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/colors.dart';
import 'package:delivery_flutter/widgets/submit_btn.dart';

class CategoryCreatePage extends StatelessWidget {

  CategoryCreatePage({super.key});

  final nameController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: _appbar(),
      body: _inputs(),
      bottomNavigationBar: _buttonCreate(context),
    );
  }

  _appbar() {
    return AppBar(
      title: const Text('Nueva Categoria'),
    );
  }

  _buttonCreate(BuildContext context) {

    final categoriaService = Provider.of<CategoriaService>(context);
    
    return SubmitBtn(
      text: 'Crear Categoria',
      onPressed: categoriaService.submitting ? null : () async {
        String name = nameController.text.trim();
        String desc = descController.text.trim();

        if(name.isEmpty || desc.isEmpty) {
          MySnackbar.show(context, 'Debe ingresar todos los campos');
        }

        final resp = await categoriaService.createCat(name, desc, context);

        if(!context.mounted) return;

        if(resp == true) {
          MySnackbar.show(context, 'Categoria Creada');
        } else {
           if(resp != null) MySnackbar.show(context, resp);
        }
        
      },
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
                controller: nameController,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.list_alt, color: MyColors.primaryColor,),
                  hintText: 'Nombre de la Categoria'
              ),
            ),
           ),
           Container(
             padding: const EdgeInsets.all(10),
             margin: const EdgeInsets.symmetric(vertical: 10),
             decoration: BoxDecoration(
              color: MyColors.primaryOpacityColor,
              borderRadius: BorderRadius.circular(30)
             ),
             child: TextField(
                maxLength: 255,
                maxLines: 3,
                controller: descController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(15),
                  suffixIcon: Icon(Icons.description, color: MyColors.primaryColor,),
                  hintText: 'Descripcion'
              ),
            ),
           ),
        ],
      ),
    );
  }


}