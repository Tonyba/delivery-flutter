import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickedImageDiaglog extends StatefulWidget {

  PickedImageDiaglog({super.key, required this.pickedFile, required this.imageFile });

  XFile? pickedFile;
  File? imageFile;


  @override
  State<PickedImageDiaglog> createState() => _PickedImageDiaglogState();
}

class _PickedImageDiaglogState extends State<PickedImageDiaglog> {
  @override
  Widget build(BuildContext context) {
    return _showAlertDialog(context);
  }

  Future _selectImage(ImageSource imageSource) async {
    widget.pickedFile = await ImagePicker().pickImage(source: imageSource);
    if(widget.pickedFile != null) {
      widget.imageFile = File(widget.pickedFile!.path);
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

