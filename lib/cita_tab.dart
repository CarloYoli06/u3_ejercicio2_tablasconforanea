import 'package:flutter/material.dart';
import 'basedatosforaneas.dart';
import 'persona.dart';
import 'cita.dart';

class CitaTab extends StatefulWidget {
  final VoidCallback onDataChanged;

  const CitaTab({super.key, required this.onDataChanged});

  @override
  CitaTabState createState() => CitaTabState();
}


class CitaTabState extends State<CitaTab> {
  List<Map<String, dynamic>> _citasConNombre = [];
  List<Persona> _personasDisponibles = [];

  final _lugarController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _anotacionesController = TextEditingController();
  int? _personaSeleccionadaId; // Para el Dropdown

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }
  void cargarDatos() async {
    final citas = await DB.mostrarCitasConNombre();
    final personas = await DB.mostrarPersonas();
    if (mounted) {
      setState(() {
        _citasConNombre = citas;
        _personasDisponibles = personas;
      });
    }
  }

  void _mostrarFormulario([Map<String, dynamic>? citaMap]) {
    _personaSeleccionadaId = null;

    if (citaMap != null) {
      _lugarController.text = citaMap['LUGAR'] ?? '';
      _fechaController.text = citaMap['FECHA'] ?? '';
      _horaController.text = citaMap['HORA'] ?? '';
      _anotacionesController.text = citaMap['ANOTACIONES'] ?? '';
      _personaSeleccionadaId = citaMap['IDPERSONA'];
    } else {
      _lugarController.clear();
      _fechaController.clear();
      _horaController.clear();
      _anotacionesController.clear();
    }

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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(citaMap == null ? 'Nueva Cita' : 'Editar Cita'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        setDialogState(() {
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
    // 5. Llamar al callback
    widget.onDataChanged();
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
    // 6. Llamar al callback
    widget.onDataChanged();
  }

  void _eliminarCita(int id) async {
    await DB.eliminarCita(id);
    // 7. Llamar al callback
    widget.onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _citasConNombre.length,
        itemBuilder: (context, index) {
          final cita = _citasConNombre[index];
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