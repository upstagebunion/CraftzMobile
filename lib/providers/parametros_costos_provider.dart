import 'package:craftz_app/data/repositories/extras_repositorie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';

final costosElaboracionProvider = StateNotifierProvider<CostosElaboracionNotifier, CatalogoCostosElaboracion>((ref) {
  return CostosElaboracionNotifier(ref);
});

final isLoadingCostosElaboracion = StateProvider<bool>((ref) => true);
final isSavingCostosElaboracion = StateProvider<bool>((ref) => false);

class CostosElaboracionNotifier extends StateNotifier<CatalogoCostosElaboracion> {
  final ApiService apiService;
  final Ref ref;
  
  CostosElaboracionNotifier(this.ref)
    : apiService = ApiService(),
      super(CatalogoCostosElaboracion(costos: []));

  Future<void> cargarCostosElaboracion() async {
    try {
      ref.read(isLoadingCostosElaboracion.notifier).state = true;
      
      final data = await apiService.getCostosElaboracion();
      final costos = data.map((item) => ParametroCostoElaboracion.fromJson(item)).toList();
      
      state = CatalogoCostosElaboracion(costos: costos);
    } catch (e) {
      throw e;
    } finally {
      ref.read(isLoadingCostosElaboracion.notifier).state = false;
    }
  }

  Future<void> agregarParametroCostoElaboracion(ParametroCostoElaboracion costo) async {
    try {
      ref.read(isSavingCostosElaboracion.notifier).state = true;

      if (costo.tipoAplicacion == TipoAplicacion.fijo && costo.prioridad < 0) {
        throw 'Los costos fijos deben tener una prioridad válida';
      }

      final response = await apiService.agregarParametroCostoElaboracion(costo.toJson());
      final nuevoCosto = ParametroCostoElaboracion.fromJson(response);
      state = CatalogoCostosElaboracion(costos: [...state.costos, nuevoCosto]);
    } catch (e) {
      throw e;
    } finally {
      ref.read(isSavingCostosElaboracion.notifier).state = false;
    }
  }

  List<ParametroCostoElaboracion> getCostosPorSubcategoria(String subcategoriaId) {
    return state.costos.where((costo) => 
      costo.subcategoriasAplica.contains(subcategoriaId)
    ).toList();
  }

  List<ParametroCostoElaboracion> getParametrosCalculo() {
    return state.costos.where((c) => 
      c.tipoAplicacion == TipoAplicacion.variable
    ).toList();
  }

  ParametroCostoElaboracion? getParametroById(parametroId) {
    try {
      return state.costos.firstWhere((c) => c.id == parametroId);
    } catch (error) {
      return null;
    }
  }

  Future<void> eliminarCostosElaboracion(String costoId) async {
    try {
      await apiService.eliminarCostosElaboracion(costoId);
      state = CatalogoCostosElaboracion(costos: state.costos.where((costo) => costo.id != costoId).toList());
    } catch (e) {
      throw Exception('Error al eliminar el parametro de costo de elaboracion: $e');
    }
  }

  Future<void> actualizarCostoElaboracion(ParametroCostoElaboracion costo) async {
    try {
      final response = await apiService.actualizarCostoElaboracion(costo.id, costo.toJson());
      final costoActualizado = ParametroCostoElaboracion.fromJson(response);
      state = CatalogoCostosElaboracion(
        costos: state.costos.map((c) => 
          c.id == costo.id ? costoActualizado : c
        ).toList()
      );
    } catch (e) {
      throw Exception('Error al eliminar el parametro de costo de elaboracion: $e');
    }
  }
}