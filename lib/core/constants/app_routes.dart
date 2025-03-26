import 'package:craftz_app/presentation/screens/productos/agregar_producto.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/screens_repositorie.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String productos = '/productos';
  static const String agregarProducto = '/agregarProducto';
  static const String listaCompras = '/listaCompras';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => LoginScreen(),
      home: (context) => const HomeScreen(),
      productos: (context) => ProductsPage(),
      agregarProducto: (context) => AgregarProductoScreen(),
      listaCompras: (context) => ListaComprasScreen(),
    };
  }
}