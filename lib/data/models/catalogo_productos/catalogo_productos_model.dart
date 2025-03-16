import 'product_model.dart';

class CatalogoProductos {
  final List<Producto> productos;

  CatalogoProductos({required this.productos});

  factory CatalogoProductos.fromJson(List<dynamic> json) {
    return CatalogoProductos(
      productos: json.map((producto) => Producto.fromJson(producto)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return productos.map((producto) => producto.toJson()).toList();
  }
}