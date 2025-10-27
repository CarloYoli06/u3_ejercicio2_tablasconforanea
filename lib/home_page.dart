import 'package:flutter/material.dart';
import 'persona_tab.dart';
import 'cita_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // DefaultTabController es la forma más fácil de conectar
    // una TabBar (las pestañas) con un TabBarView (el contenido)
    return DefaultTabController(
      length: 2, // El número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestor de Citas y Personas'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // El 'bottom' del AppBar es el lugar perfecto para la TabBar
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Personas', icon: Icon(Icons.person)),
              Tab(text: 'Citas', icon: Icon(Icons.calendar_month)),
            ],
          ),
        ),
        // TabBarView contiene las pantallas para cada pestaña
        body: const TabBarView(
          children: [
            // Pantalla 1
            PersonaTab(),
            // Pantalla 2
            CitaTab(),
          ],
        ),
      ),
    );
  }
}