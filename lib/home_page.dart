import 'package:flutter/material.dart';
import 'persona_tab.dart';
import 'cita_tab.dart';
import 'hoy_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _personaTabKey = GlobalKey<PersonaTabState>();
  final _citaTabKey = GlobalKey<CitaTabState>();
  final _hoyTabKey = GlobalKey<HoyTabState>();


  void _refreshAllTabs() {
    _personaTabKey.currentState?.cargarPersonas();
    _citaTabKey.currentState?.cargarDatos();
    _hoyTabKey.currentState?.cargarCitas();
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestor de Citas y Personas'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Personas', icon: Icon(Icons.person)),
              Tab(text: 'Citas', icon: Icon(Icons.calendar_month)),
              Tab(text: 'Proximas', icon: Icon(Icons.today)), // <--- NUEVO
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PersonaTab(key: _personaTabKey, onDataChanged: _refreshAllTabs),
            CitaTab(key: _citaTabKey, onDataChanged: _refreshAllTabs),
            HoyTab(key: _hoyTabKey, onDataChanged: _refreshAllTabs), // <--- NUEVO
          ],
        ),
      ),
    );
  }
}