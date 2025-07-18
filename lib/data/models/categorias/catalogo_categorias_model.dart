import './categoria_model.dart';
import './subcategoria_model.dart';
import 'package:craftz_app/data/models/catalogo_productos/product_model.dart';

class CatalogoCategorias {
  final List<Categoria> categorias;

  CatalogoCategorias({required this.categorias});

  factory CatalogoCategorias.fromJson(List<dynamic> json) {
    return CatalogoCategorias(
      categorias: json.map((categoria) => Categoria.fromJson(categoria)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return categorias.map((categoria) => categoria.toJson()).toList();
  }

  Categoria? getCategoria(Producto producto) {
    try {
      return categorias.firstWhere((cat) => cat.id == producto.categoria);
    } catch (e) {
      print('Categoría con ID ${producto.categoria} no encontrada para el producto ${producto.nombre}');
      return null;
    }
  }

  Subcategoria? getSubcategoria(Producto producto, Categoria? categoria) {
    if (categoria == null) {
      return null;
    }

    try {
      return categoria.subcategorias.firstWhere((subcat) => subcat.id == producto.subcategoria);
    } catch (e) {
      print('Subcategoría con ID ${producto.subcategoria} no encontrada en la categoría ${categoria.nombre} para el producto ${producto.nombre}');
      return null;
    }
  }
}