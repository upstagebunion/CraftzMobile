
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:craftz_app/core/utils/helpers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomDrawer extends StatefulWidget{
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _version = 'Cargando...';
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadPackageInfo();
    await _loadUserData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPackageInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      setState(() {
        _userData = jsonDecode(userDataString);
      });
    }
  }

  bool get _isAdmin {
    return _userData['rol']?.toLowerCase() == 'admin';
  }

  @override
  Widget build(BuildContext context){
    if (_isLoading) {
      return const Drawer(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children:[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xff292662),
            ),
            child: Text(
              'CRAFTZ',
              style: theme.textTheme.headlineLarge,
              ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: theme.colorScheme.primary),
            title: Text('Home', style: theme.textTheme.bodyLarge),
            onTap: (){
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory, color: theme.colorScheme.primary),
            title: Text('Inventario', style: theme.textTheme.bodyLarge),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.productos);
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag_rounded, color: theme.colorScheme.primary),
            title: Text('Lista de compras', style: theme.textTheme.bodyLarge),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.listaCompras);
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on, color: theme.colorScheme.primary),
            title: Text('Cotización', style: theme.textTheme.bodyLarge),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.cotizaciones);
            },
          ),
          ListTile(
            leading: Icon(Icons.sell, color: theme.colorScheme.primary),
            title: Text('Ventas', style: theme.textTheme.bodyLarge),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.ventas);
            },
          ),
          ListTile(
            leading: Icon(Icons.category, color: theme.colorScheme.primary),
            title: Text('Categorias', style: theme.textTheme.bodyLarge),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.categorias);
            },
          ),
          ListTile(
            leading: Icon(Icons.face, color: theme.colorScheme.primary),
            title: Text('Clientes', style: theme.textTheme.bodyLarge),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.clientes);
            },
          ),
          if (_isAdmin) ...[
            ListTile(
              leading: Icon(Icons.add_shopping_cart, color: theme.colorScheme.primary),
              title: Text('Extras', style: theme.textTheme.bodyLarge),
              onTap: (){
                Navigator.pushNamed(context, AppRoutes.extras);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: theme.colorScheme.primary),
              title: Text('Parametros de costo', style: theme.textTheme.bodyLarge),
              onTap: (){
                Navigator.pushNamed(context, AppRoutes.parametrosCostos);
              },
            ),
          ],
          ListTile(
            leading: Icon(Icons.output_rounded, color: theme.colorScheme.primary),
            title: Text('Cerrar Sesión', style: theme.textTheme.bodyLarge),
            onTap: (){
              AuthHelper.logout(context);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Craftz Admin App - Versión: $_version',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}