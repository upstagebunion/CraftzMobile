import 'package:flutter/material.dart';
import '../providers/product_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsController {
  final WidgetRef ref;

  ProductsController(this.ref);

  Future<void> guardarCambios(context) async {
    try {
      // Obtener el provider y llamar a la función de guardar cambios
      await ref.read(productosProvider.notifier).guardarCambios();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados exitosamente')),
        );
    } catch (e) {
      print('Error en GuardarCambiosController: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}