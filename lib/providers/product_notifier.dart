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

  Producto? obtenerProductoPorId(String id) {
    try { 
      return state.productos.firstWhere((producto) => producto.id == id);
    } catch (error) {
      return null;
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

  void actualizarStock(String productoId, String varianteId, String calidadId, String colorId, String? tallaId, int cantidad) {
    final productoIndex = state.productos.indexWhere((producto) => producto.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];

    final updatedVariantes = producto.variantes!.map((variante) {
      if (variante.id == varianteId) {
        final updatedCalidades = variante.calidades.map((calidad) {
          if (calidad.id == calidadId) {
            final updatedColores = calidad.colores.map((color) {
              if (color.id == colorId) {
                if (color.stock != null) {
                  // Producto sin tallas - modificar stock directo
                  return color.copyWith(
                    stock: color.stock! + cantidad,
                    modificado: true
                  );
                } else {
                  // Producto con tallas
                  final updatedTallas = color.tallas!.map((talla) {
                    if (talla.id == tallaId) {
                      return talla.copyWith(
                        stock: talla.stock + cantidad,
                        modificado: true
                      );
                    }
                    return talla;
                  }).toList();
                  return color.copyWith(
                    tallas: updatedTallas,
                    modificado: true
                  );
                }
              }
              return color;
            }).toList();

            return calidad.copyWith(
              colores: updatedColores,
              modificado: true
            );
          }
          return calidad;
        }).toList();

        return variante.copyWith(
          calidades: updatedCalidades,
          modificado: true
        );
      }
      return variante;
    }).toList();

    final updatedProducto = producto.copyWith(
      variantes: updatedVariantes,
      modificado: true
    );

    final updatedCatalogo = List<Producto>.from(state.productos);
    updatedCatalogo[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedCatalogo);
  }

  Future<void> guardarCambios() async {
    try {
      ref.read(isSavingProvider.notifier).state = true;
      
      // Obtener solo productos modificados
      final productosModificados = state.productos
          .where((p) => p.modificado)
          .map((p) => p.toJson())
          .toList();

      if (productosModificados.isNotEmpty) {
        await apiService.actualizarProductos(productosModificados);
        
        // Resetear banderas después de guardar
        final productosActualizados = state.productos.map((p) {
          return p.copyWith(
            modificado: false,
            variantes: p.variantes?.map((v) => v.copyWith(
              modificado: false,
              calidades: v.calidades.map((calidad) => calidad.copyWith(
                modificado: false,
                colores: calidad.colores.map((c) => c.copyWith(
                  modificado: false,
                  tallas: c.tallas?.map((t) => t.copyWith(
                    modificado: false
                  )).toList()
                )).toList()
              )).toList()
            )).toList()
          );
        }).toList();
        
        state = CatalogoProductos(productos: productosActualizados);
      }
    } catch (e) {
      throw e;
    } finally {
      ref.read(isSavingProvider.notifier).state = false;
    }
  }

  Future<void> agregarVariante(String productoId, String? variante, int orden, {bool disponibleOnline = false}) async {
    try {
      final response = await apiService.agregarVariante(productoId, variante, orden, disponibleOnline);
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

  Future<void> agregarCalidad(String productoId, String varianteId, String? calidad, int orden, {bool disponibleOnline = false}) async {
    try {
      final response = await apiService.agregarCalidad(productoId, varianteId, calidad, orden, disponibleOnline);
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

  Future<void> agregarColor(
    String productoId,
    String varianteId,
    String calidadId,
    String color,
    String codigoHex,
    int? stock,
    double? costo,
    int orden,
    {bool disponibleOnline = false}
  ) async {
    try {
      final response = await apiService.agregarColor(productoId,
        varianteId,
        calidadId,
        color,
        codigoHex,
        stock,
        costo,
        orden,
        disponibleOnline);
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

  Future<void> agregarTalla(
    String productoId,
    String varianteId,
    String calidadId,
    String colorId,
    String codigo,
    String? talla,
    int stock,
    double costo,
    int orden,
    String? suk,
    {bool disponibleOnline = false}
  ) async {
    try {
      final response = await apiService.agregarTalla(
        productoId,
        varianteId,
        calidadId,
        colorId,
        codigo,
        talla,
        stock,
        costo,
        orden,
        suk,
        disponibleOnline);
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

  Future<void> eliminarCalidad(String productoId, String varianteId, String calidadId) async {
    try {
      await apiService.eliminarCalidad(productoId, varianteId, calidadId);
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

  Future<void> eliminarColor(String productoId, String varianteId, String calidadId, String colorId) async {
    try {
      final response = await apiService.eliminarColor(productoId, varianteId, calidadId, colorId);
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

  Future<void> eliminarTalla(String productoId, String varianteId, String calidadId, String colorId, String tallaId) async {
    try {
      final response = await apiService.eliminarTalla(productoId, varianteId, calidadId, colorId, tallaId);
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
    String calidadId,
    String colorId,
    String nuevoColor,
    String nuevoCodigoHex,
    int? nuevoStock,
    double? nuevoCosto,
    int? nuevoOrden,
  ) async {
    final productoIndex = state.productos.indexWhere((p) => p.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];
    final updatedVariantes = producto.variantes?.map((variante) {
      if (variante.id == varianteId) {
        final updatedCalidades = variante.calidades.map((calidad) {
          if (calidad.id == calidadId) {
            final updatedColores = calidad.colores.map((color) {
              if (color.id == colorId) {
                return color.copyWith(
                  color: nuevoColor,
                  codigoHex: nuevoCodigoHex,
                  stock: nuevoStock,
                  costo: nuevoCosto,
                  orden: nuevoOrden ?? color.orden,
                  modificado: true,
                );
              }
              return color;
            }).toList();
            return calidad.copyWith(colores: updatedColores, modificado: true);
          }
          return calidad;
        }).toList();
        return variante.copyWith(calidades: updatedCalidades, modificado: true);
      }
      return variante;
    }).toList();

    final updatedProducto = producto.copyWith(
      variantes: updatedVariantes,
      modificado: true,
      metadata: Metadata(
        fechaCreacion: producto.metadata.fechaCreacion,
        fechaActualizacion: DateTime.now(),
      ),
    );
    final updatedProductos = List<Producto>.from(state.productos);
    updatedProductos[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedProductos);
  }

  Future<void> editarTalla(
    String productoId,
    String varianteId,
    String calidadId,
    String colorId,
    String tallaId,
    String nuevoCodigo,
    String? nuevaTalla,
    int nuevoStock,
    double nuevoCosto,
    int nuevoOrden,
    String? nuevoSuk,
  ) async {
    final productoIndex = state.productos.indexWhere((p) => p.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];
    final updatedVariantes = producto.variantes?.map((variante) {
      if (variante.id == varianteId) {
        final updatedCalidades = variante.calidades.map((calidad) {
          if (calidad.id == calidadId) {
            final updatedColores = calidad.colores.map((color) {
              if (color.id == colorId) {
                final updatedTallas = color.tallas?.map((talla) {
                  if (talla.id == tallaId) {
                    return talla.copyWith(
                      codigo: nuevoCodigo,
                      talla: nuevaTalla,
                      stock: nuevoStock,
                      costo: nuevoCosto,
                      orden: nuevoOrden,
                      suk: nuevoSuk,
                      modificado: true,
                    );
                  }
                  return talla;
                }).toList();
                return color.copyWith(tallas: updatedTallas, modificado: true);
              }
              return color;
            }).toList();
            return calidad.copyWith(colores: updatedColores, modificado: true);
          }
          return calidad;
        }).toList();
        return variante.copyWith(calidades: updatedCalidades, modificado: true);
      }
      return variante;
    }).toList();

    final updatedProducto = producto.copyWith(
      variantes: updatedVariantes,
      modificado: true,
      metadata: Metadata(
        fechaCreacion: producto.metadata.fechaCreacion,
        fechaActualizacion: DateTime.now(),
      ),
    );
    final updatedProductos = List<Producto>.from(state.productos);
    updatedProductos[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedProductos);
  }

  Future<void> editarCalidad(
    String productoId,
    String varianteId,
    String calidadId,
    String? nuevaCalidad,
    int? nuevoOrden,
  ) async {
    final productoIndex = state.productos.indexWhere((p) => p.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];
    final updatedVariantes = producto.variantes?.map((variante) {
      if (variante.id == varianteId) {
        final updatedCalidades = variante.calidades.map((calidad) {
          if (calidad.id == calidadId) {
            return calidad.copyWith(
              calidad: nuevaCalidad,
              orden: nuevoOrden ?? calidad.orden,
              modificado: true,
            );
          }
          return calidad;
        }).toList();
        return variante.copyWith(calidades: updatedCalidades, modificado: true);
      }
      return variante;
    }).toList();

    final updatedProducto = producto.copyWith(
      variantes: updatedVariantes,
      modificado: true,
      metadata: Metadata(
        fechaCreacion: producto.metadata.fechaCreacion,
        fechaActualizacion: DateTime.now(),
      ),
    );

    final updatedProductos = List<Producto>.from(state.productos);
    updatedProductos[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedProductos);
  }

  Future<void> editarVariante(String productoId, String varianteId, String? nuevaVariante, int? nuevoOrden) async {
    final productoIndex = state.productos.indexWhere((p) => p.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];
    final updatedVariantes = producto.variantes?.map((variante) {
      if (variante.id == varianteId) {
        return variante.copyWith(variante: nuevaVariante, orden: nuevoOrden ?? variante.orden, modificado: true);
      }
      return variante;
    }).toList();

    final updatedProducto = producto.copyWith(
      variantes: updatedVariantes,
      modificado: true,
      metadata: Metadata(
        fechaCreacion: producto.metadata.fechaCreacion,
        fechaActualizacion: DateTime.now(),
      ),
    );
    final updatedProductos = List<Producto>.from(state.productos);
    updatedProductos[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedProductos);
  }

  Future<void> editarProducto(String productoId, Map<String, dynamic> nuevosDatos) async {
    final productoIndex = state.productos.indexWhere((p) => p.id == productoId);
    if (productoIndex == -1) return;

    final producto = state.productos[productoIndex];
    final updatedProducto = producto.copyWith(
      nombre: nuevosDatos['nombre'] ?? producto.nombre,
      descripcion: nuevosDatos['descripcion'] ?? producto.descripcion,
      categoria: nuevosDatos['categoria'] ?? producto.categoria,
      subcategoria: nuevosDatos['subcategoria'] ?? producto.subcategoria,
      configVariantes: nuevosDatos['configVariantes'] ?? producto.configVariantes,
      activo: nuevosDatos['activo'] ?? producto.activo,
      modificado: true,
      metadata: Metadata(
        fechaCreacion: producto.metadata.fechaCreacion,
        fechaActualizacion: DateTime.now(),
      ),
    );

    final updatedProductos = List<Producto>.from(state.productos);
    updatedProductos[productoIndex] = updatedProducto;

    state = CatalogoProductos(productos: updatedProductos);
    }
}
