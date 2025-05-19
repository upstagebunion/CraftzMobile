import 'package:flutter/material.dart';
import '../../widgets/drawer_widget.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Casita'),
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: Text('Welcome to Craftz Admin App', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}