class Persona {
  int? idPersona;
  String nombre;
  String? telefono;

  Persona({
    this.idPersona,
    required this.nombre,
    this.telefono,
  });

  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      idPersona: map['IDPERSONA'],
      nombre: map['NOMBRE'],
      telefono: map['TELEFONO'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDPERSONA': idPersona,
      'NOMBRE': nombre,
      'TELEFONO': telefono,
    };
  }
}