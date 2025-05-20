import 'package:craftz_app/data/repositories/categorias_repositorie.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';
import 'package:craftz_app/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddSubcategoryScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const AddSubcategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<AddSubcategoryScreen> createState() => _AddSubcategoryScreenState();
}

class _AddSubcategoryScreenState extends ConsumerState<AddSubcategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _usesSizes = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final newSubcategory = Subcategoria(
        id: '',
        nombre: _nameController.text,
        categoria: widget.categoryId,
        usaTallas: _usesSizes,
      );

      await ref.read(categoriesProvider.notifier).agregarSubcategoria(
            widget.categoryId,
            newSubcategory,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subcategoría agregada con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(isSavingCategories);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Nueva Subcategoría en ${widget.categoryName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categoría padre: ${widget.categoryName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la subcategoría',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Usa tallas (ch, mediana, grande)'),
                value: _usesSizes,
                onChanged: (value) => setState(() => _usesSizes = value),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Subcategoría'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}