import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.purple,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Casita'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children:[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xff292662),
                ),
                child: Text(
                  'CRAFTZ',
                  style: Theme.of(context).textTheme.headlineLarge,
                  ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
                title: Text('Casita', style: Theme.of(context).textTheme.bodyMedium),
                onTap: (){

                },
              ),
              ListTile(
                leading: Icon(Icons.inventory, color: Theme.of(context).colorScheme.primary),
                title: Text('Inventario', style: Theme.of(context).textTheme.bodyMedium),
                onTap: (){

                },
              ),
              ListTile(
                leading: Icon(Icons.monetization_on, color: Theme.of(context).colorScheme.primary),
                title: Text('Cotización', style: Theme.of(context).textTheme.bodyMedium),
                onTap: (){

                },
              ),
              ListTile(
                leading: Icon(Icons.sell, color: Theme.of(context).colorScheme.primary),
                title: Text('Venta', style: Theme.of(context).textTheme.bodyMedium),
                onTap: (){

                },
              ),
            ],
          ),
        ),
        body: Center(
          child: Text('Welcome to Craftz Admin App', style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}