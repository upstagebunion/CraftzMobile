import 'package:craftz_app/data/models/cotizacion/extra_cotizado_model.dart';
import 'package:craftz_app/data/models/extras/parametro_costo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../data/repositories/cotizacion_repositories.dart';

import 'package:craftz_app/providers/extras_provider.dart';
import 'package:craftz_app/core/utils/calculadorCosto.dart';
import 'package:craftz_app/providers/parametros_costos_provider.dart';

class ProductoTile extends ConsumerStatefulWidget {
  final ProductoCotizado producto;
  final VoidCallback onRemove;
  final Function(ProductoCotizado) onUpdate;

  const ProductoTile({
    required this.producto,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  __ProductoTileState createState() => __ProductoTileState();
}

class __ProductoTileState extends ConsumerState<ProductoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        children: [
          Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    _mostrarDialogoDescuento();
                  },
                  backgroundColor: colors.primary,
                  icon: Icons.discount,
                  label: 'Agregar Descuento',
                ),
                SlidableAction(
                  onPressed: (context) async {
                    widget.onRemove();
                  },
                  backgroundColor: colors.secondary,
                  icon: Icons.delete,
                  label: 'Eliminar',
                ),
              ]
            ),
            child: ListTile(
              title: Text(widget.producto.producto.nombre),
              subtitle: Text(
                '${widget.producto.cantidad} x \$${widget.producto.precioFinal / widget.producto.cantidad} = \$${widget.producto.precioFinal}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      _mostrarDialogoExtras();
                    } 
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (widget.producto.cantidad > 1) {
                        final nuevaCantidad = widget.producto.cantidad - 1;
                        final nuevoPrecioFinal = (widget.producto.precio * nuevaCantidad);

                        widget.onUpdate(widget.producto.copyWith(
                          cantidad: nuevaCantidad,
                          precioFinal: nuevoPrecioFinal,
                        ));
                      }
                    },
                  ),
                  Text('${widget.producto.cantidad}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final nuevaCantidad = widget.producto.cantidad + 1;
                      final nuevoPrecioFinal = (widget.producto.precio * nuevaCantidad);
                      widget.onUpdate(widget.producto.copyWith(
                        cantidad: nuevaCantidad,
                        precioFinal: nuevoPrecioFinal,
                      ));
                    },
                  ),
                ],
              ),
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ),
          if (_expanded) _buildDetallesExpandidos(),
        ],
      ),
    );
  }

  Widget _buildDetallesExpandidos() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.producto.variante != null)
            Text('Variante: ${widget.producto.variante!.tipo}'),
          if (widget.producto.color != null)
            Text('Color: ${widget.producto.color!.nombre}'),
          if (widget.producto.talla != null)
            Text('Talla: ${widget.producto.talla!.nombre}'),
          if (widget.producto.extras.isNotEmpty) ...[
            const Text('Extras:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.producto.extras.map((extra) => 
              extra.unidad == UnidadExtra.cm_cuadrado 
              ? Text('- ${extra.nombre}: (${extra.anchoCm}cm x ${extra.largoCm}cm)')
              : Text('- ${extra.nombre}: \$${extra.monto}'),
            ),
          ],
          if (widget.producto.descuento != null)
            Text('Descuento: ${_formatearDescuento(widget.producto.descuento!)}'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onRemove,
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoExtras() async {
    final CalculadorCostos calculador = CalculadorCostos(ref);
    
    // Obtener extras disponibles para esta subcategoría
    final extrasDisponibles = await ref.watch(extrasProvider).extras;

    final nuevosExtras = await showDialog<List<ExtraCotizado>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return DialogoExtras(
              producto: widget.producto,
              extrasDisponibles: extrasDisponibles,
              calculador: calculador,
              subcategoriaId: widget.producto.subcategoriaId,
              onExtrasUpdated: (nuevosExtras, nuevoPrecio) {
                widget.onUpdate(widget.producto.copyWith(
                  extras: nuevosExtras,
                  precio: nuevoPrecio,
                ));
              },
            );
          },
        );
      },
    );

    widget.onUpdate(widget.producto.copyWith(
        extras: nuevosExtras,
        precio: widget.producto.precio,
        precioFinal: widget.producto.precio * widget.producto.cantidad,
      ));
  }

  void _mostrarDialogoDescuento() {
    String razon = widget.producto.descuento?.razon ?? '';
    String tipo = widget.producto.descuento?.tipo ?? 'porcentaje';
    double valor = widget.producto.descuento?.valor ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aplicar descuento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Razón del descuento'),
                onChanged: (value) => razon = value,
              ),
              DropdownButtonFormField<String>(
                value: tipo,
                items: const [
                  DropdownMenuItem(value: 'porcentaje', child: Text('Porcentaje')),
                  DropdownMenuItem(value: 'cantidad', child: Text('Cantidad fija')),
                ],
                onChanged: (value) => tipo = value!,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: tipo == 'porcentaje' ? 'Porcentaje (%)' : 'Cantidad (\$)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => valor = double.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final descuento = Descuento(
                  razon: razon,
                  tipo: tipo,
                  valor: valor,
                );
                
                // Calcular nuevo precio con descuento
                double nuevoPrecio = _aplicarDescuento(
                  widget.producto.precioFinal,
                  descuento,
                );
                
                widget.onUpdate(widget.producto.copyWith(
                  descuento: descuento,
                  precioFinal: nuevoPrecio,
                ));
                
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  double _aplicarDescuento(double precioActual, Descuento descuento) {
    if (descuento.tipo == 'porcentaje') {
      return precioActual * (1 - descuento.valor / 100);
    } else {
      return precioActual - descuento.valor;
    }
  }

  String _formatearDescuento(Descuento descuento) {
    if (descuento.tipo == 'porcentaje') {
      return '${descuento.valor}% - ${descuento.razon}';
    } else {
      return '\$${descuento.valor} - ${descuento.razon}';
    }
  }
}

