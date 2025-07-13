class ConfigVariantes {
  final bool usaVariante;
  final bool usaCalidad;

  ConfigVariantes({required this.usaVariante, required this.usaCalidad});

  factory ConfigVariantes.fromJson(Map<String, dynamic> json) {
    return ConfigVariantes(
      usaVariante: json['usaVariante'] as bool,
      usaCalidad: json['usaCalidad'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usaVariante': usaVariante,
      'usaCalidad': usaCalidad,
    };
  }

  ConfigVariantes copyWith({
    bool? usaVariante,
    bool? usaCalidad,
  }) {
    return ConfigVariantes(
      usaVariante: usaVariante ?? this.usaVariante,
      usaCalidad: usaCalidad ?? this.usaCalidad,
    );
  }
}