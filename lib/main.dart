import 'package:flutter/material.dart';
import 'package:chinchonator/pantallas/pantalla_configuracion.dart';

void main() {
  runApp(const ChinchonatorApp());
}

class ChinchonatorApp extends StatelessWidget {
  const ChinchonatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chinchonator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const PantallaConfiguracion(),
    );
  }
}