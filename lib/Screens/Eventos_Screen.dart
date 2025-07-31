import 'package:calendary_notifications/Screens/Agregar_Evento_Screen.dart';
import 'package:calendary_notifications/Screens/Ver_Evento_Screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventosScreen extends StatelessWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1FC),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🎉 Mis Eventos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Imagen decorativa (asegúrate de tenerla en assets/)
                Image.asset(
                  'assets/img/icon.jpeg', // o la ruta que tú uses
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 20),

                const Text(
                  'Gestiona cumpleaños y eventos especiales',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                EventoCard(
                  icon: Icons.add_circle,
                  iconColor: Colors.green,
                  title: 'Agregar Evento',
                  subtitle: 'Añade un nuevo cumpleaños o evento especial',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgregarEventoScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                EventoCard(
                  icon: Icons.calendar_month,
                  iconColor: Colors.blue,
                  title: 'Ver por Meses',
                  subtitle: 'Explora tus eventos organizados por mes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerEventoScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('eventos')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Cargando...');
                    }

                    final total = snapshot.data?.docs.length ?? 0;

                    return Text.rich(
                      TextSpan(
                        text: 'Total de eventos: ',
                        style: const TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: '$total',
                            style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const EventoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
