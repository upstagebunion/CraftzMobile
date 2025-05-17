import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:craftz_app/providers/parametros_costos_provider.dart';
import 'package:craftz_app/providers/categories_provider.dart';
import 'package:craftz_app/data/repositories/extras_repositorie.dart';
import 'package:craftz_app/data/repositories/categorias_repositorie.dart';

class CostosElaboracionScreen extends ConsumerStatefulWidget {
  @override
  _CostosElaboracionScreenState createState() => _CostosElaboracionScreenState();
}

class _CostosElaboracionScreenState extends ConsumerState<CostosElaboracionScreen>{
  @override
  void initState() {
    super.initState();
    // Llamamos al provider para cargar productos cuando se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(costosElaboracionProvider.notifier).cargarCostosElaboracion();
      ref.read(categoriesProvider.notifier).cargarCategorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final costosState = ref.watch(costosElaboracionProvider);
    final categoriasState = ref.watch(categoriesProvider);
    final isLoading = ref.watch(isLoadingCostosElaboracion) || ref.watch(isLoadingCategories);
    late final costos;
    late final List<Categoria> categorias;

    if (!isLoading) {
      costos = costosState.costos;
      categorias = categoriasState.categorias;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parámetros de Costo'),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : costos.isEmpty
                ? const Center(child: Text('No hay parámetros registrados'))
                : ListView.builder(
                    itemCount: costos.length,
                    itemBuilder: (context, index) {
                      final costo = costos[index];
                      return ListTile(
                        title: Text(costo.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tipo: ${_getUnidadText(costo)}'),
                            if (costo.descripcion != null) Text(costo.descripcion!),
                            if (costo.unidad == UnidadCosto.cm_cuadrado)
                              Text('Plancha: ${costo.anchoPlancha}cm x ${costo.largoPlancha}cm'),
                            Text('Aplicación: ${costo.tipoAplicacion == TipoAplicacion.fijo ? 'Fijo' : 'Variable'}'),
                            if (costo.tipoAplicacion == TipoAplicacion.fijo)
                              Text('Prioridad: ${costo.prioridad}'),
                            _buildSubcategoriasInfo(costo, categorias),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showCostoForm(context, ref, costo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteCosto(context, ref, costo.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCostoForm(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getUnidadText(ParametroCostoElaboracion costo) {
    switch (costo.unidad) {
      case UnidadCosto.pieza:
        return '${costo.monto} por pieza';
      case UnidadCosto.cm_cuadrado:
        return '${costo.monto} por plancha (${costo.anchoPlancha}cm x ${costo.largoPlancha}cm)';
      case UnidadCosto.porcentaje:
        return '${(costo.monto * 100).toStringAsFixed(2)}%';
    }
  }

  Widget _buildSubcategoriasInfo(
      ParametroCostoElaboracion costo, List<Categoria> categorias) {
    final subcategorias = costo.subcategoriasAplica
        .map((subId) {
          for (var cat in categorias) {
            try {
              final sub = cat.subcategorias.firstWhere((s) => s.id == subId);
              return sub.nombre;
            } catch (error) {
              return null;
            }
          }
          return null;
        })
        .where((name) => name != null)
        .join(', ');

    return Text('Aplica a: $subcategorias');
  }

  void _showCostoForm(BuildContext context, WidgetRef ref, ParametroCostoElaboracion? costo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ParametroCostoElaboracionForm(costo: costo);
      },
    );
  }

  Future<void> _deleteCosto(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Parámetro'),
        content: const Text('¿Estás seguro de que quieres eliminar este parámetro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(costosElaboracionProvider.notifier).eliminarCostosElaboracion(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parámetro eliminado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    }
  }
}

class ParametroCostoElaboracionForm extends ConsumerStatefulWidget {
  final ParametroCostoElaboracion? costo;

  const ParametroCostoElaboracionForm({super.key, this.costo});

  @override
  ConsumerState<ParametroCostoElaboracionForm> createState() =>
      _ParametroCostoElaboracionFormState();
}

class _ParametroCostoElaboracionFormState extends ConsumerState<ParametroCostoElaboracionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String? _descripcion;
  late UnidadCosto _unidad;
  late double _monto;
  late double? _anchoPlancha;
  late double? _largoPlancha;
  late TipoAplicacion _tipoAplicacion;
  late int _prioridad;
  late List<String> _subcategoriasAplica;

  @override
  void initState() {
    super.initState();
    _nombre = widget.costo?.nombre ?? '';
    _descripcion = widget.costo?.descripcion;
    _unidad = widget.costo?.unidad ?? UnidadCosto.pieza;
    _monto = widget.costo?.monto ?? 0.0;
    _anchoPlancha = widget.costo?.anchoPlancha;
    _largoPlancha = widget.costo?.largoPlancha;
    _tipoAplicacion = widget.costo?.tipoAplicacion ?? TipoAplicacion.fijo;
    _prioridad = widget.costo?.prioridad ?? 0;
    _subcategoriasAplica = widget.costo?.subcategoriasAplica ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(isSavingCostosElaboracion);
    final categoriasState = ref.watch(categoriesProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.costo == null ? 'Nuevo Parámetro' : 'Editar Parámetro',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _nombre,
                  decoration: const InputDecoration(labelText: 'Nombre*'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Este campo es requerido' : null,
                  onSaved: (value) => _nombre = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _descripcion,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  onSaved: (value) => _descripcion = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UnidadCosto>(
                  value: _unidad,
                  items: UnidadCosto.values.map((unidad) {
                    return DropdownMenuItem(
                      value: unidad,
                      child: Text(
                        unidad == UnidadCosto.pieza ? 'Por pieza' : 
                        unidad == UnidadCosto.cm_cuadrado ? 'Por cm²' : 'Porcentaje',
                      ),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Unidad*'),
                  onChanged: (value) {
                    setState(() {
                      _unidad = value!;
                      // Resetear valores si cambia de cm_cuadrado a otro tipo
                      if (_unidad != UnidadCosto.cm_cuadrado) {
                        _anchoPlancha = null;
                        _largoPlancha = null;
                      }
                      // Validar porcentaje
                      if (_unidad == UnidadCosto.porcentaje && _monto > 1) {
                        _monto = _monto / 100;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _unidad == UnidadCosto.porcentaje 
                      ? (_monto * 100).toString()
                      : _monto.toString(),
                  decoration: InputDecoration(
                    labelText: _unidad == UnidadCosto.porcentaje 
                        ? 'Porcentaje* (0-100)' 
                        : 'Costo*',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Este campo es requerido';
                    final numValue = double.tryParse(value!);
                    if (numValue == null) return 'Ingrese un número válido';
                    if (_unidad == UnidadCosto.porcentaje && (numValue < 0 || numValue > 100)) {
                      return 'Ingrese un porcentaje entre 0 y 100';
                    }
                    if (numValue <= 0) return 'El valor debe ser mayor a 0';
                    return null;
                  },
                  onSaved: (value) {
                    final numValue = double.parse(value!);
                    _monto = _unidad == UnidadCosto.porcentaje 
                        ? numValue / 100 
                        : numValue;
                  },
                ),
                // Campos para cm²
                if (_unidad == UnidadCosto.cm_cuadrado) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _anchoPlancha?.toString(),
                          decoration: const InputDecoration(labelText: 'Ancho plancha (cm)*'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_unidad == UnidadCosto.cm_cuadrado && 
                                (value?.isEmpty ?? true)) {
                              return 'Este campo es requerido';
                            }
                            if (value?.isNotEmpty ?? false) {
                              if (double.tryParse(value!) == null) {
                                return 'Ingrese un número válido';
                              }
                            }
                            return null;
                          },
                          onSaved: (value) => _anchoPlancha = double.parse(value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _largoPlancha?.toString(),
                          decoration: const InputDecoration(labelText: 'Largo plancha (cm)*'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_unidad == UnidadCosto.cm_cuadrado && 
                                (value?.isEmpty ?? true)) {
                              return 'Este campo es requerido';
                            }
                            if (value?.isNotEmpty ?? false) {
                              if (double.tryParse(value!) == null) {
                                return 'Ingrese un número válido';
                              }
                            }
                            return null;
                          },
                          onSaved: (value) => _largoPlancha = double.parse(value!),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<TipoAplicacion>(
                  value: _tipoAplicacion,
                  items: TipoAplicacion.values.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo == TipoAplicacion.fijo ? 'Fijo' : 'Variable'),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Tipo de aplicación*'),
                  onChanged: (value) {
                    setState(() {
                      _tipoAplicacion = value!;
                    });
                  },
                ),
                // Prioridad solo para costos fijos
                if (_tipoAplicacion == TipoAplicacion.fijo) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _prioridad.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Prioridad*',
                      hintText: '0 para aplicar primero, mayor número = después',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Este campo es requerido';
                      if (int.tryParse(value!) == null) return 'Ingrese un número válido';
                      return null;
                    },
                    onSaved: (value) => _prioridad = int.parse(value!),
                  ),
                ],
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Subcategorías que aplican'),
                  children: [
                    ...categoriasState.categorias.expand((categoria) {
                      return categoria.subcategorias.map((subcategoria) {
                        final isSelected = _subcategoriasAplica.contains(subcategoria.id);
                        return CheckboxListTile(
                          title: Text('${categoria.nombre} - ${subcategoria.nombre}'),
                          value: isSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _subcategoriasAplica.add(subcategoria.id);
                              } else {
                                _subcategoriasAplica.remove(subcategoria.id);
                              }
                            });
                          },
                        );
                      });
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              final costo = ParametroCostoElaboracion(
                                id: widget.costo?.id ?? '',
                                nombre: _nombre,
                                descripcion: _descripcion,
                                unidad: _unidad,
                                monto: _monto,
                                anchoPlancha: _unidad == UnidadCosto.cm_cuadrado 
                                    ? _anchoPlancha 
                                    : null,
                                largoPlancha: _unidad == UnidadCosto.cm_cuadrado 
                                    ? _largoPlancha 
                                    : null,
                                tipoAplicacion: _tipoAplicacion,
                                prioridad: _tipoAplicacion == TipoAplicacion.fijo 
                                    ? _prioridad 
                                    : 0,
                                subcategoriasAplica: _subcategoriasAplica,
                              );
      
                              if (widget.costo == null) {
                                await ref
                                    .read(costosElaboracionProvider.notifier)
                                    .agregarParametroCostoElaboracion(costo);
                              } else {
                                /*await ref
                                    .read(costosElaboracionProvider.notifier)
                                    .actualizarCostoElaboracion(costo);*/
                              }
      
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const CircularProgressIndicator()
                      : Text(widget.costo == null ? 'Guardar' : 'Actualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}