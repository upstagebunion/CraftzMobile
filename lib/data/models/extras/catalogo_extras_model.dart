import './extra_model.dart';

class CatalogoExtras {
  final List<Extra> extras;

  CatalogoExtras({required this.extras});

  factory CatalogoExtras.fromJson(List<dynamic> json) {
    return CatalogoExtras(
      extras: json.map((extra) => Extra.fromJson(extra)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return extras.map((extra) => extra.toJson()).toList();
  }
}