class Metadata {
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  Metadata({required this.fechaCreacion, required this.fechaActualizacion});

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaActualizacion: DateTime.parse(json['fechaActualizacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  Metadata copyWith({
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Metadata(
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }
}