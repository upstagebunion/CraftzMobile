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

class _VentasScreenState extends ConsumerState<VentasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ventasProvider.notifier).cargarVentas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _generarRecibo(WidgetRef ref, String id) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generando recibo... Por favor espere.'), 
          duration: Duration(seconds: 5),
        )
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

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      ref.read(ventasProvider.notifier).cargarVentasPorFecha(
        picked.start, 
        picked.end,
      );
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
    });
    ref.read(ventasProvider.notifier).cargarVentas();
  }

  @override
  Widget build(BuildContext context) {
    final ventasState = ref.watch(ventasProvider);
    final isLoading = ref.watch(isLoadingVentas);
    final colores = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Filtrar ventas según la pestaña seleccionada
    List<Venta> filteredVentas = [];
    switch (_tabController.index) {
      case 0: // Todas las ventas
        filteredVentas = ventasState.ventas;
        break;
      case 1: // Pendientes de liquidar
        filteredVentas = ventasState.ventas.where((v) => !v.liquidado).toList();
        break;
      case 2: // No entregadas
        filteredVentas = ventasState.ventas.where((v) => v.estado != EstadoVenta.entregado).toList();
        break;
      case 3: // Finalizadas (liquidadas y entregadas)
        filteredVentas = ventasState.ventas.where((v) => v.liquidado && v.estado == EstadoVenta.entregado).toList();
        break;
      case 4: // Finalizadas (liquidadas y entregadas)
        filteredVentas = ventasState.ventas.where((v) => v.estado == EstadoVenta.devuelto).toList();
        break;
    }

    // Aplicar búsqueda si hay texto
    if (_searchController.text.isNotEmpty) {
      filteredVentas = filteredVentas.where((v) => 
        v.id.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        (v.clienteNombre?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false)
      ).toList();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: _showSearch 
          ? TextField(
              textAlignVertical: TextAlignVertical.center,
              controller: _searchController,
              decoration: InputDecoration(
                hintStyle: textTheme.bodyLarge!.copyWith(color: colores.onPrimary),
                hintText: 'Buscar por folio o cliente',
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: Colors.white,),
                  onPressed: () {
                    setState(() {
                      _showSearch = false;
                      _searchController.clear();
                    });
                  },
                ),
              ),
              cursorColor: colores.onPrimary,
              style: textTheme.bodyLarge!.copyWith(color: colores.onPrimary),
              onChanged: (_) => setState(() {}),
              autofocus: true,
            )
          : const Text('Ventas'),
        actions: [
          if (!_showSearch) IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _showSearch = true),
          ),
          if (!_showSearch) IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(ventasProvider.notifier).cargarVentas(),
          ),
          if (!_showSearch) IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
          if (_selectedDateRange != null && !_showSearch) IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearDateFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mostrar rango de fechas seleccionado
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - '
                    '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: _clearDateFilter,
                    child: Text('Limpiar filtro'),
                  ),
                ],
              ),
            ),
          
          // Pestañas
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Todas', icon: Icon(Icons.list)),
              Tab(text: 'Por liquidar', icon: Icon(Icons.pending_actions)),
              Tab(text: 'Por entregar', icon: Icon(Icons.local_shipping)),
              Tab(text: 'Finalizadas', icon: Icon(Icons.check_circle)),
              Tab(text: 'Devoluciones', icon: Icon(Icons.error_outline)),
            ],
            onTap: (index) => setState(() {}),
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          
          // Contenido de las pestañas
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredVentas.isEmpty
                    ? Center(child: Text('No hay ventas en esta categoría'))
                    : ListView.builder(
                        itemCount: filteredVentas.length,
                        itemBuilder: (context, index) {
                          final venta = filteredVentas[index];
                          return _VentaCard(
                            venta: venta,
                            onReverse: () => _revertirVenta(ref, venta.id),
                            onGenerateRecipe: () => _generarRecibo(ref, venta.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _revertirVenta(WidgetRef ref, String id) async {
    try {
      await ref.read(ventasProvider.notifier).revertirVentaACotizacion(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Venta actualizada exitosamente')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la venta: $error')),
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
    required this.onGenerateRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async => onReverse(),
            backgroundColor: colors.primary,
            icon: Icons.currency_exchange,
            label: 'Revertir a cotización',
          ),
          SlidableAction(
            onPressed: (context) async => onGenerateRecipe(),
            backgroundColor: colors.secondary,
            icon: Icons.receipt_long,
            label: 'Generar Recibo',
          ),
        ],
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
              Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(venta.fechaCreacion)}'),
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