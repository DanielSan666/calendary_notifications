import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calendary_notifications/Services/notifications_service.dart';

class EventService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<QuerySnapshot>? _eventsSubscription;
  Timer? _notificationRefreshTimer;
  int _refreshTrigger = 0;

  // Inicializa el listener de eventos en tiempo real
  void initEventListeners() {
    _eventsSubscription = _firestore
        .collection('eventos')
        .orderBy('fecha')
        .snapshots()
        .listen((snapshot) async {
          await _syncEventsAndNotifications(snapshot.docs);
          markForRefresh();
        });

    // Reprogramar notificaciones cada 6 meses para cumpleaños
    _notificationRefreshTimer = Timer.periodic(const Duration(days: 180), (_) {
      _refreshNotifications();
    });
  }

  Future<void> _refreshNotifications() async {
    final docs = await getEventos();
    await _syncEventsAndNotifications(docs);
  }

  // Sincroniza eventos y programa notificaciones
  Future<void> _syncEventsAndNotifications(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    await _notificationService.cancelAllNotifications();

    for (var doc in docs) {
      final data = doc.data();
      await _notificationService.scheduleEventNotifications(
        eventId: doc.id,
        title: data['nombre'],
        eventDate: (data['fecha'] as Timestamp).toDate(),
        description: data['descripcion'] ?? '',
        eventType: data['tipo'] ?? 'especial',
      );
    }
  }

  // Método para agregar un nuevo evento
  Future<String> agregarEvento({
    required String nombre,
    required String tipo,
    required DateTime fecha,
    String descripcion = '',
  }) async {
    try {
      final docRef = await _firestore.collection('eventos').add({
        'nombre': nombre,
        'tipo': tipo,
        'fecha': fecha,
        'descripcion': descripcion,
        'creadoEn': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception("Error al guardar evento: $e");
    }
  }

  // Método para editar un evento existente
  Future<void> editarEvento({
    required String idEvento,
    required String nombre,
    required String tipo,
    required DateTime fecha,
    String descripcion = '',
  }) async {
    try {
      await _firestore.collection('eventos').doc(idEvento).update({
        'nombre': nombre,
        'tipo': tipo,
        'fecha': fecha,
        'descripcion': descripcion,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error al actualizar evento: $e");
    }
  }

  // Método para eliminar un evento
  Future<void> eliminarEvento(String idEvento) async {
    try {
      await _firestore.collection('eventos').doc(idEvento).delete();
      await _notificationService.cancelScheduledNotifications(idEvento);
    } catch (e) {
      throw Exception("Error al eliminar evento: $e");
    }
  }

  // Método para obtener eventos
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getEventos() async {
    final snapshot =
        await _firestore.collection('eventos').orderBy('fecha').get();
    return snapshot.docs;
  }

  // Método para obtener eventos por mes
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getEventosPorMes(
    DateTime mes,
  ) async {
    final firstDay = DateTime(mes.year, mes.month, 1);
    final lastDay = DateTime(mes.year, mes.month + 1, 0);

    final snapshot =
        await _firestore
            .collection('eventos')
            .where('fecha', isGreaterThanOrEqualTo: firstDay)
            .where('fecha', isLessThanOrEqualTo: lastDay)
            .orderBy('fecha')
            .get();

    return snapshot.docs;
  }

  // Métodos para manejar el refresh
  void markForRefresh() {
    _refreshTrigger++;
    notifyListeners();
  }

  void resetRefresh() {
    _refreshTrigger = 0;
    notifyListeners();
  }

  int get refreshTrigger => _refreshTrigger;

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _notificationRefreshTimer?.cancel();
    super.dispose();
  }
}
