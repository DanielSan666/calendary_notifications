import 'package:calendary_notifications/Screens/Agregar_Evento_Screen.dart';
import 'package:calendary_notifications/Screens/Editar_Evento_Screen.dart';
import 'package:calendary_notifications/Services/Functions_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';

class EventosDelMesScreen extends StatelessWidget {
  final String mes;

  const EventosDelMesScreen({super.key, required this.mes});

  int obtenerNumeroMes(String nombreMes) {
    const meses = [
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
    return meses.indexOf(nombreMes) + 1;
  }

  void mostrarToastEliminado(BuildContext context) {
    DelightToastBar(
      builder:
          (context) => const ToastCard(
            leading: Icon(Icons.delete_forever, size: 28, color: Colors.red),
            title: Text(
              'Evento eliminado',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: Durations.extralong4,
    ).show(context);
  }

  void mostrarToastError(BuildContext context, Object error) {
    DelightToastBar(
      builder:
          (context) => ToastCard(
            leading: const Icon(Icons.error, size: 28, color: Colors.red),
            title: Text(
              'Error al eliminar: $error',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      snackbarDuration: Durations.extralong4,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final int mesNumero = obtenerNumeroMes(mes);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5FF),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarEventoScreen()),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.card_giftcard, color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('eventos').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final eventos =
                snapshot.data!.docs.where((doc) {
                  final fecha = (doc['fecha'] as Timestamp).toDate();
                  return fecha.month == mesNumero;
                }).toList();

            final cantidadCumple =
                eventos.where((e) => e['tipo'] == 'cumpleaños').length;
            final cantidadEspecial =
                eventos.where((e) => e['tipo'] == 'especial').length;

            final eventosPorDia = <int, List<DocumentSnapshot>>{};
            for (var evento in eventos) {
              final fecha = (evento['fecha'] as Timestamp).toDate();
              eventosPorDia.putIfAbsent(fecha.day, () => []).add(evento);
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const BackButton(color: Colors.black),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mes,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${eventos.length} eventos este mes',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                "🎂 $cantidadCumple",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Cumpleaños",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.pink[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                "🎉 $cantidadEspecial",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Eventos",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      eventos.isEmpty
                          ? const Center(
                            child: Text(
                              'No hay eventos en este mes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : ListView.builder(
                            itemCount: eventosPorDia.length,
                            itemBuilder: (context, index) {
                              final dia = eventosPorDia.keys.elementAt(index);
                              final eventosDelDia = eventosPorDia[dia]!;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: Column(
                                  children:
                                      eventosDelDia.map((evento) {
                                        final nombre = evento['nombre'];
                                        final tipo = evento['tipo'];
                                        final descripcion =
                                            evento['descripcion'];
                                        final fecha =
                                            (evento['fecha'] as Timestamp)
                                                .toDate();
                                        final fechaFormateada = DateFormat(
                                          'EEEE, d \'de\' MMMM',
                                          'es_ES',
                                        ).format(fecha);
                                        final icono =
                                            tipo == 'cumpleaños' ? '🎂' : '🎉';

                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          elevation: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.purple[50],
                                                    child: Text(
                                                      '$dia',
                                                      style: const TextStyle(
                                                        color: Colors.purple,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    '$icono $nombre',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(fechaFormateada),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        tipo == 'cumpleaños'
                                                            ? 'Cumpleaños'
                                                            : 'Evento',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color: Colors.blue,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => EditarEventoScreen(
                                                                    evento:
                                                                        evento,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () async {
                                                          final confirm = await showDialog<
                                                            bool
                                                          >(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => AlertDialog(
                                                                  title: const Text(
                                                                    '¿Eliminar evento?',
                                                                  ),
                                                                  content:
                                                                      const Text(
                                                                        'Esta acción no se puede deshacer.',
                                                                      ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () => Navigator.pop(
                                                                            context,
                                                                            false,
                                                                          ),
                                                                      child: const Text(
                                                                        'Cancelar',
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () => Navigator.pop(
                                                                            context,
                                                                            true,
                                                                          ),
                                                                      child: const Text(
                                                                        'Eliminar',
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                          );

                                                          if (confirm == true) {
                                                            try {
                                                              await eliminarEvento(
                                                                evento.id,
                                                              );
                                                              if (context
                                                                  .mounted) {
                                                                mostrarToastEliminado(
                                                                  context,
                                                                );
                                                              }
                                                            } catch (e) {
                                                              if (context
                                                                  .mounted) {
                                                                mostrarToastError(
                                                                  context,
                                                                  e,
                                                                );
                                                              }
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (descripcion.isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                        ),
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(descripcion),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
