import 'package:flutter/material.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
    );
  }

  _appbar() {
    return AppBar(
      title: const Text('Categorias'),
    );
  }
}