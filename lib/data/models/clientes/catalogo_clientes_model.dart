import 'package:craftz_app/data/models/clientes/cliente_model.dart';

class CatalogoClientes {
  final List<Cliente> clientes;

  CatalogoClientes({required this.clientes});

  factory CatalogoClientes.fromJson(List<dynamic> json) {
    return CatalogoClientes(
      clientes: json.map((cliente) => Cliente.fromJson(cliente)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return clientes.map((cliente) => cliente.toJson()).toList();
  }
}