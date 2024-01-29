import 'package:flutter/material.dart';

class NoData extends StatelessWidget {

  final String text;

  const NoData({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/img/no_items.png'),
          Text(text)
        ],
      ),
    );
  }
}