import 'package:craftz_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/cotizacion_repositories.dart';

final extrasProvider = StateNotifierProvider<ExtrasNotifier, List<Extra>>((ref) {
  return ExtrasNotifier(ref);
});

class ExtrasNotifier extends StateNotifier<List<Extra>> {
  final Ref ref;
  final ApiService apiService;

  ExtrasNotifier(this.ref)
      : apiService = ApiService(),
        super([]);

  Future<void> cargarExtras() async {
    try {
      final data = await apiService.getExtras();
      state = data.map((extra) => Extra.fromJson(extra)).toList();
    } catch (e) {
      throw Exception('Error al cargar extras: $e');
    }
  }

  Future<void> agregarExtra(Extra extra) async {
    try {
      final response = await apiService.agregarExtra(extra.toJson());
      final nuevoExtra = Extra.fromJson(response);
      state = [...state, nuevoExtra];
    } catch (e) {
      throw Exception('Error al agregar extra: $e');
    }
  }
}