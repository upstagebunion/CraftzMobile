import 'package:craftz_app/services/reportes_services.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/data/repositories/ventas_repositorie.dart';
import 'package:craftz_app/providers/ventas_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
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

  void _generarRecibo(WidgetRef ref, String id) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando recibo... Por favor espere.'), duration: Duration(seconds: 5)),
      );
      final ReporteService reporteService = ReporteService();
      final FileSaver fileSaver = FileSaver();
      final pdfBytes = await reporteService.generarReciboVentaPDF(id);

      final file = await fileSaver.saveFile(
        name: 'recibo_venta_${DateFormat('yyyyMMdd').format(DateTime.now())}',
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      
      await OpenFilex.open(file);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar reporte: ${error.toString()}')),
      );
    }
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
              : SafeArea(
                child: ListView.builder(
                    itemCount: ventasState.ventas.length,
                    itemBuilder: (context, index) {
                      final venta = ventasState.ventas[index];
                      return _VentaCard(
                        venta: venta,
                        onReverse: () => _revertirVenta(ref, venta.id),
                        onGenerateRecipe: () => _generarRecibo(ref, venta.id),
                      );
                    },
                  ),
              ),
    );
  }

  void _revertirVenta(WidgetRef ref, String id) async {
    try {
      await ref.read(ventasProvider.notifier).revertirVentaACotizacion(id);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Venta actualizada exitosamente')
          ),
        );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text('Error al actualizar la venta: $error')
        ),
      );
    }
    
  }
}

class _VentaCard extends StatelessWidget {
  final Venta venta;
  final VoidCallback onReverse;
  final VoidCallback onGenerateRecipe;

  const _VentaCard({
      required this.venta,
      required this.onReverse,
      required this.onGenerateRecipe
    });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              onReverse();
            },
            backgroundColor: colors.primary,
            icon: Icons.currency_exchange,
            label: 'Revertir a cotización',
          ),
          SlidableAction(
            onPressed: (context) async {
              onGenerateRecipe();
            },
            backgroundColor: colors.secondary,
            icon: Icons.receipt_long,
            label: 'Generar Recibo',
          ),
        ]
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          title: Text('Venta #${venta.id.substring(0, 8)}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliente: ${venta.clienteNombre ?? 'Sin nombre'}'),
              Text('Vendedor: ${venta.vendedor ?? 'Sin registro'}'),
              Text('Total: \$${venta.total.toStringAsFixed(2)}'),
              Text('${venta.liquidado ? 'Venta liquidada' : 'Venta por liquidar'}'),
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
      case EstadoVenta.entregado:
        return 'Entregado';
      case EstadoVenta.devuelto:
        return 'Devuelto';
      default:
        return 'Desconocido';
    }
  }
}
