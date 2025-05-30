import 'package:craftz_app/presentation/screens/productos/form_producto.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/screens_repositorie.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String productos = '/productos';
  static const String agregarProducto = '/agregarProducto';
  static const String listaCompras = '/listaCompras';
  static const String cotizaciones = '/cotizaciones';
  static const String extras = '/extras';
  static const String parametrosCostos = '/parametrosCostos';
  static const String clientes = '/clientes';
  static const String ventas = '/ventas';
  static const String categorias = '/categorias';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => LoginScreen(),
      home: (context) => const HomeScreen(),
      productos: (context) => ProductsPage(),
      agregarProducto: (context) => FormProductoScreen(),
      listaCompras: (context) => ListaComprasScreen(),
      cotizaciones: (context) => ListaCotizacionesScreen(),
      extras: (context) => ExtrasScreen(),
      parametrosCostos: (context) => CostosElaboracionScreen(),
      clientes: (context) => ClientesScreen(),
      ventas: (context) => VentasScreen(),
      categorias: (context) => CategoriesListScreen(),
    };
  }
}