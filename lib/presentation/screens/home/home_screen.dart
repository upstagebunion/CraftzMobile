import 'package:craftz_app/services/reportes_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/drawer_widget.dart';
import 'package:craftz_app/presentation/widgets/appbar_widget.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_filex/open_filex.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReporteService reporteService = ReporteService();
  final FileSaver fileSaver = FileSaver();

  String ventasHoy = '...';
  String ingresosMes = '...';
  String countProductos = '...';
  String countClientes = '...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final ventas = await reporteService.getVentasHoy();
      final ingresos = await reporteService.getIngresosMes();
      final productos = await reporteService.getConteoProductos();
      final clientes = await reporteService.getConteoClientes();

      setState(() {
        ventasHoy = ventas.toString();
        ingresosMes = '\$${ingresos.toString()}';
        countProductos = productos.toString();
        countClientes = clientes.toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        ventasHoy = 'S/I';
        ingresosMes = 'S/I';
        countProductos = 'S/I';
        countClientes = 'S/I';
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    }
  }

  Future<void> _generarReporte(String periodo) async {
    try {
      final pdfBytes = await reporteService.obtenerReporteVentas(periodo);
      final file = await fileSaver.saveFile(
        name: 'reporte_ventas_${periodo.toLowerCase()}.pdf',
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      await OpenFilex.open(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar reporte: ${e.toString()}')),
      );
    }
  }

  Future<void> _generarReporteInventario() async {
    try {
      final filtros = await _mostrarDialogoFiltros(context);
      if (filtros == null) return; // Usuario canceló

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando reporte... Por favor espere.'), duration: Duration(seconds: 5)),
      );
      
      final pdfBytes = await reporteService.obtenerReporteInventario(filtros);
      
      final file = await fileSaver.saveFile(
        name: 'reporte_inventario_${DateFormat('yyyyMMdd').format(DateTime.now())}',
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      
      await OpenFilex.open(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar reporte: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Craftz Admin'),
      ),
      drawer: const CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
                    colors.surface,
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con bienvenida
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido/a',
                        style: theme.textTheme.displayLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Panel de Control Craftz',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
          
                // Cards de métricas (puedes reemplazar con datos reales)
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _MetricCard(
                        icon: Icons.shopping_bag,
                        title: 'Ventas Hoy',
                        value: ventasHoy,
                        color: Colors.blue,
                      ),
                      _MetricCard(
                        icon: Icons.monetization_on,
                        title: 'Ingresos',
                        value: ingresosMes,
                        color: Colors.green,
                      ),
                      _MetricCard(
                        icon: Icons.inventory,
                        title: 'Productos',
                        value: countProductos,
                        color: Colors.orange,
                      ),
                      _MetricCard(
                        icon: Icons.people,
                        title: 'Clientes',
                        value: countClientes,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
          
                // Sección de reportes
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Text(
                    'Generar Reporte de ventass',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.primary,
                    ),
                  ),
                ),
          
                // Botones de reportes
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: _ReportButton(
                          label: 'Diario',
                          icon: Icons.calendar_view_day,
                          onPressed: () => _generarReporte('diario'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: _ReportButton(
                          label: 'Semanal',
                          icon: Icons.calendar_view_week,
                          onPressed: () => _generarReporte('semanal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: _ReportButton(
                          label: 'Mensual',
                          icon: Icons.calendar_today,
                          onPressed: () => _generarReporte('mensual'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: _ReportButton(
                          label: 'Inventario',
                          icon: Icons.inventory,
                          onPressed: _generarReporteInventario,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _mostrarDialogoFiltros(BuildContext context) async {
    DateTimeRange? rangoFechas;
    String? tipoMovimiento;
    List<String> motivosSeleccionados = [];

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar Reporte de Inventario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selector de rango de fechas
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Rango de fechas'),
                  subtitle: Text(rangoFechas != null
                      ? '${DateFormat('dd/MM/yyyy').format(rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(rangoFechas!.end)}'
                      : 'Seleccionar'),
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: rangoFechas,
                    );
                    if (picked != null) {
                      rangoFechas = picked;
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),
                
                // Selector de tipo de movimiento
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de movimiento',
                    border: OutlineInputBorder(),
                  ),
                  value: tipoMovimiento,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todos los movimientos'),
                    ),
                    const DropdownMenuItem(
                      value: 'entrada',
                      child: Text('Entradas'),
                    ),
                    const DropdownMenuItem(
                      value: 'salida',
                      child: Text('Salidas'),
                    ),
                  ],
                  onChanged: (value) {
                    tipoMovimiento = value;
                  },
                ),
                
                const SizedBox(height: 16),
                const Text('Motivos:', style: TextStyle(fontWeight: FontWeight.bold)),
                
                // Selector múltiple de motivos
                Wrap(
                  spacing: 8,
                  children: [
                    'compra',
                    'venta',
                    'ajuste',
                    'devolucion',
                    'perdida',
                  ].map((motivo) {
                    return FilterChip(
                      label: Text(motivo),
                      selected: motivosSeleccionados.contains(motivo),
                      onSelected: (selected) {
                        if (selected) {
                          motivosSeleccionados.add(motivo);
                        } else {
                          motivosSeleccionados.remove(motivo);
                        }
                        (context as Element).markNeedsBuild();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (rangoFechas == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleccione un rango de fechas')),
                  );
                  return;
                }
                
                Navigator.pop(context, {
                  'fechaInicio': rangoFechas!.start.toIso8601String(),
                  'fechaFin': rangoFechas!.end.toIso8601String(),
                  'tipoMovimiento': tipoMovimiento,
                  'motivos': motivosSeleccionados,
                });
              },
              child: const Text('Generar Reporte'),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colors.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ReportButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: colors.primary,
        backgroundColor: colors.surfaceContainer,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}