import 'dart:async';
import 'dart:math';
import 'package:app_avion/api_service.dart';
import 'package:app_avion/inicio.dart';
import 'package:app_avion/perfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'perfiles.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key, required this.title, required this.perfil})
      : super(key: key);

  final String title;
  final Perfil perfil;
  final String baseUrl = 'http://192.168.1.4:3000';

  @override
  State<GamePage> createState() => _GamePageState();
}

class Meteor {
  double x;
  double y;
  double size;
  double speed;
  int hits = 0;

  Meteor(this.x, this.y, this.size, this.speed);
}

class Bullet {
  double x;
  double y;
  double size = 10;
  double speed = 10;

  Bullet(this.x, this.y);
}

class _GamePageState extends State<GamePage> {
  double _planeX = 0;
  double _planeY = 0;
  double _maxX = 0;
  double _maxY = 0;
  double _iconSize = 120;
  List<Meteor> _meteors = [];
  List<Bullet> _bullets = [];
  Random _random = Random();
  late Timer _meteorTimer;
  late Timer _gameTimer;
  late Timer _movementTimer;
  double _meteorSpeed = 1.0;
  int _score = 0;
  bool _isGameOver = false;
  Offset _explosionPosition = Offset.zero;
  bool _showExplosion = false;

  late ApiService apiService;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    apiService = ApiService();
    _audioPlayer = AudioPlayer();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final size = MediaQuery.of(context).size;
        _planeX = size.width / 2 - _iconSize / 2;
        _planeY = size.height / 2 - _iconSize / 2;
      });
    });

    accelerometerEvents.listen((AccelerometerEvent event) {
      if (!_isGameOver) {
        setState(() {
          _planeX = (_planeX + event.y * 2).clamp(0, _maxX);
          _planeY = (_planeY + event.x * 4).clamp(0, _maxY);
        });
      }
    });

    _meteorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _meteors.add(Meteor(
            _random.nextDouble() * _maxX,
            0,
            40 + _random.nextDouble() * 30,
            _meteorSpeed,
          ));
        });
      }
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isGameOver) {
        setState(() {
          _score++;
          if (_score % 20 == 0) {
            _meteorSpeed += 1.0;
          }
        });
      }
    });

    _movementTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted && !_isGameOver) {
        setState(() {
          _moveMeteors();
          _moveBullets();
          _checkCollisions();
        });
      }
    });
  }

  @override
  void dispose() {
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      _meteorTimer.cancel();
      _gameTimer.cancel();
      _movementTimer.cancel();
      _audioPlayer.stop();
    } catch (e) {
      print("Error during dispose: $e");
    }

    super.dispose();
  }

  void _moveMeteors() {
    for (var meteor in _meteors) {
      meteor.y += meteor.speed;
    }
    _meteors.removeWhere((meteor) => meteor.y > _maxY);
  }

  void _moveBullets() {
    for (var bullet in _bullets) {
      bullet.y -= bullet.speed;
    }
    _bullets.removeWhere((bullet) => bullet.y < 0);
  }

  void _checkCollisions() {
    List<Meteor> meteorsCopy = List.from(_meteors);
    List<Bullet> bulletsCopy = List.from(_bullets);

    for (Meteor meteor in meteorsCopy) {
      if ((meteor.x - _planeX).abs() < _iconSize * 0.3 &&
          (meteor.y - _planeY).abs() < _iconSize * 0.3) {
        _explosionPosition = Offset(_planeX, _planeY);
        _showExplosion = true;
        _endGame();
        return;
      }
    }

    for (var bullet in bulletsCopy) {
      for (var meteor in meteorsCopy) {
        if ((meteor.x - bullet.x).abs() < meteor.size / 2 &&
            (meteor.y - bullet.y).abs() < meteor.size / 2) {
          meteor.hits++;
          if (meteor.hits >= 5) {
            _meteors.remove(meteor);
            _showExplosion = true;
            _explosionPosition = Offset(meteor.x, meteor.y);
            Timer(Duration(seconds: 3), () {
              setState(() {
                _showExplosion = false;
              });
            });
          }
          _bullets.remove(bullet);
          break;
        }
      }
    }
  }

  void _endGame() {
    _isGameOver = true;
    _meteorTimer.cancel();
    _gameTimer.cancel();
    _movementTimer.cancel();

    _updateUserScore();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Your score: $_score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text("Restart"),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Inicio(perfil: widget.perfil),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Inicio'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => PerfilesView(),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }

  void _updateUserScore() async {
    try {
      print('Puntaje actual: $_score');

      final perfil = await apiService.getProyecto(widget.perfil.id);

      print('Puntaje almacenado en la base de datos: ${perfil.record}');

      if (_score > perfil.record) {
        await apiService.updateRecord(widget.perfil.id, _score);
        print('Nuevo récord actualizado: $_score');
      } else {
        print(
            'El nuevo puntaje no es mayor que el puntaje actual. No se actualiza.');
      }
    } catch (e) {
      print('Excepción al actualizar el record: $e');
      throw Exception('Error al actualizar el record');
    }
  }

  void _shoot() {
    if (!_isGameOver) {
      setState(() {
        _bullets.add(Bullet(
          _planeX + _iconSize / 2 - 5,
          _planeY,
        ));
      });
    }
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _meteors.clear();
      _bullets.clear();
      _isGameOver = false;
      _showExplosion = false;
      _planeX = _maxX / 2 - _iconSize / 2;
      _planeY = _maxY / 2 - _iconSize / 2;
      _meteorSpeed = 1.0;

      _meteorTimer.cancel();
      _gameTimer.cancel();
      _movementTimer.cancel();

      _meteorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _meteors.add(Meteor(
              _random.nextDouble() * _maxX,
              0,
              40 + _random.nextDouble() * 30,
              _meteorSpeed,
            ));
          });
        }
      });

      _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && !_isGameOver) {
          setState(() {
            _score++;
            if (_score % 20 == 0) {
              _meteorSpeed += 1.0;
            }
          });
        }
      });

      _movementTimer =
          Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (mounted && !_isGameOver) {
          setState(() {
            _moveMeteors();
            _moveBullets();
            _checkCollisions();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => Inicio(perfil: widget.perfil),
            ),
            (Route<dynamic> route) => false,
          );

          return false;
        },
        child: Scaffold(
          body: GestureDetector(
            onTap: _shoot,
            child: LayoutBuilder(
              builder: (context, constraints) {
                _maxX = constraints.maxWidth - _iconSize;
                _maxY = constraints.maxHeight - _iconSize;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'img/fondoinfi.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Imagen del avión
                    if (!_isGameOver)
                      Positioned(
                        left: _planeX,
                        top: _planeY,
                        child: Image.asset(
                          'img/jj.gif',
                          width: _iconSize,
                          height: _iconSize,
                        ),
                      ),
                    // Meteoros
                    ..._meteors.map((meteor) => Positioned(
                          left: meteor.x,
                          top: meteor.y,
                          child: Image.asset(
                            'img/meteorito.png',
                            width: meteor.size,
                            height: meteor.size,
                          ),
                        )),
                    // Disparos
                    ..._bullets.map((bullet) => Positioned(
                          left: bullet.x,
                          top: bullet.y,
                          child: Container(
                            width: bullet.size,
                            height: bullet.size,
                            color: Colors.yellow,
                          ),
                        )),
                    // puntuación
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Text(
                        "Score: $_score",
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    if (_showExplosion)
                      Positioned(
                        left: _explosionPosition.dx,
                        top: _explosionPosition.dy,
                        child: Image.asset(
                          'img/explosion.gif',
                          width: _iconSize,
                          height: _iconSize,
                        ),
                      ),

                    Positioned(
                      top: 20,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: _restartGame,
                        child: const Text('Restart'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }
}
