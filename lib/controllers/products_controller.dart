import 'package:flutter/material.dart';
import '../providers/product_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/catalogo_productos_repositorie.dart';
import '../data/repositories/categorias_repositorie.dart';

class ProductsController {
  final WidgetRef ref;

  ProductsController(this.ref);

  List<Producto> obtenerProductosPorSubcategoria(List<Producto> productos, Subcategoria subcategoria) {
    final productosPorCategoria = productos.where((producto) => producto.subcategoria == subcategoria.id).toList();
    return productosPorCategoria;
  }

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

  Future<void> eliminarCalidad(BuildContext context, String productoId, String varianteId, String calidadId) async {
    try {
      await ref.read(productosProvider.notifier).eliminarCalidad(productoId, varianteId, calidadId);
      showSnackBar(context, 'Calidad eliminada exitosamente');
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> eliminarColor(BuildContext context, String productoId, String varianteId, String calidadId, String colorId) async {
    try {
      await ref.read(productosProvider.notifier).eliminarColor(productoId, varianteId, calidadId, colorId);
      showSnackBar(context, 'Color eliminado exitosamente');
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> eliminarTalla(BuildContext context, String productoId, String varianteId, String calidadId, String colorId, String tallaId) async {
    try {
      await ref.read(productosProvider.notifier).eliminarTalla(productoId, varianteId, calidadId, colorId, tallaId);
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