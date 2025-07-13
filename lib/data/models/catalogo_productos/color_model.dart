import 'talla_model.dart';

class Color {
  final String id;
  final String color;
  final String codigoHex;
  final bool disponibleOnline;
  final String? suk;
  final int orden;
  final List<Talla>? tallas;
  int? stock;
  double? costo;
  bool modificado;

  Color({
    required this.id,
    required this.color,
    required this.codigoHex,
    required this.disponibleOnline,
    this.suk,
    required this.orden,
    this.tallas,
    this.stock,
    this.costo,
    this.modificado = false,
  });

  factory Color.fromJson(Map<String, dynamic> json) {
    return Color(
      id: json['_id'] as String,
      color: json['color'] as String,
      codigoHex: json['codigoHex'] as String,
      disponibleOnline: json['disponibleOnline'] as bool,
      suk: json['SUK'] as String?,
      orden: (json['orden'] as num).toInt(),
      tallas: (json['tallas'] as List<dynamic>?)
          ?.map((talla) => Talla.fromJson(talla))
          .toList(),
      stock: (json['stock'] as num?)?.toInt(),
      costo: (json['costo'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'color': color,
      'codigoHex': codigoHex,
      'disponibleOnline': disponibleOnline,
      'SUK': suk,
      'orden': orden,
      'tallas': tallas?.map((talla) => talla.toJson()).toList(),
      'stock': stock,
      'costo': costo,
    };
  }

  Color copyWith({
    String? color,
    String? codigoHex,
    bool? disponibleOnline,
    String? suk,
    int? orden,
    List<Talla>? tallas,
    int? stock,
    double? costo,
    bool? modificado,
  }) {
    final tallasModificadas = tallas?.any((t) => t.modificado) ?? this.tallas?.any((t) => t.modificado) ?? false;
    
    return Color(
      id: this.id,
      color: color ?? this.color,
      codigoHex: codigoHex ?? this.codigoHex,
      disponibleOnline: disponibleOnline ?? this.disponibleOnline,
      suk: suk ?? this.suk,
      orden: orden ?? this.orden,
      tallas: tallas ?? this.tallas,
      stock: stock ?? this.stock,
      costo: costo ?? this.costo,
      modificado: modificado ?? tallasModificadas || (stock != null && stock != this.stock),
    );
  }
}