import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ApiService apiService = ApiService();
  List<dynamic> products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    setState((){
      _isLoading = true;
    });

    try {
      final data = await apiService.getProducts();
      setState(() {
        _isLoading = false;
        products = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        titleTextStyle: theme.textTheme.headlineMedium,
        ),
      body: _isLoading? const Center(child: CircularProgressIndicator(),
      ): ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['nombre']),
            subtitle: Text('Precio: ${product['precio']} -- Hay: ${product['stock']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí agregar lógica para añadir producto
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
