import 'package:craftz_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/extras_repositorie.dart';

final extrasProvider = StateNotifierProvider<ExtrasNotifier, CatalogoExtras>((ref) {
  return ExtrasNotifier(ref);
});

final isLoadingExtras = StateProvider<bool>((ref) => true);
final isSavingExtras = StateProvider<bool>((ref) => false);

class ExtrasNotifier extends StateNotifier<CatalogoExtras> {
  final Ref ref;
  final ApiService apiService;

  ExtrasNotifier(this.ref)
      : apiService = ApiService(),
        super(CatalogoExtras(extras: []));

  Future<void> cargarExtras() async {
    try {
      ref.read(isLoadingExtras.notifier).state = true;

      final data = await apiService.getExtras();
      final extras = data.map((item) => Extra.fromJson(item)).toList();

      state = CatalogoExtras(extras: extras);
    } catch (e) {
      throw Exception('Error al cargar extras: $e');
    } finally {
      ref.read(isLoadingExtras.notifier).state = false;
    }
  }

  Future<void> agregarExtra(Extra extra) async {
    try {
      ref.read(isSavingExtras.notifier).state = true;

      if (extra.unidad == UnidadExtra.pieza && extra.monto == null) {
        throw 'Los extras por pieza deben tener un monto definido';
      }
      
      if (extra.unidad == UnidadExtra.cm_cuadrado && 
          (extra.anchoCm == null || extra.largoCm == null || extra.parametroCalculoId == null)) {
        throw 'Los extras por cm² deben tener dimensiones y un parámetro de cálculo';
      }
      
      final response = await apiService.agregarExtra(extra.toJson());
      final nuevoExtra = Extra.fromJson(response);
      state = CatalogoExtras(extras: [...state.extras, nuevoExtra]);
    } catch (e) {
      throw Exception('Error al agregar extra: $e');
    } finally {
      ref.read(isSavingExtras.notifier).state = false;
    }
  }

  Future<void> eliminarExtra(String extraId) async {
    try {
      await apiService.eliminarExtra(extraId);
      state = CatalogoExtras(extras: state.extras.where((extra) => extra.id != extraId).toList());
    } catch (e) {
      throw Exception('Error al eliminar el extra: $e');
    }
  }

  Extra? getExtraById(String extraId) {
    try { 
      return state.extras.firstWhere((extra) => extra.id == extraId);
    } catch (error) {
      return null;
    }
  }
}