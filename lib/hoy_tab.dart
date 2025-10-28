import 'package:flutter/material.dart';
import 'basedatosforaneas.dart';

class HoyTab extends StatefulWidget {

  final VoidCallback onDataChanged;

  const HoyTab({super.key, required this.onDataChanged});

  @override

  HoyTabState createState() => HoyTabState();
}


class HoyTabState extends State<HoyTab> {
  List<Map<String, dynamic>> _citasHoyYFuturas = [];

  @override
  void initState() {
    super.initState();
    cargarCitas();
  }

  void cargarCitas() async {
    final citas = await DB.mostrarCitasHoyYFuturas();
    if (mounted) {
      setState(() {
        _citasHoyYFuturas = citas;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_citasHoyYFuturas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes citas programadas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              '¡Añade una en la pestaña "Citas"!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final todayDate = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    return Scaffold(
      body: ListView.builder(
        itemCount: _citasHoyYFuturas.length,
        itemBuilder: (context, index) {
          final cita = _citasHoyYFuturas[index];
          final nombrePersona = cita['NOMBRE'] ?? 'Persona desconocida';
          final lugar = cita['LUGAR'] ?? 'Sin lugar';
          final fecha = cita['FECHA'] ?? 'Sin fecha';
          final hora = cita['HORA'] ?? 'Sin hora';
          final anotaciones = cita['ANOTACIONES'] ?? '';

          final isToday = fecha == todayDate;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            elevation: 3,
            color: isToday ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isToday ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                child: Icon(isToday ? Icons.warning_amber : Icons.calendar_month),
              ),
              title: Text(
                '$fecha - $hora',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isToday ? Theme.of(context).colorScheme.error : null,
                ),
              ),
              subtitle: Text('Con: $nombrePersona \nLugar: $lugar \nNotas: $anotaciones'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}