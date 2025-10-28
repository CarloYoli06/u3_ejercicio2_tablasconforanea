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
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _citasConNombre = [];
  List<Persona> _personasDisponibles = [];

  final _lugarController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _anotacionesController = TextEditingController();
  int? _personaSeleccionadaId;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _fechaController.text = formattedDate;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formattedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      _horaController.text = formattedTime;
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
          content: Text(
              'Error: Debes registrar al menos una persona antes de crear una cita.'),
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
                child: Form(
                  key: _formKey,
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
                        validator: (value) =>
                        value == null ? 'Debe seleccionar una persona' : null,
                      ),
                      TextFormField(
                        controller: _lugarController,
                        decoration: const InputDecoration(labelText: 'Lugar'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El lugar es requerido';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _fechaController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La fecha es requerida';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _horaController,
                        readOnly: true,
                        onTap: () => _selectTime(context),
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La hora es requerida';
                          }
                          return null;
                        },
                      ),
                      TextField(
                        controller: _anotacionesController,
                        decoration:
                        const InputDecoration(labelText: 'Anotaciones'),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (citaMap == null) {
                        _insertarCita();
                      } else {
                        _actualizarCita(citaMap['IDCITA']);
                      }
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
      lugar: _lugarController.text.trim(),
      fecha: _fechaController.text.trim(),
      hora: _horaController.text.trim(),
      anotaciones: _anotacionesController.text.trim(),
    );
    await DB.insertarCita(nuevaCita);
    Navigator.pop(context);

    widget.onDataChanged();
  }

  void _actualizarCita(int idCita) async {
    final citaActualizada = Cita(
      idCita: idCita,
      idPersona: _personaSeleccionadaId!,
      lugar: _lugarController.text.trim(),
      fecha: _fechaController.text.trim(),
      hora: _horaController.text.trim(),
      anotaciones: _anotacionesController.text.trim(),
    );
    await DB.actualizarCita(citaActualizada);
    Navigator.pop(context);

    widget.onDataChanged();
  }

  void _eliminarCita(int id) async {
    await DB.eliminarCita(id);

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
          final idCita = cita['IDCITA'];

          return Dismissible(
            key: Key('cita-$idCita'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white, size: 30),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar Eliminación'),
                  content: const Text('¿Estás seguro de que quieres eliminar esta cita?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              _eliminarCita(idCita);
            },
            child: ListTile(
              title: Text('Cita con: $nombrePersona'),
              subtitle:
              Text('$lugar \n$fechaHora \n${cita['ANOTACIONES'] ?? ''}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _mostrarFormulario(cita),
              ),
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