import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/data/repositories/ventas_repositorie.dart';
import 'package:craftz_app/providers/ventas_provider.dart';
import './detalle_venta_screen.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';

class VentasScreen extends ConsumerStatefulWidget {
  @override
    _VentasScreenState createState() => _VentasScreenState();
}
class _VentasScreenState extends ConsumerState<VentasScreen>{

   @override
  void initState() {
    
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ventasProvider.notifier).cargarVentas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ventasState = ref.watch(ventasProvider);
    final isLoading = ref.watch(isLoadingVentas);

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(ventasProvider.notifier).cargarVentas(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: const CircularProgressIndicator())
          : ventasState.ventas.isEmpty
              ? const Center(child: Text('No hay ventas registradas'))
              : ListView.builder(
                  itemCount: ventasState.ventas.length,
                  itemBuilder: (context, index) {
                    final venta = ventasState.ventas[index];
                    return _VentaCard(venta: venta);
                  },
                ),
    );
  }
}

class _VentaCard extends StatelessWidget {
  final Venta venta;

  const _VentaCard({required this.venta});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text('Venta #${venta.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${venta.clienteNombre ?? 'Sin nombre'}'),
            Text('Total: \$${venta.total.toStringAsFixed(2)}'),
            Text('Estado: ${_getEstadoText(venta.estado)}'),
            Text('Restante: \$${venta.restante.toStringAsFixed(2)}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleVentaScreen(ventaId: venta.id),
            ),
          );
        },
      ),
    );
  }

  String _getEstadoText(EstadoVenta estado) {
    switch (estado) {
      case EstadoVenta.pendiente:
        return 'Pendiente';
      case EstadoVenta.confirmado:
        return 'Confirmado';
      case EstadoVenta.preparado:
        return 'Preparado';
      case EstadoVenta.liquidado:
        return 'Liquidado';
      case EstadoVenta.entregado:
        return 'Entregado';
      case EstadoVenta.devuelto:
        return 'Devuelto';
      default:
        return 'Desconocido';
    }
  }
}