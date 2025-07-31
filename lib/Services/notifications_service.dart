import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Configuración del canal
  static const String channelId = 'event_reminders';
  static const String channelName = 'Recordatorios de Eventos';
  static const String channelDesc =
      'Notificaciones para recordatorios de eventos';

  // Inicializa el servicio
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: channelId,
        channelName: channelName,
        channelDescription: channelDesc,
        importance: NotificationImportance.High,
        defaultColor: Colors.purple,
        ledColor: Colors.purple,
        playSound: true,
        enableVibration: true,
      ),
    ]);
    tz.initializeTimeZones(); // Configura zonas horarias
  }

  // Programa notificaciones para un evento
  Future<void> scheduleEventNotifications({
    required String eventId,
    required String title,
    required DateTime eventDate,
    required String? description,
    required String eventType,
  }) async {
    try {
      await cancelScheduledNotifications(eventId);

      final localTimeZone = tz.local;
      final now = tz.TZDateTime.now(localTimeZone);

      // Notificación 1 día antes a las 9 AM
      final dayBefore = tz.TZDateTime(
        localTimeZone,
        eventDate.year,
        eventDate.month,
        eventDate.day - 1, // Día anterior
        9, // Hora: 9 AM
        0, // Minutos
      );

      if (dayBefore.isAfter(now)) {
        String dayBeforeTitle = '';
        String dayBeforeBody = '';

        if (eventType == 'cumpleaños') {
          dayBeforeTitle = '🎉 Mañana es un cumpleaños!';
          dayBeforeBody = 'No olvides que mañana es el cumpleaños de $title';
        } else {
          dayBeforeTitle = '📅 Recordatorio de evento';
          dayBeforeBody = 'Mañana tienes este evento: $title';
        }

        if (description?.isNotEmpty ?? false) {
          dayBeforeBody += '\n\n$description';
        }

        await _scheduleNotification(
          id: eventId.hashCode,
          title: dayBeforeTitle,
          body: dayBeforeBody,
          scheduledDate: dayBefore,
          payload: {'eventId': eventId, 'type': 'day_before'},
        );
      }

      // Notificación el día del evento a las 9 AM
      final dayOf = tz.TZDateTime(
        localTimeZone,
        eventDate.year,
        eventDate.month,
        eventDate.day,
        9, // Hora: 9 AM
        0, // Minutos
      );

      if (dayOf.isAfter(now)) {
        String dayOfTitle = '';
        String dayOfBody = '';

        if (eventType == 'cumpleaños') {
          dayOfTitle = '🎂 ¡Feliz cumpleaños!';
          dayOfBody = 'Hoy es el cumpleaños de $title 🎉';
        } else {
          dayOfTitle = '⏰ ¡Hoy es el día!';
          dayOfBody = 'No olvides que hoy tienes: $title';
        }

        if (description?.isNotEmpty ?? false) {
          dayOfBody += '\n\n$description';
        }

        await _scheduleNotification(
          id: (eventId.hashCode + 1),
          title: dayOfTitle,
          body: dayOfBody,
          scheduledDate: dayOf,
          payload: {'eventId': eventId, 'type': 'day_of'},
        );
      }
    } catch (e) {
      debugPrint("Error al programar notificaciones: $e");
    }
  }

  // Programa una notificación individual
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required Map<String, String> payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelId,
        title: title,
        body: body,
        payload: payload,
      ),
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        timeZone: tz.local.name,
        allowWhileIdle: true,
      ),
    );
  }

  // Cancela notificaciones de un evento
  Future<void> cancelScheduledNotifications(String eventId) async {
    await AwesomeNotifications().cancel(eventId.hashCode);
    await AwesomeNotifications().cancel(eventId.hashCode + 1);
  }

  // Cancela TODAS las notificaciones
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Solicita permisos
  Future<void> requestPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}
