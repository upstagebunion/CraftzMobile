// clientes_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftz_app/data/repositories/clientes_repositorie.dart';
import 'package:craftz_app/services/api_service.dart';

final clientesProvider = StateNotifierProvider<ClientesNotifier, CatalogoClientes>((ref) {
  return ClientesNotifier(ref);
});

final isLoadingClientes = StateProvider<bool>((ref) => true);
final isSavingCliente = StateProvider<bool>((ref) => false);

class ClientesNotifier extends StateNotifier<CatalogoClientes> {
  final ApiService apiService;
  final Ref ref;
  
  ClientesNotifier(this.ref)
    : apiService = ApiService(),
      super(CatalogoClientes(clientes: []));

  Future<void> cargarClientes() async {
    try {
      ref.read(isLoadingClientes.notifier).state = true;
      
      final data = await apiService.getClientes();
      final clientes = data.map((item) => Cliente.fromJson(item)).toList();
      
      state = CatalogoClientes(clientes: clientes);
    } catch (e) {
      throw Exception('Error al cargar clientes: $e');
    } finally {
      ref.read(isLoadingClientes.notifier).state = false;
    }
  }

  Future<void> agregarCliente(Cliente cliente) async {
    try {
      ref.read(isSavingCliente.notifier).state = true;

      if (cliente.nombre.isEmpty) {
        throw 'El nombre del cliente es obligatorio';
      }

      final response = await apiService.agregarCliente(cliente.toJson());
      final nuevoCliente = Cliente.fromJson(response);
      state = CatalogoClientes(clientes: [...state.clientes, nuevoCliente]);
    } catch (e) {
      throw e;
    } finally {
      ref.read(isSavingCliente.notifier).state = false;
    }
  }

  Future<void> actualizarCliente(Cliente cliente) async {
    try {
      ref.read(isSavingCliente.notifier).state = true;
      
      final response = await apiService.actualizarCliente(cliente.id, cliente.toJson());
      final clienteActualizado = Cliente.fromJson(response);
      
      state = CatalogoClientes(
        clientes: state.clientes.map((c) => 
          c.id == clienteActualizado.id ? clienteActualizado : c
        ).toList()
      );
    } catch (e) {
      throw e;
    } finally {
      ref.read(isSavingCliente.notifier).state = false;
    }
  }

  Cliente? getClienteById(String clienteId) {
    try {
      return state.clientes.firstWhere((c) => c.id == clienteId);
    } catch (error) {
      return null;
    }
  }

  List<Cliente> buscarClientes(String query) {
    final searchTerm = query.toLowerCase();
    return state.clientes.where((cliente) =>
      cliente.nombre.toLowerCase().contains(searchTerm) ||
      cliente.apellidoPaterno != null && cliente.apellidoPaterno!.toLowerCase().contains(searchTerm) ||
      cliente.apellidoPaterno != null && cliente.telefono!.contains(searchTerm) ||
      cliente.apellidoPaterno != null && cliente.correo!.toLowerCase().contains(searchTerm)
    ).toList();
  }

  Future<void> eliminarCliente(String clienteId) async {
    try {
      await apiService.eliminarCliente(clienteId);
      state = CatalogoClientes(clientes: state.clientes.where((cliente) => cliente.id != clienteId).toList());
    } catch (e) {
      throw Exception('Error al eliminar el cliente: $e');
    }
  }
}