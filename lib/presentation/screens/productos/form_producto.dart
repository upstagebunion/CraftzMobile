import 'package:craftz_app/data/repositories/categorias_repositorie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/product_notifier.dart';
import '../../../providers/categories_provider.dart';
import '../../../services/api_service.dart';
import '../../../data/models/catalogo_productos/product_model.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';

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

  late CatalogoCategorias catalogoCategorias;
  String? _selectedCategoriaId;
  String? _selectedSubcategoriaId;
  bool _usaVariantes = false;
  bool _usaCalidades = false;
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.isEditing ? widget.producto?.nombre : ''
    );
    _descripcionController = TextEditingController(
      text: widget.isEditing ? widget.producto?.descripcion : ''
    );

    if (widget.isEditing && widget.producto != null) {
      _usaVariantes = widget.producto!.configVariantes.usaVariante;
      _usaCalidades = widget.producto!.configVariantes.usaCalidad;
      _activo = widget.producto!.activo;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if(widget.isEditing){
        final Set<String> idsCategoriasExistentes = ref.read(categoriesProvider).categorias.map((c) => c.id).toSet();
        if (idsCategoriasExistentes.contains(widget.producto!.categoria)) {
          // La categoría existe, asignamos el ID
          setState(() {
            _selectedCategoriaId = widget.producto!.categoria;
            if (widget.producto!.subcategoria.isNotEmpty) {
              // Debes validar que la subcategoría exista en la categoría seleccionada
              final categoriaActual = catalogoCategorias.categorias.firstWhere(
                  (c) => c.id == widget.producto!.categoria);
              if (categoriaActual.subcategorias.any((s) => s.id == widget.producto!.subcategoria)) {
              _selectedSubcategoriaId = widget.producto!.subcategoria;
              }
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    catalogoCategorias = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(widget.isEditing ? 'Editar Producto' : 'Agregar Producto'),
        actions: widget.isEditing ? [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmarEliminacion,
          )
        ] : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Sección de información básica
              _buildSectionTitle('Información Básica'),
              _buildTextFormField(
                controller: _nombreController,
                label: 'Nombre',
                isRequired: true,
              ),
              _buildTextFormField(
                controller: _descripcionController,
                label: 'Descripción',
                isRequired: true,
                maxLines: 3,
              ),
              
              // Selectores de categoría y subcategoría
              _buildSectionTitle('Categorización'),
              _buildCategoryDropdowns(),
              
              // Configuración de variantes
              _buildSectionTitle('Configuración de Variantes'),
              SwitchListTile(
                title: Text('Usar Variantes'),
                value: _usaVariantes,
                onChanged: (value) => setState(() => _usaVariantes = value),
                activeColor: colors.primary,
              ),
              SwitchListTile(
                title: Text('Usar Calidades'),
                value: _usaCalidades,
                onChanged: (value) => setState(() => _usaCalidades = value),
                activeColor: colors.primary,
              ),
              
              // Estado del producto
              _buildSectionTitle('Estado'),
              SwitchListTile(
                title: Text('Producto Activo'),
                value: _activo,
                onChanged: (value) => setState(() => _activo = value),
                activeColor: colors.primary,
              ),
              
              // Botón de guardar
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16)
                ),
                child: Text(
                  widget.isEditing ? 'Actualizar Producto' : 'Guardar Producto',
                  style: TextStyle(fontSize: 16)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        } : null,
      ),
    );
  }

  Widget _buildCategoryDropdowns() {
    final colors = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Categoría',
            border: OutlineInputBorder(),
          ),
          value: _selectedCategoriaId,
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategoriaId = newValue;
              _selectedSubcategoriaId = null;
            });
          },
          items: catalogoCategorias.categorias.map<DropdownMenuItem<String>>((categoria) {
            return DropdownMenuItem<String>(
              value: categoria.id,
              child: Text(categoria.nombre),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona una categoría';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Subcategoría',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
              color: _selectedCategoriaId != null ? colors.primary : Colors.grey),
          ),
          value: _selectedSubcategoriaId,
          onChanged: _selectedCategoriaId != null ? (String? newValue) {
            setState(() => _selectedSubcategoriaId = newValue);
          } : null,
          items: _selectedCategoriaId != null
              ? catalogoCategorias.categorias
                  .firstWhere((categoria) => categoria.id == _selectedCategoriaId)
                  .subcategorias
                  .map<DropdownMenuItem<String>>((subcategoria) {
                    return DropdownMenuItem<String>(
                      value: subcategoria.id,
                      child: Text(subcategoria.nombre),
                    );
                  }).toList()
              : [],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona una subcategoría';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final productoData = {
          'nombre': _nombreController.text,
          'descripcion': _descripcionController.text,
          'categoria':  _selectedCategoriaId,
          'subcategoria': _selectedSubcategoriaId,
          'configVariantes': {
            'usaVariante': _usaVariantes,
            'usaCalidad': _usaCalidades,
          },
          'activo': _activo,
          'variantes': [],
          'imagenes': [],
        };

        if (widget.isEditing && widget.producto != null) {
          await ref.read(productosProvider.notifier).editarProducto(
            widget.producto!.id,
            productoData,
          );
        } else {
          await ref.read(productosProvider.notifier).agregarProducto(
            productoData,
          );
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmarEliminacion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(productosProvider.notifier)
          .eliminarProducto(widget.producto!.id);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}