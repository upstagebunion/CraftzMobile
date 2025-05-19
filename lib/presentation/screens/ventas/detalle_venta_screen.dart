import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/data/repositories/ventas_repositorie.dart';
import 'package:craftz_app/providers/ventas_provider.dart';
import 'package:intl/intl.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';

class DetalleVentaScreen extends ConsumerStatefulWidget {
  final String ventaId;

  const DetalleVentaScreen({super.key, required this.ventaId});

  @override
  ConsumerState<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends ConsumerState<DetalleVentaScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos si no están en el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final venta = ref.read(ventasProvider.notifier).getVentaById(widget.ventaId);
      if (venta == null) {
        ref.read(ventasProvider.notifier).cargarVentas();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Venta? venta = ref.watch(ventasProvider.select(
        (state) => state.ventas.firstWhere(
          (v) => v.id == widget.ventaId,
          orElse: null,
        ),  
      ),
    );
    final isLoading = ref.watch(isLoadingVentas);

    if (isLoading && venta == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (venta == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: const Text('Detalle de Venta'),
        ),
        body: const Center(child: Text('Venta no encontrada')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Venta #${venta.id.substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoGeneral(venta),
            const SizedBox(height: 20),
            _buildProductosList(venta),
            const SizedBox(height: 20),
            _buildPagosList(venta),
            const SizedBox(height: 20),
            _buildAcciones(venta),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGeneral(Venta venta) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${venta.clienteNombre ?? 'Sin nombre'}', 
              style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(venta.fechaCreacion)}'),
            const SizedBox(height: 8),
            Text('Subtotal: \$${venta.subTotal.toStringAsFixed(2)}'),
            if (venta.descuentoGlobal != null) ...[
              const SizedBox(height: 8),
              Text('Descuento: ${_getDescuentoText(venta.descuentoGlobal!)}'),
            ],
            const SizedBox(height: 8),
            Text('Total: \$${venta.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Restante: \$${venta.restante.toStringAsFixed(2)}',
              style: TextStyle(
                color: venta.restante > 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              )),
            const SizedBox(height: 8),
            Text('Estado: ${_getEstadoText(venta.estado)}',
              style: TextStyle(
                color: _getEstadoColor(venta.estado),
                fontWeight: FontWeight.bold,
              )),
            if (venta.fechaLiquidacion != null) ...[
              const SizedBox(height: 8),
              Text('Liquidada: ${DateFormat('dd/MM/yyyy HH:mm').format(venta.fechaLiquidacion!)}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductosList(Venta venta) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...venta.productos.map((producto) => _buildProductoItem(producto)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoItem(ProductoVendido producto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${producto.producto.nombre} x${producto.cantidad}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
          if (producto.variante?.nombreCompleto != null) 
            Text('Variante: ${producto.variante!.nombreCompleto}'),
          if (producto.color?.nombre != null)
            Text('Color: ${producto.color!.nombre}'),
          if (producto.talla?.nombre != null)
            Text('Talla: ${producto.talla!.nombre}'),
          if (producto.extras.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Extras:', style: TextStyle(color: Colors.grey[600])),
            ...producto.extras.map((extra) => 
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('• ${extra.nombre}: \$${extra.monto.toStringAsFixed(2)}'),
              )).toList(),
          ],
          const SizedBox(height: 4),
          Text('Precio final: \$${producto.precioFinal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildPagosList(Venta venta) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pagos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (venta.pagos.isEmpty)
              const Text('No hay pagos registrados')
            else
              ...venta.pagos.map((pago) => _buildPagoItem(pago)).toList(),
            const SizedBox(height: 8),
            Text('Total pagado: \$${(venta.total - venta.restante).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPagoItem(Pago pago) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monto: \$${pago.monto.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Método: ${_getMetodoPagoText(pago.metodo)}'),
          if (pago.razon != null) Text('Razón: ${pago.razon}'),
          Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(pago.fecha)}'),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildAcciones(Venta venta) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Acciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (venta.estado != EstadoVenta.liquidado && venta.restante > 0)
              ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Agregar Pago'),
                onPressed: () => _mostrarDialogoAgregarPago(venta),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            const SizedBox(height: 8),
            if (venta.estado != EstadoVenta.liquidado && venta.restante == 0)
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Liquidar Venta'),
                onPressed: () => _liquidarVenta(venta.id),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
              ),
            const SizedBox(height: 8),
            PopupMenuButton<EstadoVenta>(
              itemBuilder: (context) => [
                if (venta.estado != EstadoVenta.pendiente)
                  const PopupMenuItem(
                    value: EstadoVenta.pendiente,
                    child: Text('Marcar como Pendiente'),
                  ),
                if (venta.estado != EstadoVenta.confirmado)
                  const PopupMenuItem(
                    value: EstadoVenta.confirmado,
                    child: Text('Confirmar Venta'),
                  ),
                if (venta.estado != EstadoVenta.preparado)
                  const PopupMenuItem(
                    value: EstadoVenta.preparado,
                    child: Text('Marcar como Preparado'),
                  ),
                if (venta.estado != EstadoVenta.entregado)
                  const PopupMenuItem(
                    value: EstadoVenta.entregado,
                    child: Text('Marcar como Entregado'),
                  ),
                if (venta.estado != EstadoVenta.devuelto)
                  const PopupMenuItem(
                    value: EstadoVenta.devuelto,
                    child: Text('Marcar como Devuelto'),
                  ),
              ],
              onSelected: (estado) => _cambiarEstado(venta.id, estado),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Cambiar Estado'),
                    Icon(Icons.trending_up),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarPago(Venta venta) {
    final formKey = GlobalKey<FormState>();
    final montoController = TextEditingController();
    final razonController = TextEditingController();
    MetodoPago metodoSeleccionado = MetodoPago.efectivo;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Pago'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: montoController,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingrese un monto';
                      final monto = double.tryParse(value);
                      if (monto == null) return 'Monto inválido';
                      if (monto <= 0) return 'El monto debe ser mayor a cero';
                      if (monto > venta.restante) return 'El monto excede el restante';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: razonController,
                    decoration: const InputDecoration(
                      labelText: 'Razón (opcional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<MetodoPago>(
                    value: metodoSeleccionado,
                    items: MetodoPago.values.map((metodo) {
                      return DropdownMenuItem(
                        value: metodo,
                        child: Text(_getMetodoPagoText(metodo)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        metodoSeleccionado = value;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Método de Pago',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final monto = double.parse(montoController.text);
                  final pago = Pago(
                    razon: razonController.text.isNotEmpty ? razonController.text : null,
                    monto: monto,
                    metodo: metodoSeleccionado,
                  );

                  try {
                    await ref.read(ventasProvider.notifier)
                      .agregarPagoAVenta(venta.id, pago);
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al agregar pago: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _liquidarVenta(String ventaId) async {
    try {
      await ref.read(ventasProvider.notifier).liquidarVenta(ventaId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta liquidada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al liquidar venta: $e')),
        );
      }
    }
  }

  Future<void> _cambiarEstado(String ventaId, EstadoVenta nuevoEstado) async {
    try {
      await ref.read(ventasProvider.notifier)
        .actualizarEstadoVenta(ventaId, nuevoEstado);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado cambiado a ${_getEstadoText(nuevoEstado)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: $e')),
        );
      }
    }
  }

  String _getEstadoText(EstadoVenta estado) {
    switch (estado) {
      case EstadoVenta.pendiente: return 'Pendiente';
      case EstadoVenta.confirmado: return 'Confirmado';
      case EstadoVenta.preparado: return 'Preparado';
      case EstadoVenta.liquidado: return 'Liquidado';
      case EstadoVenta.entregado: return 'Entregado';
      case EstadoVenta.devuelto: return 'Devuelto';
    }
  }

  Color _getEstadoColor(EstadoVenta estado) {
    switch (estado) {
      case EstadoVenta.pendiente: return Colors.orange;
      case EstadoVenta.confirmado: return Colors.blue;
      case EstadoVenta.preparado: return Colors.purple;
      case EstadoVenta.liquidado: return Colors.green;
      case EstadoVenta.entregado: return Colors.teal;
      case EstadoVenta.devuelto: return Colors.red;
    }
  }

  String _getMetodoPagoText(MetodoPago metodo) {
    switch (metodo) {
      case MetodoPago.efectivo: return 'Efectivo';
      case MetodoPago.tarjeta: return 'Tarjeta';
      case MetodoPago.transferencia: return 'Transferencia';
    }
  }

  String _getDescuentoText(Descuento descuento) {
    if (descuento.tipo == TipoDescuento.porcentaje) {
      return '${descuento.valor}% ${descuento.razon ?? ''}';
    } else {
      return '\$${descuento.valor} ${descuento.razon ?? ''}';
    }
  }
}