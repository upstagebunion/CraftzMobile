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
      showSnackBar(context, 'Cambios guardados exitosamente');
    } catch (e) {
      print('Error en GuardarCambiosController: $e');
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> eliminarProducto(BuildContext context, String productoId) async {
    try {
      await ref.read(productosProvider.notifier).eliminarProducto(productoId);
      showSnackBar(context, 'Producto eliminado exitosamente');
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> eliminarVariante(BuildContext context, String productoId, String varianteId) async {
    try {
      await ref.read(productosProvider.notifier).eliminarVariante(productoId, varianteId);
      showSnackBar(context, 'Variante eliminada exitosamente');
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> eliminarColor(BuildContext context, String productoId, String varianteId, String colorId) async {
    try {
      await ref.read(productosProvider.notifier).eliminarColor(productoId, varianteId, colorId);
      showSnackBar(context, 'Color eliminado exitosamente');
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> eliminarTalla(BuildContext context, String productoId, String varianteId, String colorId, String tallaId) async {
    try {
      await ref.read(productosProvider.notifier).eliminarTalla(productoId, varianteId, colorId, tallaId);
      showSnackBar(context, 'Talla eliminada exitosamente');
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  void showSnackBar(BuildContext context, String Message) {
    if(!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$Message')),
    );
  }
}