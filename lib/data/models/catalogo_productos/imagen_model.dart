class Imagen {
  final String url;
  final bool esPrincipal;
  final int orden;

  Imagen({required this.url, required this.esPrincipal, required this.orden});

  factory Imagen.fromJson(Map<String, dynamic> json) {
    return Imagen(
      url: json['url'] as String,
      esPrincipal: json['esPrincipal'] as bool,
      orden: (json['orden'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'esPrincipal': esPrincipal,
      'orden': orden,
    };
  }

  Imagen copyWith({
    String? url,
    bool? esPrincipal,
    int? orden,
  }) {
    return Imagen(
      url: url ?? this.url,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      orden: orden ?? this.orden,
    );
  }
}