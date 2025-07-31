import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> editarEvento({
  required String idEvento,
  required String nombre,
  required String tipo,
  required DateTime fecha,
  required String descripcion,
}) async {
  await FirebaseFirestore.instance.collection('eventos').doc(idEvento).update({
    'nombre': nombre,
    'tipo': tipo,
    'fecha': Timestamp.fromDate(fecha),
    'descripcion': descripcion,
  });
}

Future<void> eliminarEvento(String idEvento) async {
  await FirebaseFirestore.instance.collection('eventos').doc(idEvento).delete();
}
