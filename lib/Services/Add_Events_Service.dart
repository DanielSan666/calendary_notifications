import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> agregarEvento({
  required String nombre,
  required String tipo,
  required DateTime fecha,
  String? descripcion,
}) async {
  // Crea una fecha sin componente horario (solo día, mes, año)
  final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);

  final evento = {
    'nombre': nombre,
    'tipo': tipo,
    'fecha': Timestamp.fromDate(fechaSinHora), // Guarda solo la fecha
    'descripcion': descripcion ?? '',
    'creado_en':
        FieldValue.serverTimestamp(), // Esto guarda la marca de tiempo del servidor
  };

  await FirebaseFirestore.instance.collection('eventos').add(evento);
}
