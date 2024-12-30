import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'perfil.dart';

class CrearPerfil extends StatefulWidget {
  @override
  _CrearPerfilState createState() => _CrearPerfilState();
}

class _CrearPerfilState extends State<CrearPerfil> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController apodoController = TextEditingController();
  XFile? _imageFile;
  final ApiService apiService = ApiService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    final String nombre = nombreController.text;
    final int edad = int.tryParse(edadController.text) ?? 0;
    final String apodo = apodoController.text;
    final String imagePath = _imageFile?.path ?? '';

    if (nombre.isEmpty || edad == 0 || apodo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final Map<String, dynamic> proyectoData = {
      'nombre': nombre,
      'edad': edad,
      'apodo': apodo,
      'record': 0,
    };

    try {
      final response = await apiService.saveProyecto(proyectoData, imagePath);
      final nuevoPerfil = Perfil.fromJson(response);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil guardado con éxito')),
      );
      Navigator.pop(context, nuevoPerfil);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear Perfil',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 24,
            color: Color.fromARGB(255, 202, 120, 65),
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Color.fromARGB(255, 104, 95, 185),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(
                  'Seleccionar Imagen',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 233, 167, 69),
                ),
              ),
              SizedBox(height: 20),
              _imageFile != null
                  ? Image.file(File(_imageFile!.path))
                  : Icon(Icons.image, size: 100, color: Colors.white),
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              TextField(
                controller: edadController,
                decoration: InputDecoration(
                  labelText: 'Edad',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
              ),
              TextField(
                controller: apodoController,
                decoration: InputDecoration(
                  labelText: 'Apodo',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text(
                  'Crear Perfil',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 233, 167, 69),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
