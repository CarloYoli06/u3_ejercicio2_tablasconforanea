# 📅 Gestor de Citas y Personas (Flutter + SQLite)

Este proyecto es una aplicación móvil desarrollada con **Flutter** que utiliza la base de datos **SQLite** (a través del paquete `sqflite`) para gestionar personas y sus citas asociadas.

La aplicación está estructurada con pestañas (Tabs) que permiten navegar entre las siguientes funcionalidades:

1.  **Personas:** Gestionar la lista de personas (Crear, Leer, Actualizar, Eliminar). Incluye **Búsqueda por nombre** y **Eliminación por deslizamiento (Dismissible)**.
2.  **Citas:** Gestionar las citas (CRUD), asociándolas a una persona existente. Incluye **Selectores de Fecha/Hora** para ingreso de datos preciso y **Eliminación por deslizamiento (Dismissible)**.
3.  **Próximas:** Visualizar una lista ordenada de **citas de hoy y futuras**. Resalta visualmente las citas programadas para el día actual.

## 🛠️ Requisitos

* **Flutter SDK** instalado y configurado.
* Conocimientos básicos de **Dart** y **Flutter**.
* Conocimientos básicos de bases de datos **SQLite**.

## 🚀 Instalación y Ejecución

Sigue estos pasos para poner en marcha el proyecto:

1.  **Clonar el repositorio o descargar los archivos:**
    ```bash
    git clone [https://github.com/CarloYoli06/u3_ejercicio2_tablasconforanea](https://github.com/CarloYoli06/u3_ejercicio2_tablasconforanea)
    cd u3_ejercicio2_tablasconforanea
    ```

2.  **Obtener las dependencias:**
    Ejecuta el siguiente comando en la terminal desde la raíz del proyecto para descargar todos los paquetes necesarios (`sqflite` y `path`):
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

| Archivo | Descripción |
| :--- | :--- |
| `main.dart` | Punto de entrada de la aplicación. |
| `home_page.dart` | Contiene el `DefaultTabController` y gestiona las tres pestañas principales (`Personas`, `Citas`, `Proximas`). |
| `persona.dart` | Modelo de datos (`class Persona`) y lógica de serialización para la entidad Persona. |
| `cita.dart` | Modelo de datos (`class Cita`) y lógica de serialización para la entidad Cita. |
| `basedatosforaneas.dart` | Clase `DB` para la conexión y operaciones **CRUD** en SQLite (`sqflite`). Contiene la lógica para tablas `PERSONA` y `CITA` con la relación de clave foránea (`ON DELETE CASCADE`). |
| `persona_tab.dart` | Interfaz de usuario y lógica para la gestión de Personas (Lista, Formulario CRUD, Búsqueda, Dismissible). |
| `cita_tab.dart` | Interfaz de usuario y lógica para la gestión de Citas (Lista, Formulario CRUD con `DropdownButton` para Persona y **Date/Time Pickers**). |
| `hoy_tab.dart` | Interfaz de usuario y lógica para listar las citas de **Hoy y Futuras**, ordenadas por fecha y hora, resaltando las de hoy. |

## ✨ Funcionalidades Destacadas (Imágenes)

Aquí se muestran algunas de las interacciones clave de la aplicación:
![](https://github.com/CarloYoli06/u3_ejercicio2_tablasconforanea/blob/main/Eliminar.png)
![](https://github.com/CarloYoli06/u3_ejercicio2_tablasconforanea/blob/main/Citasvista.png)
![](https://github.com/CarloYoli06/u3_ejercicio2_tablasconforanea/blob/main/Personas.png)

### Personas (Formulario y Eliminación)

Permite registrar nuevas personas y editarlas. La eliminación es segura gracias a un diálogo de confirmación, incluso al deslizar.

| Registro de Persona | Confirmación de Eliminación |
| :---: | :---: |
|  |  |

### Próximas Citas (Hoy y Futuro)

Muestra una vista limpia de las citas futuras. Las citas de hoy se resaltan con un icono de advertencia y un color de fondo diferente para mayor visibilidad.

| Vista de Próximas Citas |
| :---: |
|  |

## 🔗 Dependencias Clave

Este proyecto utiliza las siguientes dependencias clave para su funcionalidad:

* `sqflite`: Para la gestión de la base de datos local SQLite.
* `path`: Para construir rutas de archivos compatibles con el sistema.
