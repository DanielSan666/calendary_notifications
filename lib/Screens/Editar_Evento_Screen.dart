import 'package:calendary_notifications/Services/Functions_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarEventoScreen extends StatefulWidget {
  final DocumentSnapshot evento;

  const EditarEventoScreen({super.key, required this.evento});

  @override
  State<EditarEventoScreen> createState() => _EditarEventoScreenState();
}

class _EditarEventoScreenState extends State<EditarEventoScreen> {
  late TextEditingController nombreController;
  late TextEditingController descripcionController;
  late String tipoEvento;
  DateTime? fecha;

  @override
  void initState() {
    super.initState();
    final data = widget.evento.data() as Map<String, dynamic>;
    nombreController = TextEditingController(text: data['nombre']);
    descripcionController = TextEditingController(text: data['descripcion']);
    tipoEvento = data['tipo'];
    fecha = (data['fecha'] as Timestamp).toDate();
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> guardarCambios() async {
    try {
      await editarEvento(
        idEvento: widget.evento.id,
        nombre: nombreController.text.trim(),
        tipo: tipoEvento,
        fecha: fecha!,
        descripcion: descripcionController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Evento actualizado correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error al actualizar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Editar Evento',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Modificar Datos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Tipo de evento'),
                RadioListTile(
                  title: const Text('🎂 Cumpleaños'),
                  value: 'cumpleaños',
                  groupValue: tipoEvento,
                  onChanged: (value) => setState(() => tipoEvento = value!),
                ),
                RadioListTile(
                  title: const Text('🎉 Evento especial'),
                  value: 'especial',
                  groupValue: tipoEvento,
                  onChanged: (value) => setState(() => tipoEvento = value!),
                ),
                const SizedBox(height: 10),
                const Text('Nombre de la persona'),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Juan Pérez',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Fecha'),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: DateFormat('dd/MM/yyyy').format(fecha!),
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final nuevaFecha = await showDatePicker(
                      context: context,
                      initialDate: fecha!,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (nuevaFecha != null) {
                      setState(() => fecha = nuevaFecha);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Descripción (opcional)'),
                TextField(
                  controller: descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Descripción del evento...',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: guardarCambios,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Cambios'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '💡 Tip: Los cambios se guardarán automáticamente cuando presiones "Guardar Cambios"',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
