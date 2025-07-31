import 'package:calendary_notifications/Services/Event_Service.dart';
import 'package:calendary_notifications/Services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendary_notifications/Screens/EventosDelMesScreen.dart';
import 'package:calendary_notifications/Services/Add_Events_Service.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:intl/intl.dart';

class AgregarEventoScreen extends StatefulWidget {
  final bool fromMonthScreen;

  const AgregarEventoScreen({super.key, this.fromMonthScreen = false});

  @override
  State<AgregarEventoScreen> createState() => _AgregarEventoScreenState();
}

class _AgregarEventoScreenState extends State<AgregarEventoScreen> {
  String tipoEvento = 'cumpleaños';
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  DateTime? fecha;

  bool botonHabilitado = false;

  @override
  void initState() {
    super.initState();
    nombreController.addListener(_validarFormulario);
  }

  void _validarFormulario() {
    setState(() {
      botonHabilitado =
          nombreController.text.trim().isNotEmpty && fecha != null;
    });
  }

  @override
  void dispose() {
    nombreController.removeListener(_validarFormulario);
    nombreController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarEvento() async {
    try {
      if (fecha == null || nombreController.text.isEmpty) {
        throw Exception('Datos incompletos');
      }

      final eventId = await agregarEvento(
        nombre: nombreController.text.trim(),
        tipo: tipoEvento,
        fecha: fecha!,
        descripcion: descripcionController.text.trim(),
      );

      await NotificationService().scheduleEventNotifications(
        eventId: eventId,
        title: nombreController.text.trim(),
        eventDate: fecha!,
        description: descripcionController.text.trim(),
        eventType: tipoEvento, // Pasamos el tipo de evento
      );

      final eventService = Provider.of<EventService>(context, listen: false);
      eventService.markForRefresh();

      DelightToastBar(
        builder:
            (context) => const ToastCard(
              leading: Icon(Icons.check_circle, size: 28, color: Colors.green),
              title: Text(
                '🎉 Evento guardado correctamente',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: Durations.extralong4,
      ).show(context);

      if (widget.fromMonthScreen) {
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => EventosDelMesScreen(
                  mes: DateFormat('MMMM', 'es_ES').format(fecha!),
                  key: UniqueKey(),
                ),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      DelightToastBar(
        builder:
            (context) => ToastCard(
              leading: const Icon(Icons.error, size: 28, color: Colors.red),
              title: Text(
                '❌ Error al guardar: $e',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        snackbarDuration: Durations.extralong4,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFCF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Agregar Evento',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Nuevo Evento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('Tipo de evento'),
                RadioListTile(
                  title: const Text('🎂 Cumpleaños'),
                  value: 'cumpleaños',
                  groupValue: tipoEvento,
                  onChanged: (value) {
                    setState(() {
                      tipoEvento = value!;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('🎉 Evento especial'),
                  value: 'especial',
                  groupValue: tipoEvento,
                  onChanged: (value) {
                    setState(() {
                      tipoEvento = value!;
                    });
                  },
                ),

                const SizedBox(height: 10),
                const Text('Nombre de la persona'),
                const SizedBox(height: 4),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    hintText: 'Ej: María García',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Fecha'),
                const SizedBox(height: 4),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText:
                        fecha == null
                            ? 'dd/mm/aaaa'
                            : '${fecha!.day}/${fecha!.month}/${fecha!.year}',
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        fecha = picked;
                        _validarFormulario();
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),
                const Text('Descripción (opcional)'),
                const SizedBox(height: 4),
                TextField(
                  controller: descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Añade detalles adicionales...',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: botonHabilitado ? _guardarEvento : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFFCF5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.save, color: Colors.black),
                    label: const Text(
                      'Guardar Evento',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
