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

      if (eventType == 'cumpleaños') {
        await _scheduleBirthdayNotifications(
          eventId: eventId,
          title: title,
          eventDay: eventDate.day,
          eventMonth: eventDate.month,
          description: description,
          now: now,
          localTimeZone: localTimeZone,
        );
      } else {
        await _scheduleRegularEventNotifications(
          eventId: eventId,
          title: title,
          eventDate: eventDate,
          description: description,
          now: now,
          localTimeZone: localTimeZone,
        );
      }
    } catch (e) {
      debugPrint("Error al programar notificaciones: $e");
    }
  }

  Future<void> _scheduleBirthdayNotifications({
    required String eventId,
    required String title,
    required int eventDay,
    required int eventMonth,
    required String? description,
    required tz.TZDateTime now,
    required tz.Location localTimeZone,
  }) async {
    // Notificación 1 día antes
    var notificationYear = now.year;
    var dayBefore = tz.TZDateTime(
      localTimeZone,
      notificationYear,
      eventMonth,
      eventDay - 1,
      9, // Hora: 9 AM
      0,
    );

    // Si ya pasó la fecha este año, programar para el próximo año
    if (dayBefore.isBefore(now)) {
      notificationYear++;
      dayBefore = tz.TZDateTime(
        localTimeZone,
        notificationYear,
        eventMonth,
        eventDay - 1,
        9,
        0,
      );
    }

    await _scheduleNotification(
      id: eventId.hashCode,
      title: '🎉 Mañana es un cumpleaños!',
      body:
          'No olvides que mañana es el cumpleaños de $title${description?.isNotEmpty ?? false ? '\n\n$description' : ''}',
      scheduledDate: dayBefore,
      payload: {'eventId': eventId, 'type': 'day_before'},
    );

    // Notificación el día del cumpleaños
    final dayOf = tz.TZDateTime(
      localTimeZone,
      notificationYear,
      eventMonth,
      eventDay,
      9, // Hora: 9 AM
      0,
    );

    await _scheduleNotification(
      id: (eventId.hashCode + 1),
      title: '🎂 ¡Feliz cumpleaños!',
      body:
          'Hoy es el cumpleaños de $title 🎉${description?.isNotEmpty ?? false ? '\n\n$description' : ''}',
      scheduledDate: dayOf,
      payload: {'eventId': eventId, 'type': 'day_of'},
    );
  }

  Future<void> _scheduleRegularEventNotifications({
    required String eventId,
    required String title,
    required DateTime eventDate,
    required String? description,
    required tz.TZDateTime now,
    required tz.Location localTimeZone,
  }) async {
    // Notificación 1 día antes
    final dayBefore = tz.TZDateTime(
      localTimeZone,
      eventDate.year,
      eventDate.month,
      eventDate.day - 1,
      9, // Hora: 9 AM
      0,
    );

    if (dayBefore.isAfter(now)) {
      await _scheduleNotification(
        id: eventId.hashCode,
        title: '📅 Recordatorio de evento',
        body:
            'Mañana tienes este evento: $title${description?.isNotEmpty ?? false ? '\n\n$description' : ''}',
        scheduledDate: dayBefore,
        payload: {'eventId': eventId, 'type': 'day_before'},
      );
    }

    // Notificación el día del evento
    final dayOf = tz.TZDateTime(
      localTimeZone,
      eventDate.year,
      eventDate.month,
      eventDate.day,
      9, // Hora: 9 AM
      0,
    );

    if (dayOf.isAfter(now)) {
      await _scheduleNotification(
        id: (eventId.hashCode + 1),
        title: '⏰ ¡Hoy es el día!',
        body:
            'No olvides que hoy tienes: $title${description?.isNotEmpty ?? false ? '\n\n$description' : ''}',
        scheduledDate: dayOf,
        payload: {'eventId': eventId, 'type': 'day_of'},
      );
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
