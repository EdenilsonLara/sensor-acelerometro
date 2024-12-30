import 'package:app_avion/perfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'usuario.dart';
import 'juego.dart';

class Inicio extends StatelessWidget {
  final Perfil perfil;

  Inicio({required this.perfil});

  @override
  Widget build(BuildContext context) {
    // Establecer la orientación vertical por defecto
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Inicio',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 24,
              color: Color.fromARGB(255, 202, 120, 65),
            ),
          ),
          backgroundColor: Colors.deepPurple,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Usuario(
                      perfil: perfil,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(
                    'http://192.168.1.4:3000/getImage/${perfil.image}',
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GamePage(title: 'Air Force', perfil: perfil),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 202, 120, 65),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child:
                          Text('Jugar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 202, 120, 65),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text('Salir del Juego',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Image.asset(
      'img/fondoinfi.gif',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
