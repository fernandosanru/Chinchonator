import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chinchonator/pantallas/pantalla_tablero.dart';

class PantallaConfiguracion extends StatelessWidget {
  const PantallaConfiguracion({super.key});

  @override
  Widget build(BuildContext context) => const _PantallaConfiguracionStateful();
}

class _PantallaConfiguracionStateful extends StatefulWidget {
  const _PantallaConfiguracionStateful();

  @override
  State<_PantallaConfiguracionStateful> createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<_PantallaConfiguracionStateful> {
  int _numJugadores = 3;
  final TextEditingController _limiteController = TextEditingController(text: '100');
  List<TextEditingController> _nombreControllers = [];

  @override
  void initState() {
    super.initState();
    _actualizarControllers();
  }

  void _actualizarControllers() {
    _nombreControllers = List.generate(
      _numJugadores,
      (index) => TextEditingController(text: 'Jugador ${index + 1}'),
    );
  }

  @override
  void dispose() {
    _limiteController.dispose();
    for (var c in _nombreControllers) {
      c.dispose();
    }
    super.dispose();
  }

  double _calcularAlturaImagenConfig() {
    if (_numJugadores <= 2) return 220.0;
    if (_numJugadores == 3) return 180.0;
    if (_numJugadores == 4) return 140.0;
    if (_numJugadores == 5) return 100.0;
    return 70.0;
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = _calcularAlturaImagenConfig();
    
    // 🟢 DETECTA SI EL TECLADO ESTÁ ABIERTO
    bool tecladoAbierto = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Chinchonator'),
        centerTitle: true,
        backgroundColor: Colors.green[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nº de Jugadores:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        DropdownButton<int>(
                          value: _numJugadores,
                          items: [2, 3, 4, 5, 6].map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value jugadores', style: const TextStyle(fontSize: 16)),
                            );
                          }).toList(),
                          onChanged: (nuevoValor) {
                            if (nuevoValor != null) {
                              setState(() {
                                _numJugadores = nuevoValor;
                                _actualizarControllers();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _limiteController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Límite de puntos',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.score),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text('Nombres de los jugadores:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _numJugadores,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TextField(
                            controller: _nombreControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Jugador ${index + 1}',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // 🟢 SI EL TECLADO ESTÁ ABIERTO, ESTE CUADRO NO SE DIBUJA, EVITANDO EL DESBORDAMIENTO
            if (!tecladoAbierto)
              Opacity(
                opacity: 1.0,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: imageSize,
                  width: imageSize,
                  child: Image.asset(
                    'assets/images/chinchonator.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      List<String> nombres = _nombreControllers.map((c) => c.text.trim()).toList();
                      int limite = int.tryParse(_limiteController.text) ?? 101;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaTablero(
                            nombresJugadores: nombres,
                            limitePuntos: limite,
                          ),
                        ),
                      );
                    },
                    child: const Text('¡A Jugar!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent, width: 2),
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else {
                        exit(0);
                      }
                    },
                    child: const Text('Salir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}