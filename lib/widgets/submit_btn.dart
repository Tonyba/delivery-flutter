import 'package:flutter/material.dart';

class SubmitBtn extends StatelessWidget {

  final Function? onPressed;
  final String text;

  const SubmitBtn({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: ElevatedButton(
        onPressed: onPressed  != null ? () => onPressed!() : null , 
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15)
        ),
        child: Text(text, style: const TextStyle(color: Colors.white))
      ),
    );
  }
}