import 'dart:convert';
import 'dart:io';

import 'package:delivery_flutter/models/producto.dart';
import 'package:delivery_flutter/services/categoria_service.dart';
import 'package:delivery_flutter/widgets/my_snackbar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:delivery_flutter/services/producto_service.dart';

import 'package:delivery_flutter/theme/colors.dart';
import 'package:delivery_flutter/widgets/drawer.dart';
import 'package:delivery_flutter/widgets/submit_btn.dart';

import 'package:delivery_flutter/models/categoria.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';


class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = MoneyMaskedTextController();

  String? _idCategory;
 
  bool submitted = false;

  File? mainImage;
  List<File> pickedImages = [];
  List<Categoria> cats = [];



  @override
  Widget build(BuildContext context) {

    if(!submitted) _getCategories();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: _appbar(),
      body: SingleChildScrollView(
        child: _inputs(),
      ),
      bottomNavigationBar: _submitBtn(context),
    );
  }

  _submitBtn(BuildContext context) {
    final productoService = Provider.of<ProductoService>(context);

    return SubmitBtn(
      text: 'Crear Producto',
      onPressed: productoService.submitting ? null :  () => _createProduct(context),
    );
  }

  _createProduct(BuildContext context) async {
     final productoService = Provider.of<ProductoService>(context, listen: false);

     ProgressDialog _progressDialog = ProgressDialog(context: context);

     String name = nameController.text.trim();
     String desc = descController.text.trim();
     double price = priceController.numberValue;

     if(name.isEmpty || desc.isEmpty) {
      MySnackbar.show(context, 'Debe ingresar todos los campos');
      return;
     }

     if(mainImage == null) {
      MySnackbar.show(context, 'Selecciona la imagen principal del producto');
       return;
     }

     if(_idCategory == null) {
      MySnackbar.show(context, 'Selecciona una categoria');
       return;
     }


      Producto producto = Producto(
        nombre: name, 
        descripcion: desc, 
        precio: price, 
        idCategoria: int.parse(_idCategory!), 
        imagenes: []
      );

      _progressDialog.show(max: 100, msg: 'Creando Producto...');
      Stream stream = await productoService.createProd(producto, [...pickedImages, mainImage!]);

      stream.listen((res) { 
        _progressDialog.close();
        final respApi = json.decode(res);

        if(respApi['success'] == true) {
            MySnackbar.show(context, respApi['msg']);
            _resetValues();
        } else {
            if(respApi['msg'] != null) MySnackbar.show(context, respApi['msg']);
        }
        
      });

  }

  void _resetValues() {
    nameController.clear();
    priceController.text = '0,00';
    descController.clear();

    mainImage = null;
    _idCategory = null;
    pickedImages = [];

    setState(() {
      
    });
  }

  _appbar( ) {
    return AppBar(
      title: const Text('Nuevo Producto'),
    );
  }

  _inputs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 35),
      child: Column(
        children: [
          _nameInput(),
          _descInput(),
          _precioInput(),
          _productImage(),
          _imagesBox(),
          _dropdownCategory(cats),
          const SizedBox(height: 30,)
        ],
      ),
    );
  }

  _descInput() {
    return Container(
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
          prefixIcon: Icon(Icons.description, color: MyColors.primaryColor,),
          hintText: 'Descripcion'
      ),
    ),
    );
  }

  _precioInput() {
   return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
      color: MyColors.primaryOpacityColor,
      borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        maxLines: 1,
        controller: priceController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.monetization_on, color: MyColors.primaryColor,),
          hintText: 'Precio',
      ),
    ),
    );
  }

  _nameInput() {
   return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
      color: MyColors.primaryOpacityColor,
      borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        maxLines: 1,
        maxLength: 180,
        controller: nameController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.local_pizza, color: MyColors.primaryColor,),
          hintText: 'Nombre del producto',
      ),
    ),
    );
  }

  _productImage() {
    return GestureDetector(
      onTap: () async {
        _showAlertDialog(context);
        setState(() {
        });
      },
      child: _imageBox(mainImage, true),
    ); 
  }

  _imagesBox() {
    
    List<Widget> content = [_addImage()];

    for (var i = 0; i < pickedImages.length; i++) {
     content.insert(0, _imageBox(pickedImages[i], false));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Imagenes', textAlign: TextAlign.start,),
              const SizedBox(width: 10,),
              pickedImages.isNotEmpty 
                ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  elevation: 0,
                ),
                onPressed: () {
                  pickedImages.clear();
                  setState(() {
                    
                  });
                }, child: const Text('Vaciar Caja de imagenes', style: TextStyle(fontSize: 12, color: Colors.white),))
                : const SizedBox()
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: content,
          ),
        ],
      ),
    );
  }

  _addImage() {
   return GestureDetector(
     onTap: ()  async {
        final List<XFile> images = await ImagePicker().pickMultiImage();
        
        for (var i = 0; i < images.length; i++) {
          pickedImages.add(File(images[i].path));
        }

        setState(() {
          
        });
     },
     child: Card(
          elevation: 3,
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.25,
            child: const Icon(Icons.add),
          ),
        ),
   );
  }

  _imageBox(File? imgFile, bool? full) {
    return imgFile != null 
      ? Card(
        elevation: 3,
        child: Container(
          height: full == true ? 150 : 100,
          width: MediaQuery.of(context).size.width * (full == true ? 1 : 0.20),
          child: Image.file(
            imgFile,
            fit: BoxFit.cover,
          ),
        ),
      )
      : Card(
        elevation: 3,
        child: Container(
          height: full == true ? 150 : 100,
          width: MediaQuery.of(context).size.width * (full == true ? 1 : 0.20),
          child: const Image(
            image: AssetImage('assets/img/add_image.png'),
          ),
        ),
      );
  }

  List<DropdownMenuItem<String>> _dropdownItems(List<Categoria> cats) {
    List<DropdownMenuItem<String>> list = [];

    cats.forEach((cat) { 
      list.add(
        DropdownMenuItem(
          value: cat.id,
          child: Text(cat.nombre),
        )
      );
    });

    return list;
  }
 
  _dropdownCategory(List<Categoria> categories) {
    return Material(
      elevation: 2,
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.search, color: MyColors.primaryColor,),
                const SizedBox(width: 15,),
                const Text(
                  'Categorias',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButton(
                underline: Container(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_drop_down_circle,
                    color: MyColors.primaryColor,
                  ),
                ),
                elevation: 3,
                isExpanded: true,
                hint: const Text('Seleccionar categoria', style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16
                ),),
                onChanged: (e){
                  setState(() {
                    _idCategory = e;
                  });
                },
                items: _dropdownItems(categories),
                value: _idCategory,
              
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _selectImage(ImageSource imageSource) async {
    final pickedFile = await ImagePicker().pickImage(source: imageSource);
    if(pickedFile != null) {
      mainImage = File(pickedFile.path);
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
      title: const Text('Selecciona tu imagen'),
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

  void _getCategories() async {
    final categoriaService = Provider.of<CategoriaService>(context);
    cats = categoriaService.categorias;
  }
}