
class Cita {
 int? idCita;
 String? lugar;
 String? fecha;
 String? hora;
 String? anotaciones;
 int idPersona;

 Cita({
  this.idCita,
  this.lugar,
  this.fecha,
  this.hora,
  this.anotaciones,
  required this.idPersona,
 });

 factory Cita.fromMap(Map<String, dynamic> map) {
  return Cita(
   idCita: map['IDCITA'],
   lugar: map['LUGAR'],
   fecha: map['FECHA'],
   hora: map['HORA'],
   anotaciones: map['ANOTACIONES'],
   idPersona: map['IDPERSONA'],
  );
 }

 Map<String, dynamic> toJson() {
  return {
   'IDCITA': idCita,
   'LUGAR': lugar,
   'FECHA': fecha,
   'HORA': hora,
   'ANOTACIONES': anotaciones,
   'IDPERSONA': idPersona,
  };
 }
}