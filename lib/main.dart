import 'package:calendary_notifications/Services/Event_Service.dart';
import 'package:calendary_notifications/Services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:calendary_notifications/Screens/Eventos_Screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_ES', null);

  // Inicializa el servicio de notificaciones
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermission();

  // Inicializa el servicio de eventos y escucha cambios en tiempo real
  final eventService = EventService();
  eventService.initEventListeners(); // Activa el listener

  runApp(
    ChangeNotifierProvider(
      create: (context) => eventService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Eventos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const EventosScreen(),
    );
  }
}
