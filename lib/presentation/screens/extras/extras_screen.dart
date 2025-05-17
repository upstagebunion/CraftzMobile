import 'package:craftz_app/providers/parametros_costos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/providers/extras_provider.dart';
import 'package:craftz_app/data/repositories/extras_repositorie.dart';

class ExtrasScreen extends ConsumerStatefulWidget {
  @override
  _ExtrasScreenState createState() => _ExtrasScreenState();
}

class _ExtrasScreenState extends ConsumerState<ExtrasScreen>{
  @override
  void initState() {
    super.initState();
    // Llamamos al provider para cargar productos cuando se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(costosElaboracionProvider.notifier).cargarCostosElaboracion();
      ref.read(extrasProvider.notifier).cargarExtras();
    });
  }

  @override
  Widget build(BuildContext context) {
    final extrasState = ref.watch(extrasProvider);
    final isLoading = ref.watch(isLoadingExtras);
    late final List<Extra> extras;

    if (!isLoading) {
      extras = extrasState.extras;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Extras'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : extras.isEmpty
              ? const Center(child: Text('No hay extras registrados'))
              : ListView.builder(
                  itemCount: extras.length,
                  itemBuilder: (context, index) {
                    final extra = extras[index];
                    return ListTile(
                      title: Text(extra.nombre),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tipo: ${extra.unidad == UnidadExtra.pieza ? 'Por pieza' : 'Por cm²'}'),
                          if (extra.unidad == UnidadExtra.pieza)
                            Text('Monto: \$${extra.monto?.toStringAsFixed(2)}'),
                          if (extra.unidad == UnidadExtra.cm_cuadrado)
                            Text('Dimensiones: ${extra.anchoCm}cm x ${extra.largoCm}cm'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showExtraForm(context, ref, extra),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteExtra(context, ref, extra.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExtraForm(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showExtraForm(BuildContext context, WidgetRef ref, Extra? extra) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ExtraForm(extra: extra);
      },
    );
  }

  Future<void> _deleteExtra(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Extra'),
        content: const Text('¿Estás seguro de que quieres eliminar este extra?'),
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
        await ref.read(extrasProvider.notifier).eliminarExtra(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Extra eliminado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    }
  }
}

class ExtraForm extends ConsumerStatefulWidget {
  final Extra? extra;

  const ExtraForm({super.key, this.extra});

  @override
  ConsumerState<ExtraForm> createState() => _ExtraFormState();
}

class _ExtraFormState extends ConsumerState<ExtraForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late UnidadExtra _unidad;
  late double? _monto;
  late double? _anchoCm;
  late double? _largoCm;
  late String? _parametroCalculoId;

  List<DropdownMenuItem<UnidadExtra>> _unidadItems = [
    const DropdownMenuItem(
      value: UnidadExtra.pieza,
      child: Text('Por pieza'),
    ),
    const DropdownMenuItem(
      value: UnidadExtra.cm_cuadrado,
      child: Text('Por cm²'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _nombre = widget.extra?.nombre ?? '';
    _unidad = widget.extra?.unidad ?? UnidadExtra.pieza;
    _monto = widget.extra?.monto;
    _anchoCm = widget.extra?.anchoCm;
    _largoCm = widget.extra?.largoCm;
    _parametroCalculoId = widget.extra?.parametroCalculoId;
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(isSavingExtras);
    final parametrosVariables = ref.watch(costosElaboracionProvider.notifier).getParametrosCalculo();

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
                  widget.extra == null ? 'Nuevo Extra' : 'Editar Extra',
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
                DropdownButtonFormField<UnidadExtra>(
                  value: _unidad,
                  items: _unidadItems,
                  decoration: const InputDecoration(labelText: 'Unidad*'),
                  onChanged: (value) {
                    setState(() {
                      _unidad = value!;
                      // Resetear valores cuando cambia el tipo
                      if (_unidad == UnidadExtra.pieza) {
                        _anchoCm = null;
                        _largoCm = null;
                        _parametroCalculoId = null;
                      } else {
                        _monto = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Campos condicionales según el tipo de unidad
                if (_unidad == UnidadExtra.pieza) ...[
                  TextFormField(
                    initialValue: _monto?.toString(),
                    decoration: const InputDecoration(labelText: 'Monto*'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_unidad == UnidadExtra.pieza && (value?.isEmpty ?? true)) {
                        return 'Este campo es requerido';
                      }
                      if (value?.isNotEmpty ?? false) {
                        if (double.tryParse(value!) == null) {
                          return 'Ingrese un número válido';
                        }
                      }
                      return null;
                    },
                    onSaved: (value) => _monto = double.tryParse(value ?? '0'),
                  ),
                ] else ...[
                  // Campos para cm²
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _anchoCm?.toString(),
                          decoration: const InputDecoration(labelText: 'Ancho (cm)*'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_unidad == UnidadExtra.cm_cuadrado && 
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
                          onSaved: (value) => _anchoCm = double.tryParse(value ?? '0'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _largoCm?.toString(),
                          decoration: const InputDecoration(labelText: 'Largo (cm)*'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_unidad == UnidadExtra.cm_cuadrado && 
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
                          onSaved: (value) => _largoCm = double.tryParse(value ?? '0'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _parametroCalculoId,
                    decoration: const InputDecoration(labelText: 'Parámetro de cálculo*'),
                    items: parametrosVariables.map((parametro) {
                      return DropdownMenuItem(
                        value: parametro.id,
                        child: Text(parametro.nombre),
                      );
                    }).toList(),
                    onChanged: (value) => _parametroCalculoId = value,
                    validator: (value) {
                      if (_unidad == UnidadExtra.cm_cuadrado && 
                          (value == null || value.isEmpty)) {
                        return 'Seleccione un parámetro de cálculo';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              final extra = Extra(
                                id: widget.extra?.id ?? '',
                                nombre: _nombre,
                                unidad: _unidad,
                                monto: _unidad == UnidadExtra.pieza ? _monto : null,
                                anchoCm: _unidad == UnidadExtra.cm_cuadrado ? _anchoCm : null,
                                largoCm: _unidad == UnidadExtra.cm_cuadrado ? _largoCm : null,
                                parametroCalculoId: _unidad == UnidadExtra.cm_cuadrado 
                                    ? _parametroCalculoId 
                                    : null,
                              );
      
                              if (widget.extra == null) {
                                await ref
                                    .read(extrasProvider.notifier)
                                    .agregarExtra(extra);
                              } else {
                                /*await ref
                                    .read(extrasProvider.notifier)
                                    .actualizarExtra(extra);*/
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
                      : Text(widget.extra == null ? 'Guardar' : 'Actualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}