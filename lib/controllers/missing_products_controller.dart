import '../data/repositories/catalogo_productos_repositorie.dart';
import '../data/repositories/categorias_repositorie.dart';

class MissingProductsController {
  final CatalogoCategorias catalogoCategorias;
  final CatalogoProductos catalogoProductos;

  MissingProductsController({required this.catalogoCategorias, required this.catalogoProductos});

  // Método para obtener productos filtrados por subcategoría
  List<Producto> obtenerProductosFaltosStockPorSubcategoria(Subcategoria subcategoria) {
    final productos = catalogoProductos.productos.where((producto) => producto.subcategoria == subcategoria.id);
    final productosFiltrados = productos.where((producto) {
      return producto.variantes?.any((variante) {
        return variante.colores.any((color) {
          if (subcategoria.usaTallas) {
            return color.tallas?.any((talla) => talla.stock < 2) ?? false;
          } else {
            return color.stock != null && color.stock! < 2;
          }
        });
      }) ?? false;
    }).toList();

    // Ordena los productos por urgencia (stock menor a 2 primero)
    productosFiltrados.sort((a, b) {
      final stockA = _obtenerStockMinimo(a, subcategoria.usaTallas);
      final stockB = _obtenerStockMinimo(b, subcategoria.usaTallas);
      return stockA.compareTo(stockB);
    });

    return productosFiltrados;
  }

  // Método para obtener el stock mínimo de un producto
  int _obtenerStockMinimo(Producto producto, bool usaTallas) {
    if (usaTallas) {
      return producto.variantes?.expand((variante) => variante.colores)
          .expand((color) => color.tallas ?? [])
          .map((talla) => talla.stock)
          .reduce((a, b) => a < b ? a : b) ?? 0;
    } else {
      return producto.variantes?.expand((variante) => variante.colores)
          .map((color) => color.stock ?? 0)
          .reduce((a, b) => a < b ? a : b) ?? 0;
    }
  }
}