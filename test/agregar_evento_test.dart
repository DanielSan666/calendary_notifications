import 'package:calendary_notifications/Screens/Agregar_Evento_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Agregar Evento muestra formulario correctamente', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: AgregarEventoScreen()));

    expect(find.text('Agregar Evento'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3)); // 3 campos de texto
  });
}
