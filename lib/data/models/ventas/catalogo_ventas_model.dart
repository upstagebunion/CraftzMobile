import './venta_model.dart';

class CatalogoVentas {
  final List<Venta> ventas;

  CatalogoVentas({required this.ventas});

  factory CatalogoVentas.fromJson(List<dynamic> json) {
    return CatalogoVentas(
      ventas: json.map((venta) => Venta.fromJson(venta)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return ventas.map((venta) => venta.toJson()).toList();
  }
}