import 'package:craftz_app/data/repositories/categorias_repositorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/product_notifier.dart';
import '../../../providers/categories_provider.dart';
import '../../../services/api_service.dart';

class AgregarProductoScreen extends ConsumerStatefulWidget {
  @override
  _AgregarProductoScreenState createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends ConsumerState<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  ApiService apiService = ApiService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _calidadController = TextEditingController();
  final TextEditingController _corteController = TextEditingController();

  late CatalogoCategorias catalogoCategorias;
  String? _selectedCategoriaId;
  String? _selectedSubcategoriaId;

   @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    catalogoCategorias = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Producto'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Categoría'),
                value: _selectedCategoriaId,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategoriaId = newValue; // Actualiza la categoría seleccionada
                    _selectedSubcategoriaId = null; // Reinicia la subcategoría seleccionada
                  });
                },
                items: catalogoCategorias.categorias.map<DropdownMenuItem<String>>((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria.id, // Usa el ID de la categoría como valor
                    child: Text(categoria.nombre), // Muestra el nombre de la categoría
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona una categoría';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Subcategoría', labelStyle: TextStyle(color: _selectedCategoriaId != null ? colors.primary : Colors.blueGrey)),
                value: _selectedSubcategoriaId,
                onChanged: _selectedCategoriaId != null ? (String? newValue) {
                  setState(() {
                    _selectedSubcategoriaId = newValue; // Actualiza la subcategoría seleccionada
                  });
                } : null, // Deshabilita el dropdown si no hay categoría seleccionada
                items: _selectedCategoriaId != null
                    ? catalogoCategorias.categorias
                        .firstWhere((categoria) => categoria.id == _selectedCategoriaId)
                        .subcategorias
                        .map<DropdownMenuItem<String>>((subcategoria) {
                          return DropdownMenuItem<String>(
                            value: subcategoria.id, // Usa el ID de la subcategoría como valor
                            child: Text(subcategoria.nombre), // Muestra el nombre de la subcategoría
                          );
                        }).toList()
                    : [], // Si no hay categoría seleccionada, no muestra subcategorías
                validator: (value) {
                  if (_selectedCategoriaId != null && (value == null || value.isEmpty)) {
                    return 'Selecciona una subcategoría';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _calidadController,
                decoration: InputDecoration(labelText: 'Calidad'),
              ),
              TextFormField(
                controller: _corteController,
                decoration: InputDecoration(labelText: 'Corte'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final producto = {
                      'nombre': _nombreController.text,
                      'descripcion': _descripcionController.text,
                      'categoria': _selectedCategoriaId,
                      'subcategoria': _selectedSubcategoriaId,
                      'calidad': _calidadController.text,
                      'corte': _corteController.text,
                      'variantes': [],
                      'imagenes': [],
                    };

                    try {
                      await ref.read(productosProvider.notifier).agregarProducto(producto);
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}