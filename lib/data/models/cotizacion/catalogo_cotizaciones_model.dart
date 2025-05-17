import './cotizacion_model.dart';

class CatalogoCotizaciones {
  final List<Cotizacion> cotizaciones;

  CatalogoCotizaciones({required this.cotizaciones});

  factory CatalogoCotizaciones.fromJson(List<dynamic> json) {
    return CatalogoCotizaciones(
      cotizaciones: json.map((cotizacion) => Cotizacion.fromJson(cotizacion)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return cotizaciones.map((cotizacion) => cotizacion.toJson()).toList();
  }
}