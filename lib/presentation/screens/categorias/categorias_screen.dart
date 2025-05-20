import 'package:craftz_app/presentation/screens/categorias/agregar_categoria_screen.dart';
import 'package:craftz_app/presentation/screens/categorias/agregar_subcategoria_screen.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';
import 'package:craftz_app/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  ConsumerState<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).cargarCategorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final categories = ref.watch(categoriesProvider).categorias;
    final isLoading = ref.watch(isLoadingCategories);

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCategoryScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            ref.read(categoriesProvider.notifier).eliminarCategoria(category.id);
                          },
                          backgroundColor: colors.secondary,
                          icon: Icons.delete,
                          label: 'Eliminar',
                        ),
                      ]
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.circular(20)),
                      title: Text(
                        category.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        if (category.subcategorias.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No hay subcategorías'),
                          )
                        else
                          ...category.subcategorias.map((subcategory) {
                              return ListTile(
                                title: Text(subcategory.nombre),
                                subtitle: Text(
                                    subcategory.usaTallas ? 'Usa tallas' : 'No usa tallas'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    ref.read(categoriesProvider.notifier).eliminarSubcategoria(category.id, subcategory.id);
                                  },
                                ),
                              );
                            }).toList(),
                        ListTile(
                          leading: const Icon(Icons.add, color: Colors.green),
                          title: const Text('Agregar subcategoría',
                              style: TextStyle(color: Colors.green)),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddSubcategoryScreen(
                                categoryId: category.id,
                                categoryName: category.nombre,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}