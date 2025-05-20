import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/categorias_repositorie.dart';
import '../services/api_service.dart';
import '../data/repositories/catalogo_productos_repositorie.dart';
import 'package:collection/collection.dart';

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, CatalogoCategorias>((ref) {
  return CategoriesNotifier(ref);
});

final isLoadingCategories = StateProvider<bool>((ref) => true);
final isSavingCategories = StateProvider<bool>((ref) => false);

class CategoriesNotifier extends StateNotifier<CatalogoCategorias> {
  final ApiService apiService;
  final Ref ref;
  CategoriesNotifier(this.ref)
    : apiService = ApiService(),
      super(CatalogoCategorias(categorias: []));

  Future<void> cargarCategorias() async {
    try {
      ref.read(isLoadingCategories.notifier).state = true;
      
      final data = await apiService.getCategories();

      final categorias = data.map((item) => Categoria.fromJson(item)).toList();
      state = CatalogoCategorias(categorias: categorias);
    } catch (e) {
      throw e;
    } finally {
      ref.read(isLoadingCategories.notifier).state = false;
    }
  }

  Categoria? getCategoria(Producto producto) {
    return state.categorias.firstWhereOrNull(
      (categoria) => categoria.id == producto.categoria
    );
  }

  // Resuelve la subcategoría de un producto
  Subcategoria? getSubcategoria(Producto producto) {
    final categoria = getCategoria(producto);
    if (categoria != null) {
      return categoria.subcategorias.firstWhereOrNull(
        (subcategoria) => subcategoria.id == producto.subcategoria // Retorna null si no se encuentra la subcategoría
      );
    }
    return null;
  }

  Future<void> agregarCategoria(Categoria categoria) async {
    try {
      ref.read(isSavingCategories.notifier).state = true;

      if (categoria.nombre.isEmpty) {
        throw 'El nombre del cliente es obligatorio';
      }

      final response = await apiService.agregarCategoria(categoria.toJson());
      final nuevaCategoria = Categoria.fromJson(response);
      state = CatalogoCategorias(categorias: [...state.categorias, nuevaCategoria]);
    } catch (e) {
      throw e;
    } finally {
      ref.read(isSavingCategories.notifier).state = false;
    }
  }
  Future<void> agregarSubcategoria(String categoriaId, Subcategoria subcategoria) async {
    try {
      ref.read(isSavingCategories.notifier).state = true;

      if (subcategoria.nombre.isEmpty) {
        throw 'El nombre del cliente es obligatorio';
      }

      final response = await apiService.agregarSubcategoria(categoriaId, subcategoria.toJson());
      final nuevaSubcategoria = Subcategoria.fromJson(response);
      state = CatalogoCategorias(
        categorias: state.categorias.map((categoria) {
          if (categoria.id == categoriaId) {
            final subcategoriasNuevas = [...categoria.subcategorias, nuevaSubcategoria];
            return categoria.copyWith(
              subcategorias: subcategoriasNuevas
            );
          }
          return categoria;
        }).toList()
      );
    } catch (e) {
      throw e;
    } finally {
      ref.read(isSavingCategories.notifier).state = false;
    }
  }

  Future<void> eliminarCategoria(String categoriaId) async {
    try {
      await apiService.eliminarCategoria(categoriaId);
      state = CatalogoCategorias(categorias: state.categorias.where((categoria) => categoria.id != categoriaId).toList());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> eliminarSubcategoria(String categoriaId, String subcategoriaId) async {
    try {
      await apiService.eliminarSubcategoria(categoriaId, subcategoriaId);
      state = CatalogoCategorias(
        categorias: state.categorias.map((categoria) {
        if (categoria.id == categoriaId) {
          final nuevasSubcategorias = categoria.subcategorias
              .where((subcat) => subcat.id != subcategoriaId)
              .toList();
          return categoria.copyWith(subcategorias: nuevasSubcategorias);
        }
        return categoria;
      }
      ).toList());
    } catch (e) {
      throw Exception('Error al eliminar el cliente: $e');
    }
  }
}