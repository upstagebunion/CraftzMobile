import 'variante_talla_model.dart';

class Color {
  final String id;
  final String color;
  final List<Talla>? tallas;
  int? stock;
  final double? costo;
  bool modificado;

  Color({required this.id, required this.color, this.tallas, this.stock, this.costo, this.modificado = false});

  factory Color.fromJson(Map<String, dynamic> json) {
    return Color(
      id: json['_id'] as String,
      color: json['color'] as String,
      tallas: json['tallas'] != null
          ? (json['tallas'] as List)
              .map((talla) => Talla.fromJson(talla))
              .toList()
          : null,
      stock: json['stock'] as int?,
      costo: json['costo'] != null ? (json['costo'] as num?)?.toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'color': color,
      'tallas': tallas?.map((talla) => talla.toJson()).toList(),
      'stock': stock,
      'costo': costo,
    };
  }

  Color copyWith({int? stock, List<Talla>? tallas, String? color, double? costo, bool? modificado,}) {
    final tallasModificadas = tallas?.any((t) => t.modificado) ?? 
                           this.tallas?.any((t) => t.modificado) ?? false;
    return Color(
      id: this.id,
      color: color ?? this.color,
      tallas: tallas ?? this.tallas,
      stock: stock ?? this.stock,
      costo: costo ?? this.costo,
      modificado: modificado ?? tallasModificadas || 
                  (stock != null && stock != this.stock),
      );
  }
}
