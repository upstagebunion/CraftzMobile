import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/catalogo_productos_repositorie.dart';
import '../services/api_service.dart';

final productosProvider = StateNotifierProvider<ProductosNotifier, CatalogoProductos>((ref) {
  return ProductosNotifier(ref);
});

final isLoadingProvider = StateProvider<bool>((ref) => true);
final isSavingProvider = StateProvider<bool>((ref) => false);

class ProductosNotifier extends StateNotifier<CatalogoProductos> {
  final Ref ref;
  final ApiService apiService;
  ProductosNotifier(this.ref)
    : apiService = ApiService(),
      super(CatalogoProductos(productos: []));

  Future<void> cargarProductos() async {
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      
      final data = await apiService.getProducts();

      final productos = data.map((item) => Producto.fromJson(item)).toList();
      state = CatalogoProductos(productos: productos);
    } catch (e) {
      throw e;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> agregarProducto(Map<String, dynamic> producto) async {
    try {
      final response = await apiService.agregarProducto(producto);
      final productoActualizado = Producto.fromJson(response);
      state = CatalogoProductos(productos: [...state.productos, productoActualizado]);
    } catch (e) {
      throw e;
    }
  }

  void actualizarStockTalla(String productoId, String varianteId, String colorId, String tallaId, int cantidad) {
    final productoIndex = state.productos.indexWhere((producto) => producto.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];

    final updatedVariantes = producto.variantes!.map((variante) {
      if (variante.id == varianteId) {
        final updatedColores = variante.colores.map((color) {
          if (color.id == colorId) {
            if (color.stock != null) {
              return color.copyWith(stock: color.stock! + cantidad);
            } else {
              final updatedTallas = color.tallas!.map((talla) {
                if (talla.id == tallaId) {
                  return talla.copyWith(stock: talla.stock + cantidad);
                }
                return talla;
              }).toList();
              return color.copyWith(tallas: updatedTallas);
            }
          } else {
            return color.copyWith();
          }
        }).toList();

        return Variante(id: variante.id, tipo: variante.tipo, colores: updatedColores);
      }
      return variante;
    }).toList();

    final updatedProducto = producto.copyWith(variantes: updatedVariantes);

    final updatedCatalogo = List<Producto>.from(state.productos);
    updatedCatalogo[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedCatalogo);
  }

  Future<void> guardarCambios() async {
    try {
      ref.read(isSavingProvider.notifier).state = true;

      // Obtener el catálogo actual del estado
      final catalogoActual = state;

      // Convertir el catálogo a JSON
      final catalogoJson = catalogoActual.toJson();

      // Enviar el JSON al backend
      await apiService.actualizarProductos(catalogoJson);
    } catch (e) {
      throw e;
    } finally {
      ref.read(isSavingProvider.notifier).state = false;
    }
  }

  Future<void> agregarVariante(String productoId, String tipo) async {
    try {
      final response = await apiService.agregarVariante(productoId, tipo);
      final productoActualizado = Producto.fromJson(response);
      state  = CatalogoProductos(productos: 
        state.productos.map((producto) {
          if (producto.id == productoId) {
            return productoActualizado;
          }
          return producto;
        }).toList());
    } catch (e) {
      throw Exception('Error al agregar la variante: $e');
    }
  }

  Future<void> agregarColor(String productoId, String varianteId, String color, int? stock, double? costo) async {
    try {
      final response = await apiService.agregarColor(productoId, varianteId, color, stock, costo);
      final productoActualizado = Producto.fromJson(response);
      state  = CatalogoProductos(productos: 
        state.productos.map((producto) {
          if (producto.id == productoId) {
            return productoActualizado;
          }
          return producto;
        }).toList());
    } catch (e) {
      throw Exception('Error al agregar el color: $e');
    }
  }

  Future<void> agregarTalla(String productoId, String varianteId, String colorId, String talla, int stock, double costo) async {
    try {
      final response = await apiService.agregarTalla(productoId, varianteId, colorId, talla, stock, costo);
      final productoActualizado = Producto.fromJson(response);
      state  = CatalogoProductos(productos: 
        state.productos.map((producto) {
          if (producto.id == productoId) {
            return productoActualizado;
          }
          return producto;
        }).toList());
    } catch (e) {
      throw Exception('Error al agregar la talla: $e');
    }
  }

  Future<void> eliminarProducto(String productoId) async {
    try {
      await apiService.eliminarProducto(productoId);
      state = CatalogoProductos(productos: state.productos.where((producto) => producto.id != productoId).toList());
    } catch (e) {
      throw Exception('Error al eliminar el producto: $e');
    }
  }

  Future<void> eliminarVariante(String productoId, String varianteId) async {
    try {
      await apiService.eliminarVariante(productoId, varianteId);
      state = CatalogoProductos(productos: state.productos.map((producto) {
        if (producto.id == productoId) {
          return producto.copyWith(
            variantes: producto.variantes?.where((variante) => variante.id != varianteId).toList(),
          );
        }
        return producto;
      }).toList());
    } catch (e) {
      throw Exception('Error al eliminar el producto: $e');
    }
  }

  Future<void> eliminarColor(String productoId, String varianteId, String colorId) async {
    try {
      final response = await apiService.eliminarColor(productoId, varianteId, colorId);
      final productoActualizado = Producto.fromJson(response);

      // Actualizar el estado del provider
      state = CatalogoProductos(productos: state.productos.map((producto) {
        if (producto.id == productoId) {
          return productoActualizado;
        }
        return producto;
      }).toList());
    } catch (e) {
      throw Exception('Error al eliminar el producto: $e');
    }
  }

  Future<void> eliminarTalla(String productoId, String varianteId, String colorId, String tallaId) async {
    try {
      final response = await apiService.eliminarTalla(productoId, varianteId, colorId, tallaId);
      final productoActualizado = Producto.fromJson(response);

      state = CatalogoProductos(productos: state.productos.map((producto) {
        if (producto.id == productoId) {
          return productoActualizado;
        }
        return producto;
      }).toList());
    } catch (e) {
      throw Exception('Error al eliminar el producto: $e');
    }
  }

  Future<void> editarColor(
    String productoId, 
    String varianteId, 
    String colorId, 
    String nuevoColor, 
    int? nuevoStock,
    double? nuevoCosto
  ) async {
    final productoIndex = state.productos.indexWhere((p) => p.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];
    final updatedVariantes = producto.variantes?.map((variante) {
      if (variante.id == varianteId) {
        final updatedColores = variante.colores.map((color) {
          if (color.id == colorId) {
            return color.copyWith(
              color: nuevoColor,
              stock: nuevoStock ?? color.stock,
              costo: nuevoCosto ?? color.costo,
            );
          }
          return color;
        }).toList();
        return variante.copyWith(colores: updatedColores);
      }
      return variante;
    }).toList();

    final updatedProducto = producto.copyWith(variantes: updatedVariantes);
    final updatedProductos = List<Producto>.from(state.productos);
    updatedProductos[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedProductos);
  }

  Future<void> editarTalla(
    String productoId, 
    String varianteId, 
    String colorId, 
    String tallaId, 
    String? nuevaTalla, 
    int? nuevoStock,
    double? nuevoCosto
  ) async {
    final productoIndex = state.productos.indexWhere((p) => p.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];
    final updatedVariantes = producto.variantes?.map((variante) {
      if (variante.id == varianteId) {
        final updatedColores = variante.colores.map((color) {
          if (color.id == colorId) {
            final updatedTallas = color.tallas?.map((talla) {
              if (talla.id == tallaId) {
                return talla.copyWith(
                  talla: nuevaTalla ?? talla.talla,
                  stock: nuevoStock ?? talla.stock,
                  costo: nuevoCosto ?? talla.costo,
                );
              }
              return talla;
            }).toList();
            return color.copyWith(tallas: updatedTallas);
          }
          return color;
        }).toList();
        return variante.copyWith(colores: updatedColores);
      }
      return variante;
    }).toList();

    final updatedProducto = producto.copyWith(variantes: updatedVariantes);
    final updatedProductos = List<Producto>.from(state.productos);
    updatedProductos[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedProductos);
  }

  void editarVariante(String productoId, String varianteId, String nuevoTipo) {
    final productoIndex = state.productos.indexWhere((p) => p.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];
    final updatedVariantes = producto.variantes?.map((variante) {
      if (variante.id == varianteId) {
        return variante.copyWith(tipo: nuevoTipo);
      }
      return variante;
    }).toList();

    final updatedProducto = producto.copyWith(variantes: updatedVariantes);
    final updatedProductos = List<Producto>.from(state.productos);
    updatedProductos[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedProductos);
  }

  void editarProducto(String productoId, Map<String, dynamic> nuevosDatos) {
    final productoIndex = state.productos.indexWhere((p) => p.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];
    final updatedProducto = producto.copyWith(
      nombre: nuevosDatos['nombre'] ?? producto.nombre,
      descripcion: nuevosDatos['descripcion'] ?? producto.descripcion,
      categoria : nuevosDatos['categoria'] ?? producto.categoria,
      subcategoria : nuevosDatos['subcategoria'] ?? producto.subcategoria,
      calidad : nuevosDatos['calidad'] ?? producto.calidad,
      corte : nuevosDatos['corte'] ?? producto.corte
    );

    final updatedProductos = List<Producto>.from(state.productos);
    updatedProductos[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedProductos);
    }
}
