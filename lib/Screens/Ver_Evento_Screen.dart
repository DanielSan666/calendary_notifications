import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EventosDelMesScreen.dart';

class VerEventoScreen extends StatefulWidget {
  const VerEventoScreen({super.key});

  @override
  State<VerEventoScreen> createState() => _VerEventoScreenState();
}

class _VerEventoScreenState extends State<VerEventoScreen> {
  final List<String> meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  final List<Color> colores = [
    Color(0xFFDCEBFF),
    Color(0xFFFFD9E0),
    Color(0xFFDFFFF2),
    Color(0xFFFFFFC7),
    Color(0xFFF0E3FF),
    Color(0xFFD6E7FF),
    Color(0xFFFFE2DE),
    Color(0xFFFFEDD5),
    Color(0xFFD8FFF9),
    Color(0xFFD8F7FF),
    Color(0xFFFFF3C2),
    Color(0xFFE1FFEC),
  ];

  final List<IconData> iconosMeses = [
    Icons.ac_unit, // Enero
    Icons.favorite, // Febrero
    Icons.local_florist, // Marzo
    Icons.wb_sunny, // Abril
    Icons.park, // Mayo
    Icons.beach_access, // Junio
    Icons.wb_sunny_outlined, // Julio
    Icons.icecream, // Agosto
    Icons.school, // Septiembre
    Icons.emoji_nature, // Octubre
    Icons.food_bank, // Noviembre
    Icons.star, // Diciembre
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Eventos por Mes',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('eventos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventos = snapshot.data?.docs ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final mesNumero = index + 1;
                final eventosMes =
                    eventos.where((doc) {
                      final fecha = (doc['fecha'] as Timestamp).toDate();
                      return fecha.month == mesNumero;
                    }).length;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventosDelMesScreen(mes: meses[index]),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colores[index],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          iconosMeses[index],
                          size: 28,
                          color: Colors.black54,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meses[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          eventosMes == 0
                              ? 'Sin eventos'
                              : '$eventosMes evento${eventosMes != 1 ? "s" : ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                eventosMes == 0 ? Colors.black54 : Colors.green,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
