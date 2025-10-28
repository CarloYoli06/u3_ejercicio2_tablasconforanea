# 📅 Gestor de Citas y Personas (Flutter + SQLite)

Este proyecto es una aplicación móvil desarrollada con **Flutter** que utiliza la base de datos **SQLite** (a través del paquete `sqflite`) para gestionar personas y sus citas asociadas.

La aplicación está estructurada con pestañas (Tabs) que permiten navegar entre las siguientes funcionalidades:

1.  **Personas:** Gestionar la lista de personas (Crear, Leer, Actualizar, Eliminar).
2.  **Citas:** Gestionar las citas, asociándolas a una persona existente mediante una clave foránea.
3.  **Calendario:** Visualizar un calendario interactivo donde se resaltan los días con citas programadas y se listan las citas del día seleccionado.

## 🛠️ Requisitos

* **Flutter SDK** instalado y configurado.
* Conocimientos básicos de **Dart** y **Flutter**.
* Conocimientos básicos de bases de datos **SQLite**.

## 🚀 Instalación y Ejecución

Sigue estos pasos para poner en marcha el proyecto:

1.  **Clonar el repositorio o descargar los archivos:**
    ```bash
    git clone https://github.com/CarloYoli06/u3_ejercicio2_tablasconforanea
    cd u3_ejercicio2_tablasconforanea
    ```

2.  **Obtener las dependencias:**
    Ejecuta el siguiente comando en la terminal desde la raíz del proyecto para descargar todos los paquetes necesarios (incluyendo `sqflite` y `table_calendar`):
    ```bash
    flutter pub get
    ```

3.  **Ejecutar la aplicación:**
    Asegúrate de tener un emulador o un dispositivo conectado y ejecuta:
    ```bash
    flutter run
    ```

## 📂 Estructura del Proyecto

La lógica principal de la aplicación se encuentra en la carpeta `lib`.

[**Enlace a la carpeta `lib` (Google Drive)**](https://drive.google.com/drive/folders/1kgqzTBOG2GwehiNNYrB2JLn1eDByi78C?usp=drive_link)

| Archivo | Descripción |
| :--- | :--- |
| `main.dart` | Punto de entrada de la aplicación. |
| `home_page.dart` | Contiene el `DefaultTabController` y gestiona las pestañas principales. |
| `persona.dart` | Modelo de datos para la entidad Persona. |
| `cita.dart` | Modelo de datos para la entidad Cita. |
| `basedatosforaneas.dart` | Clase `DB` con métodos para la conexión y operaciones CRUD en SQLite para `PERSONA` y `CITA` (incluye joins y consultas específicas para el calendario). |
| `persona_tab.dart` | Interfaz de usuario y lógica para la gestión de Personas. |
| `cita_tab.dart` | Interfaz de usuario y lógica para la gestión de Citas. |
| `calendario_tab.dart` | Interfaz de usuario y lógica para la visualización de citas en un calendario. **(Requiere `table_calendar`)** |

## 🔗 Dependencias Clave

Este proyecto utiliza las siguientes dependencias clave para su funcionalidad:

* `sqflite`: Para la gestión de la base de datos local SQLite.
* `path`: Para construir rutas de archivos compatibles con el sistema.
* `table_calendar`: Para la implementación del widget de calendario en la pestaña "Calendario".