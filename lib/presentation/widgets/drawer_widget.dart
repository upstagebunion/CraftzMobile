
import '../../core/constants/app_routes.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget{
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context){
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
            title: Text('Home', style: theme.textTheme.bodyMedium),
            onTap: (){
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory, color: theme.colorScheme.primary),
            title: Text('Inventario', style: theme.textTheme.bodyMedium),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.productos);
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag_rounded, color: theme.colorScheme.primary),
            title: Text('Lista de compras', style: theme.textTheme.bodyMedium),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.listaCompras);
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on, color: theme.colorScheme.primary),
            title: Text('Cotización', style: theme.textTheme.bodyMedium),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.cotizaciones);
            },
          ),
          ListTile(
            leading: Icon(Icons.sell, color: theme.colorScheme.primary),
            title: Text('Ventas', style: theme.textTheme.bodyMedium),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.ventas);
            },
          ),
          ListTile(
            leading: Icon(Icons.face, color: theme.colorScheme.primary),
            title: Text('Clientes', style: theme.textTheme.bodyMedium),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.clientes);
            },
          ),
          ListTile(
            leading: Icon(Icons.add_shopping_cart, color: theme.colorScheme.primary),
            title: Text('Extras', style: theme.textTheme.bodyMedium),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.extras);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.primary),
            title: Text('Parametros de costo', style: theme.textTheme.bodyMedium),
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.parametrosCostos);
            },
          ),
        ],
      ),
    );
  }
}