class DialogoExtras extends ConsumerStatefulWidget {
  final ProductoCotizado producto;
  final List<Extra> extrasDisponibles;
  final CalculadorCostos calculador;
  final String subcategoriaId;
  final Function(List<ExtraCotizado>, double) onExtrasUpdated;

  const DialogoExtras({
    required this.producto,
    required this.extrasDisponibles,
    required this.calculador,
    required this.subcategoriaId,
    required this.onExtrasUpdated,
  });

  @override
  _DialogoExtrasState createState() => _DialogoExtrasState();
}

class _DialogoExtrasState extends ConsumerState<DialogoExtras> {
  late List<ExtraCotizado> _extrasActuales;

  @override
  void initState() {
    super.initState();
    _extrasActuales = List.from(widget.producto.extras);
  }

  Future<void> _agregarExtraTemporal() async {
    final parametrosDisponibles = ref.read(costosElaboracionProvider).costos;
    
    final extraTemporal = await showDialog<Extra>(
      context: context,
      builder: (context) => _DialogoExtraTemporal(parametrosDisponibles),
    );

    if (extraTemporal != null) {
      await _agregarExtra(extraTemporal, esTemporal: true);
    }
  }

  Future<void> _agregarExtra(Extra extra, {bool esTemporal = false}) async {
    ParametroCalculo? parametroCalculo = null;
    final costo = ref.read(costosElaboracionProvider.notifier).getParametroById(extra.parametroCalculoId);
    if (costo != null) {
      final valor = costo.monto / (costo.anchoPlancha! * costo.largoPlancha!);
      parametroCalculo = ParametroCalculo(nombre: costo.nombre, valor: valor); 
    }

    final nuevoExtraCotizado = ExtraCotizado(
      esTemporal: esTemporal,
      extraRef: extra.id,
      nombre: extra.nombre, 
      unidad: extra.unidad, 
      monto: extra.unidad == UnidadExtra.pieza
        ? extra.monto!
        : extra.calcularMontoWithOwnParameter(ref),
      largoCm: extra.largoCm,
      anchoCm: extra.anchoCm,
      parametroCalculo: parametroCalculo,
    );
    final nuevosExtras = List.of(_extrasActuales)..add(nuevoExtraCotizado);
    final precioNeto = await widget.calculador.calcularPrecioFinal(
      subcategoriaId: widget.subcategoriaId,
      extras: nuevosExtras,
      precioBase: widget.producto.precioBase,
    );
    
    setState(() {
      _extrasActuales = nuevosExtras;
    });
    
    widget.onExtrasUpdated(nuevosExtras, precioNeto);
  }

