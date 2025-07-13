class Talla {
 final String id;
  final String? suk;
  final String codigo; // Ej: "CH", "M"
  final String? talla;  // Ej: "Chica", "Mediana"
  int stock;
  double costo;
  final int orden;
  bool modificado;
  bool disponibleOnline;

  Talla({
    required this.id,
    this.suk,
    required this.codigo,
    this.talla,
    required this.stock,
    required this.costo,
    required this.orden,
    this.modificado = false,
    this.disponibleOnline = false,
  });

  factory Talla.fromJson(Map<String, dynamic> json) {
    return Talla(
      id: json['_id'] as String,
      suk: json['SUK'] as String?,
      codigo: json['codigo'] as String,
      talla: json['talla'] as String?,
      stock: (json['stock'] as num).toInt(),
      costo: (json['costo'] as num).toDouble(),
      orden: (json['orden'] as num).toInt(),
      disponibleOnline: json['disponibleOnline'] as bool
    );
  }

   Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'SUK': suk,
      'codigo': codigo,
      'talla': talla,
      'stock': stock,
      'costo': costo,
      'orden': orden,
      'disponibleOnline': disponibleOnline
    };
  }

  Talla copyWith({
    String? suk,
    String? codigo,
    String? talla,
    int? stock,
    double? costo,
    int? orden,
    bool? modificado,
    bool? disponibleOnline,
  }) {
    return Talla(
      id: this.id,
      suk: suk ?? this.suk,
      codigo: codigo ?? this.codigo,
      talla: talla ?? this.talla,
      stock: stock ?? this.stock,
      costo: costo ?? this.costo,
      orden: orden ?? this.orden,
      disponibleOnline: disponibleOnline ?? this.disponibleOnline,
      modificado: modificado ?? (stock != null && stock != this.stock),
    );
  }
}
