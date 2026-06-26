import 'package:flutter/material.dart';

class JugadorPartida {
  String nombre;
  int puntuacionTotal = 0;
  List<int> historico = [];
  TextEditingController controllerParcial = TextEditingController();

  JugadorPartida({required this.nombre});
}

class PantallaTablero extends StatefulWidget {
  final List<String> nombresJugadores;
  final int limitePuntos;

  const PantallaTablero({
    super.key,
    required this.nombresJugadores,
    required this.limitePuntos,
  });

  @override
  State<PantallaTablero> createState() => _PantallaTableroState();
}

class _PantallaTableroState extends State<PantallaTablero> {
  List<JugadorPartida> _jugadores = [];
  int _rondaActual = 1;

  @override
  void initState() {
    super.initState();
    _jugadores = widget.nombresJugadores.map((nombre) => JugadorPartida(nombre: nombre)).toList();
  }

  @override
  void dispose() {
    for (var j in _jugadores) {
      j.controllerParcial.dispose();
    }
    super.dispose();
  }

  // Valores generosos corregidos para que la imagen de 512x512 luzca bien
  double _calcularAlturaImagenTablero() {
    if (_jugadores.length <= 2) return 280.0;
    if (_jugadores.length == 3) return 240.0;
    if (_jugadores.length == 4) return 180.0;
    if (_jugadores.length == 5) return 130.0;
    return 90.0;
  }

  void _anotarRonda() {
    bool alguienHaPerdido = false;
    String nombrePerdedor = '';

    setState(() {
      for (var jugador in _jugadores) {
        int puntosParciales = int.tryParse(jugador.controllerParcial.text) ?? 0;
        
        jugador.historico.add(puntosParciales);
        jugador.puntuacionTotal += puntosParciales;
        jugador.controllerParcial.clear();

        if (jugador.puntuacionTotal >= widget.limitePuntos) {
          alguienHaPerdido = true;
          nombrePerdedor = jugador.nombre;
        }
      }
      _rondaActual++;
    });

    if (alguienHaPerdido) {
      _mostrarFinPartida(nombrePerdedor);
    }
  }

  void _mostrarFinPartida(String perdedor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('💥 ¡Fin de la Partida!'),
        content: Text('$perdedor ha alcanzado o superado el límite de ${widget.limitePuntos} puntos y ha perdido.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Volver al Menú'),
          )
        ],
      ),
    );
  }

  // Función auxiliar práctica para pintar las medallas o la posición
  Widget _buildIconoPosicion(int posicion) {
    if (_rondaActual == 1) return const SizedBox(); // Si no se ha anotado nada, vacío

    switch (posicion) {
      case 1:
        return const Text('🥇', style: TextStyle(fontSize: 18), textAlign: TextAlign.center);
      case 2:
        return const Text('🥈', style: TextStyle(fontSize: 18), textAlign: TextAlign.center);
      case 3:
        return const Text('🥉', style: TextStyle(fontSize: 18), textAlign: TextAlign.center);
      default:
        return Text('$posicionº', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center);
    }
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = _calcularAlturaImagenTablero();
    bool tecladoAbierto = MediaQuery.of(context).viewInsets.bottom > 0;

    // 🟢 LÓGICA DE CLASIFICACIÓN INTERNA: Ordenamos una copia de menor a mayor puntuación
    List<JugadorPartida> jugadoresOrdenados = List.from(_jugadores);
    jugadoresOrdenados.sort((a, b) => a.puntuacionTotal.compareTo(b.puntuacionTotal));

    return Scaffold(
      appBar: AppBar(
        title: Text('Ronda $_rondaActual (Máx: ${widget.limitePuntos})'),
        centerTitle: true,
        backgroundColor: Colors.green[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Cabecera informativa fija (Ajustada con el nuevo hueco de Posición)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: Text('Jugador', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  Expanded(flex: 1, child: Text(_rondaActual > 1 ? 'Pos' : '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)),
                  const Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue))),
                  const Expanded(flex: 2, child: Text('Puntos Ronda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green))),
                ],
              ),
            ),
            const Divider(),

            // Lista central de jugadores
            Expanded(
              child: ListView.builder(
                itemCount: _jugadores.length,
                itemBuilder: (context, index) {
                  final jugador = _jugadores[index];
                  
                  // 🟢 Calculamos la posición buscando al jugador en la lista ordenada (+1 porque empieza en index 0)
                  int posicion = jugadoresOrdenados.indexOf(jugador) + 1;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Nombre
                          Expanded(
                            flex: 3,
                            child: Text(
                              jugador.nombre,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          
                          // 🟢 IDENTIFICADOR DE POSICIÓN (Entre el nombre y los puntos)
                          Expanded(
                            flex: 1,
                            child: _buildIconoPosicion(posicion),
                          ),

                          // Puntuación Total
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${jugador.puntuacionTotal} pts',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                color: jugador.puntuacionTotal >= widget.limitePuntos ? Colors.red : Colors.blue[800]
                              ),
                            ),
                          ),
                          
                          // Input de Ronda
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: jugador.controllerParcial,
                              keyboardType: const TextInputType.numberWithOptions(signed: true),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Ocultar imagen si el teclado está desplegado
            if (!tecladoAbierto)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: imageSize,
                width: imageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/chinchonator.png',
                  fit: BoxFit.contain,
                ),
              ),

            // Botón de registrar jugada corregido (_anotarRonda)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _anotarRonda,
                child: const Text('Anotar Jugada ➜', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}