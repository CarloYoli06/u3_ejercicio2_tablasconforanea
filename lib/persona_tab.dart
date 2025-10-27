// persona_tab.dart
import 'package:flutter/material.dart';
import 'basedatosforaneas.dart';
import 'persona.dart';

class PersonaTab extends StatefulWidget {
  const PersonaTab({super.key});

  @override
  State<PersonaTab> createState() => _PersonaTabState();
}

class _PersonaTabState extends State<PersonaTab> {
  List<Persona> _personas = [];
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPersonas();
  }

  void _cargarPersonas() async {
    final personas = await DB.mostrarPersonas();
    setState(() {
      _personas = personas;
    });
  }

  void _mostrarFormulario([Persona? persona]) {
    // Si la persona no es nula, estamos editando
    if (persona != null) {
      _nombreController.text = persona.nombre;
      _telefonoController.text = persona.telefono ?? '';
    } else {
      // Si es nula, estamos creando, limpiamos los campos
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
      Navigator.pop(context); // Cierra el diálogo
      _cargarPersonas(); // Recarga la lista
    }
  }

  void _actualizarPersona(Persona persona) async {
    persona.nombre = _nombreController.text;
    persona.telefono = _telefonoController.text;
    await DB.actualizarPersona(persona);
    Navigator.pop(context); // Cierra el diálogo
    _cargarPersonas(); // Recarga la lista
  }

  void _eliminarPersona(int id) async {
    // Pedir confirmación
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
              _cargarPersonas();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _personas.length,
        itemBuilder: (context, index) {
          final persona = _personas[index];
          return ListTile(
            title: Text(persona.nombre),
            subtitle: Text(persona.telefono ?? 'Sin teléfono'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de Editar
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _mostrarFormulario(persona),
                ),
                // Botón de Eliminar
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarPersona(persona.idPersona!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        tooltip: 'Nueva Persona',
        child: const Icon(Icons.add),
      ),
    );
  }
}