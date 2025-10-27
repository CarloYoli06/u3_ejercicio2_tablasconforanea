// cita_tab.dart
import 'package:flutter/material.dart';
import 'basedatosforaneas.dart';
import 'persona.dart';
import 'cita.dart';

class CitaTab extends StatefulWidget {
  const CitaTab({super.key});

  @override
  State<CitaTab> createState() => _CitaTabState();
}

class _CitaTabState extends State<CitaTab> {
  List<Map<String, dynamic>> _citasConNombre = [];
  List<Persona> _personasDisponibles = [];

  // Controladores para el formulario
  final _lugarController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _anotacionesController = TextEditingController();
  int? _personaSeleccionadaId; // Para el Dropdown

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
    // Cargamos ambos, las citas y las personas (para el dropdown)
    final citas = await DB.mostrarCitasConNombre();
    final personas = await DB.mostrarPersonas();
    setState(() {
      _citasConNombre = citas;
      _personasDisponibles = personas;
    });
  }

  void _mostrarFormulario([Map<String, dynamic>? citaMap]) {
    _personaSeleccionadaId = null; // Resetea la selección

    if (citaMap != null) {
      // Editando: cargamos los datos existentes
      _lugarController.text = citaMap['LUGAR'] ?? '';
      _fechaController.text = citaMap['FECHA'] ?? '';
      _horaController.text = citaMap['HORA'] ?? '';
      _anotacionesController.text = citaMap['ANOTACIONES'] ?? '';
      _personaSeleccionadaId = citaMap['IDPERSONA'];
    } else {
      // Creando: limpiamos los campos
      _lugarController.clear();
      _fechaController.clear();
      _horaController.clear();
      _anotacionesController.clear();
    }

    // Validar que haya personas antes de abrir el formulario
    if (_personasDisponibles.isEmpty && citaMap == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Debes registrar al menos una persona antes de crear una cita.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        // Usamos StatefulBuilder para que el Dropdown se actualice
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(citaMap == null ? 'Nueva Cita' : 'Editar Cita'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // El Dropdown para seleccionar la Persona (Llave Foránea)
                    DropdownButtonFormField<int>(
                      value: _personaSeleccionadaId,
                      hint: const Text('Seleccionar Persona'),
                      items: _personasDisponibles.map((persona) {
                        return DropdownMenuItem<int>(
                          value: persona.idPersona,
                          child: Text(persona.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() { // Actualiza el estado del diálogo
                          _personaSeleccionadaId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Campo requerido' : null,
                    ),
                    TextField(
                      controller: _lugarController,
                      decoration: const InputDecoration(labelText: 'Lugar'),
                    ),
                    TextField(
                      controller: _fechaController,
                      decoration: const InputDecoration(labelText: 'Fecha (ej. YYYY-MM-DD)'),
                      keyboardType: TextInputType.datetime,
                    ),
                    TextField(
                      controller: _horaController,
                      decoration: const InputDecoration(labelText: 'Hora (ej. HH:MM)'),
                      keyboardType: TextInputType.datetime,
                    ),
                    TextField(
                      controller: _anotacionesController,
                      decoration: const InputDecoration(labelText: 'Anotaciones'),
                      textCapitalization: TextCapitalization.sentences,
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
                    if (_personaSeleccionadaId == null) {
                      // Mostrar error si no se seleccionó persona
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debe seleccionar una persona.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (citaMap == null) {
                      _insertarCita();
                    } else {
                      _actualizarCita(citaMap['IDCITA']);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _insertarCita() async {
    final nuevaCita = Cita(
      idPersona: _personaSeleccionadaId!,
      lugar: _lugarController.text,
      fecha: _fechaController.text,
      hora: _horaController.text,
      anotaciones: _anotacionesController.text,
    );
    await DB.insertarCita(nuevaCita);
    Navigator.pop(context);
    _cargarDatos();
  }

  void _actualizarCita(int idCita) async {
    final citaActualizada = Cita(
      idCita: idCita,
      idPersona: _personaSeleccionadaId!,
      lugar: _lugarController.text,
      fecha: _fechaController.text,
      hora: _horaController.text,
      anotaciones: _anotacionesController.text,
    );
    await DB.actualizarCita(citaActualizada);
    Navigator.pop(context);
    _cargarDatos();
  }

  void _eliminarCita(int id) async {
    await DB.eliminarCita(id);
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _citasConNombre.length,
        itemBuilder: (context, index) {
          final cita = _citasConNombre[index];
          // Usamos los datos del JOIN
          final nombrePersona = cita['NOMBRE'] ?? 'Persona desconocida';
          final lugar = cita['LUGAR'] ?? 'Sin lugar';
          final fechaHora = '${cita['FECHA'] ?? ''} - ${cita['HORA'] ?? ''}';

          return ListTile(
            title: Text('Cita con: $nombrePersona'),
            subtitle: Text('$lugar \n$fechaHora \n${cita['ANOTACIONES'] ?? ''}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _mostrarFormulario(cita),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarCita(cita['IDCITA']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        tooltip: 'Nueva Cita',
        child: const Icon(Icons.add),
      ),
    );
  }
}