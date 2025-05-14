import 'parametro_costo_model.dart';

class CatalogoCostosElaboracion {
  final List<ParametroCostoElaboracion> costos;

  CatalogoCostosElaboracion({required this.costos});

  factory CatalogoCostosElaboracion.fromJson(List<dynamic> json) {
    return CatalogoCostosElaboracion(
      costos: json.map((extra) => ParametroCostoElaboracion.fromJson(extra)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return costos.map((extra) => extra.toJson()).toList();
  }
}