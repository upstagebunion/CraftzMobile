import 'package:craftz_app/data/repositories/categorias_repositorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/product_notifier.dart';
import '../../../providers/categories_provider.dart';
import '../../../services/api_service.dart';
import '../../../data/models/catalogo_productos/product_model.dart';

class FormProductoScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  final Producto? producto;

  const FormProductoScreen({
    Key? key,
    this.isEditing = false,
    this.producto = null,
  }) : super(key: key);

  @override
  _FormProductoScreenState createState() => _FormProductoScreenState();
}

class _FormProductoScreenState extends ConsumerState<FormProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  ApiService apiService = ApiService();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _calidadController;
  late TextEditingController _corteController;

  late CatalogoCategorias catalogoCategorias;
  String? _selectedCategoriaId;
  String? _selectedSubcategoriaId;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.isEditing ? widget.producto?.nombre : ''
    );
    _descripcionController = TextEditingController(
      text: widget.isEditing ? widget.producto?.descripcion : ''
    );
    _calidadController = TextEditingController(
      text: widget.isEditing ? widget.producto?.calidad : ''
    );
    _corteController = TextEditingController(
      text: widget.isEditing ? widget.producto?.corte : ''
    );

    if(widget.isEditing && widget.producto != null) {
      _selectedCategoriaId = widget.producto!.categoria;
      _selectedSubcategoriaId = widget.producto!.subcategoria;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _calidadController.dispose();
    _corteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    catalogoCategorias = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Producto' : 'Agregar Producto'),
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
                      if (widget.isEditing && widget.producto != null) {
                        ref.read(productosProvider.notifier).editarProducto(
                          widget.producto!.id,
                          producto
                        );
                      } else {
                        await ref.read(productosProvider.notifier).agregarProducto(producto);
                      }
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text(widget.isEditing ? 'Actualizar Producto' : 'Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}