  Future<void> _eliminarExtra(ExtraCotizado extra) async {
    final nuevosExtras = List.of(_extrasActuales)..remove(extra);
    final precioNeto = await widget.calculador.calcularPrecioFinal(
      subcategoriaId: widget.subcategoriaId,
      extras: nuevosExtras,
      precioBase: widget.producto.precioBase,
    );
    
    setState(() {
      _extrasActuales = nuevosExtras;
    });
    
    widget.onExtrasUpdated(nuevosExtras, precioNeto);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Agregar Extras', style: textTheme.titleSmall),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Extras actuales del producto
            if (_extrasActuales.isNotEmpty) ...[
              const Text('Extras actuales:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _extrasActuales.map((extra) {
                  return Chip(
                    label: extra.unidad == UnidadExtra.cm_cuadrado 
                      ? Text('${ extra.nombre } (${ extra.anchoCm } x ${ extra.largoCm })')
                      : Text('${ extra.nombre } (\$${ extra.monto })'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _eliminarExtra(extra),
                  );
                }).toList(),
              ),
              const Divider(),
            ],

            // Botón para agregar extra temporal
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tamaño manual', style: TextStyle(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary
              ),
              onPressed: _agregarExtraTemporal,
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            
            // Lista de extras disponibles
            const Text('Agregar extras:', 
              style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: widget.extrasDisponibles.length,
                itemBuilder: (context, index) {
                  final extra = widget.extrasDisponibles[index];
                  return ListTile(
                    title: Text(extra.nombre),
                    subtitle: Text(
                      extra.unidad == UnidadExtra.pieza
                        ? '\$${extra.monto} (por pieza)'
                        : '${extra.anchoCm}cm x ${extra.largoCm}cm',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _agregarExtra(extra),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _extrasActuales),
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 20.0)
          ),
          child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _DialogoExtraTemporal extends StatefulWidget {
  final List<ParametroCostoElaboracion> parametrosDisponibles;

  const _DialogoExtraTemporal(this.parametrosDisponibles);

  @override
  __DialogoExtraTemporalState createState() => __DialogoExtraTemporalState();
}

class __DialogoExtraTemporalState extends State<_DialogoExtraTemporal> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre = 'Personalizado';
  late double _anchoCm = 0;
  late double _largoCm = 0;
  String? _parametroCalculoId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Extra Personalizado', style: textTheme.titleSmall),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .85,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _nombre,
                  decoration: const InputDecoration(labelText: 'Nombre*'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Este campo es requerido' : null,
                  onChanged: (value) => _nombre = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Ancho (cm)*'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Requerido';
                          if (double.tryParse(value!) == null) return 'Número inválido';
                          return null;
                        },
                        onChanged: (value) => _anchoCm = double.parse(value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Largo (cm)*'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Requerido';
                          if (double.tryParse(value!) == null) return 'Número inválido';
                          return null;
                        },
                        onChanged: (value) => _largoCm = double.parse(value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _parametroCalculoId,
                  decoration: const InputDecoration(labelText: 'Parámetro de cálculo*'),
                  items: widget.parametrosDisponibles
                          .where((parametro) => parametro.unidad == UnidadCosto.cm_cuadrado)
                          .map((parametro) {
                    return DropdownMenuItem(
                      value: parametro.id,
                      child: Text(parametro.nombre, style: textTheme.bodyLarge),
                    );
                  }).toList(),
                  validator: (value) => value == null ? 'Seleccione un parámetro' : null,
                  onChanged: (value) => _parametroCalculoId = value,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 20.0)
          ),
          child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final extra = Extra(
                id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                nombre: _nombre,
                unidad: UnidadExtra.cm_cuadrado,
                anchoCm: _anchoCm,
                largoCm: _largoCm,
                parametroCalculoId: _parametroCalculoId,
              );
              Navigator.pop(context, extra);
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 20.0)
          ),
          child: const Text('Agregar',  style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}