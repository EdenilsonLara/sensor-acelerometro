import 'package:app_avion/inicio.dart';
import 'package:flutter/material.dart';
import 'crearPerfil.dart';
import 'perfil.dart';
import 'api_service.dart';

void main() {
  runApp(const PerfilesView());
}

class PerfilesView extends StatelessWidget {
  const PerfilesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<Perfil> perfiles = []; // Lista de perfiles
  bool _isLoading = true; // Variable para controlar el estado de carga
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAppBarVisible = false; // Controla la visibilidad de la AppBar
  final ApiService apiService = ApiService(); // Instancia del servicio de API

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _loadProfiles(); // Cuando la animación comienza de nuevo, cargar perfiles
      }
    });
    _controller.forward();
    _loadProfiles(); // Cargar perfiles al iniciar la aplicación
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    try {
      final response = await apiService.getAllProyectos();
      print('Datos recibidos: $response');
      setState(() {
        perfiles = response;
        _isLoading = false;
        _isAppBarVisible = true;
      });
    } catch (e) {
      print('Error al cargar los perfiles: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los perfiles: $e')),
      );
      setState(() {
        _isLoading = false;
        _isAppBarVisible = true;
      });
    }
  }

  Future<void> _deleteProfile(String id) async {
    try {
      final response = await apiService.deleteProyecto(id);
      print('Respuesta de eliminación: $response');
      if (response['success'] == true) {
        setState(() {
          perfiles.removeWhere((perfil) => perfil.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil eliminado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eliminado correctamente')),
        );
      }
    } catch (e) {
      print('Eliminado correctamente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 25, 56, 70), // Color de fondo de la vista
      appBar: _isAppBarVisible
          ? AppBar(
              centerTitle: true, // Centra el título en la AppBar
              title: Text(
                'Air Force',
                style: TextStyle(
                  fontSize: 32, // Tamaño de fuente más grande
                  color: Color.fromARGB(255, 202, 120,
                      65), // Color verde para que coincida con la serpiente
                  fontWeight: FontWeight.bold, // Texto en negrita
                  letterSpacing: 2.0, // Espacio adicional entre las letras
                  fontFamily:
                      'PressStart2P', // Fuente que recuerda a los juegos retro
                ),
              ),
              backgroundColor:
                  Colors.deepPurple, // Color de fondo de la barra de navegación
            )
          : null, // Si _isAppBarVisible es false, no muestra la AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildProfilesListView(),
      ),
    );
  }

/*  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Snake Rewind',
          style: TextStyle(
            fontSize: 32,
            color: Color.fromARGB(255, 202, 120, 65),
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontFamily: 'PressStart2P',
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: SnakePainter(animationValue: _animation.value),
          ),
        ),
      ],
    );
  }
*/
  Widget _buildProfilesListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            'Selecciona un perfil para continuar',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: perfiles.length,
            itemBuilder: (context, index) {
              final perfil = perfiles[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(perfil.nombre.isNotEmpty
                        ? perfil.nombre
                        : 'Nombre no disponible'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Apodo: ${perfil.apodo.isNotEmpty ? perfil.apodo : 'Apodo no disponible'}'),
                        Text('Puntaje: ${perfil.record}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Inicio(perfil: perfil),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteProfile(perfil.id);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                final nuevoPerfil = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearPerfil()),
                );
                if (nuevoPerfil != null) {
                  setState(() {
                    perfiles.add(nuevoPerfil);
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Agregar Perfil'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SnakePainter extends CustomPainter {
  final double animationValue;

  SnakePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      final xPos = size.width * animationValue + (i * 20);
      final yPos = size.height / 2;
      canvas.drawRect(
        Rect.fromLTWH(xPos, yPos, 15, 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
