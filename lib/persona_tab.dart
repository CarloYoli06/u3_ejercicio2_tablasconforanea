// persona_tab.dart
import 'package:flutter/material.dart';
import 'basedatosforaneas.dart';
import 'persona.dart';

class PersonaTab extends StatefulWidget {

  final VoidCallback onDataChanged;

  const PersonaTab({super.key, required this.onDataChanged});

  @override
  PersonaTabState createState() => PersonaTabState();
}

class PersonaTabState extends State<PersonaTab> {
  List<Persona> _personas = [];
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _filtroController = TextEditingController(); // NUEVO: Controlador para el filtro

  @override
  void initState() {
    super.initState();
    cargarPersonas();
    _filtroController.addListener(_onFilterChanged); // NUEVO: Escuchador para el filtro
  }

  @override
  void dispose() {
    _filtroController.removeListener(_onFilterChanged);
    _filtroController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    setState(() {
      // Forzar un redraw para aplicar el filtro
    });
  }

  void cargarPersonas() async {
    final personas = await DB.mostrarPersonas();
    if (mounted) {
      setState(() {
        _personas = personas;
      });
    }
  }

  void _mostrarFormulario([Persona? persona]) {
    if (persona != null) {
      _nombreController.text = persona.nombre;
      _telefonoController.text = persona.telefono ?? '';
    } else {
      _nombreController.clear();
      _telefonoController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(persona == null ? 'Nueva Persona' : 'Editar Persona'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (persona == null) {
                  _insertarPersona();
                } else {
                  _actualizarPersona(persona);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _insertarPersona() async {
    final nombre = _nombreController.text;
    final telefono = _telefonoController.text;
    if (nombre.isNotEmpty) {
      final nuevaPersona = Persona(nombre: nombre, telefono: telefono);
      await DB.insertarPersona(nuevaPersona);
      Navigator.pop(context);
      widget.onDataChanged();
    }
  }

  void _actualizarPersona(Persona persona) async {
    persona.nombre = _nombreController.text;
    persona.telefono = _telefonoController.text;
    await DB.actualizarPersona(persona);
    Navigator.pop(context);
    widget.onDataChanged();
  }

  void _eliminarPersona(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
            '¿Seguro que quieres eliminar esta persona? Todas sus citas asociadas también se borrarán.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await DB.eliminarPersona(id);
              Navigator.pop(context);
              widget.onDataChanged();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtro = _filtroController.text.toLowerCase();
    final personasFiltradas = _personas.where((p) {
      return p.nombre.toLowerCase().contains(filtro);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filtroController,
              decoration: const InputDecoration(
                labelText: 'Buscar Persona',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: personasFiltradas.length,
              itemBuilder: (context, index) {
                final persona = personasFiltradas[index];
                return Dismissible(
                  key: Key('persona-${persona.idPersona}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  confirmDismiss: (direction) async {
                    // Muestra el diálogo de confirmación ya existente
                    bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: const Text(
                            '¿Seguro que quieres eliminar esta persona? Todas sus citas asociadas también se borrarán.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _eliminarPersona(persona.idPersona!); // La lógica de eliminar está en _eliminarPersona
                    }
                    return false; // Retornamos false para manejar la eliminación explícitamente y no con onDismissed
                  },
                  onDismissed: (direction) {
                    // No hace falta lógica aquí ya que se maneja en confirmDismiss
                  },
                  child: ListTile(
                    title: Text(persona.nombre),
                    subtitle: Text(persona.telefono ?? 'Sin teléfono'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _mostrarFormulario(persona),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        tooltip: 'Nueva Persona',
        child: const Icon(Icons.add),
      ),
    );
  }
}