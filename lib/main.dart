import 'package:flutter/material.dart';
import 'package:calendary_notifications/Screens/Eventos_Screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart'; // Añade esta importación
import 'firebase_options.dart'; // Añade esta importación (se genera automáticamente)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa formato de fechas para español
  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Eventos',
      debugShowCheckedModeBanner: false,
      home: const EventosScreen(),
    );
  }
}
