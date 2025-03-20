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
}