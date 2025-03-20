import 'package:flutter/material.dart';
import '../../widgets/drawer_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casita'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: Text('Welcome to Craftz Admin App', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}