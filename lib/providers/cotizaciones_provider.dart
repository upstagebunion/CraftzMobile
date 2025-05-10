import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import '../data/repositories/cotizacion_repositories.dart';

final cotizacionProvider = StateNotifierProvider<CotizacionNotifier, CotizacionState>((ref) {
  return CotizacionNotifier(ref);
});

class CotizacionNotifier extends StateNotifier<CotizacionState> {
  final Ref ref;
  
  CotizacionNotifier(this.ref) : super(CotizacionState.empty());

  void agregarProducto(ProductoCotizado producto) {
    state = state.copyWith(
      productos: [...state.productos, producto],
    );
  }

  void removerProducto(int index) {
    final nuevosProductos = List<ProductoCotizado>.from(state.productos);
    nuevosProductos.removeAt(index);
    state = state.copyWith(productos: nuevosProductos);
  }

  void actualizarProducto(int index, ProductoCotizado producto) {
    final nuevosProductos = List<ProductoCotizado>.from(state.productos);
    nuevosProductos[index] = producto;
    state = state.copyWith(productos: nuevosProductos);
  }

  void aplicarDescuentoGlobal({String? razon, required String tipo, required double valor}) {
    state = state.copyWith(
      descuentoGlobal: Descuento(
        razon: razon,
        tipo: tipo,
        valor: valor,
      ),
    );
  }

  Future<void> guardarCotizacion() async {
    // Implementar lógica para enviar al backend
    final cotizacionData = state.toJson();
    // await ref.read(apiService).guardarCotizacion(cotizacionData);
  }

  double get subTotal {
    return state.productos.fold(0, (sum, producto) => sum + producto.precioFinal);
  }

  double get total {
    double total = subTotal;
    final descuento = state.descuentoGlobal;
    
    if (descuento != null) {
      if (descuento.tipo == 'porcentaje') {
        total *= (1 - descuento.valor / 100);
      } else {
        total -= descuento.valor;
      }
    }
    
    return total;
  }
}

@immutable
class CotizacionState {
  final List<ProductoCotizado> productos;
  final Descuento? descuentoGlobal;

  const CotizacionState({
    required this.productos,
    this.descuentoGlobal,
  });

  factory CotizacionState.empty() => const CotizacionState(productos: []);

  CotizacionState copyWith({
    List<ProductoCotizado>? productos,
    Descuento? descuentoGlobal,
  }) {
    return CotizacionState(
      productos: productos ?? this.productos,
      descuentoGlobal: descuentoGlobal ?? this.descuentoGlobal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productos': productos.map((p) => p.toJson()).toList(),
      'descuentoGlobal': descuentoGlobal?.toJson(),
    };
  }
}