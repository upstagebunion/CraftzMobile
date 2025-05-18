import 'package:craftz_app/data/repositories/clientes_repositorie.dart';
import 'package:craftz_app/providers/clientes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar clientes al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientesProvider.notifier).cargarClientes();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _agregarCliente() async {
    if (_formKey.currentState!.validate()) {
      try {
        final nuevoCliente = Cliente(
          id: '', // El backend asignará el ID
          nombre: _nombreController.text,
          apellidoPaterno: _apellidoPaternoController.text.isNotEmpty ? _apellidoPaternoController.text : null,
          apellidoMaterno: _apellidoMaternoController.text.isNotEmpty ? _apellidoMaternoController.text : null,
          telefono: _telefonoController.text.isNotEmpty ? _telefonoController.text : null,
          correo: _correoController.text.isNotEmpty ? _correoController.text : null,
          fechaRegistro: DateTime.now(),
        );

        await ref.read(clientesProvider.notifier).agregarCliente(nuevoCliente);

        // Limpiar formulario
        _nombreController.clear();
        _apellidoPaternoController.clear();
        _apellidoMaternoController.clear();
        _telefonoController.clear();
        _correoController.clear();

        // Cerrar el diálogo
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente agregado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _mostrarFormulario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre*'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _apellidoPaternoController,
                      decoration: const InputDecoration(labelText: 'Apellido Paterno'),
                    ),
                    TextFormField(
                      controller: _apellidoMaternoController,
                      decoration: const InputDecoration(labelText: 'Apellido Materno'),
                    ),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextFormField(
                      controller: _correoController,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !value.contains('@')) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _agregarCliente,
                      child: const Text('Guardar Cliente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientesState = ref.watch(clientesProvider);
    final isLoading = ref.watch(isLoadingClientes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : clientesState.clientes.isEmpty
              ? const Center(child: Text('No hay clientes registrados'))
              : ListView.builder(
                  itemCount: clientesState.clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientesState.clientes[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(cliente.nombre[0]),
                      ),
                      title: Text(
                        '${cliente.nombre} ${cliente.apellidoPaterno ?? ''}',
                      ),
                      subtitle: Text(cliente.telefono ?? 'Sin teléfono'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar Cliente'),
                              content: const Text('¿Estás seguro de eliminar este cliente?'),
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

                          if (confirm == true) {
                            try {
                              await ref.read(clientesProvider.notifier).eliminarCliente(cliente.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cliente eliminado')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al eliminar: $e')),
                              );
                            }
                          }
                        },
                      ),
                      onTap: () {
                        // Podrías navegar a una pantalla de detalles
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }
}