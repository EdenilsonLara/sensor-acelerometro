import 'dart:convert';

import 'package:app_avion/perfil.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.1.4:3000';

  Future<Map<String, dynamic>> home() async {
    final response = await http.get(Uri.parse('$baseUrl/home'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener el inicio de la API');
    }
  }

  Future<Perfil> getProyecto(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/get/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> proyectoData = json.decode(response.body);
      return Perfil.fromJson(proyectoData);
    } else {
      throw Exception('Error al obtener el proyecto');
    }
  }

  Future<Map<String, dynamic>> saveProyecto(
      Map<String, dynamic> proyectoData, String? imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/save'));

    proyectoData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al guardar el proyecto');
    }
  }

  Future<List<Perfil>> getAllProyectos() async {
    final response = await http.get(Uri.parse('$baseUrl/getAll'));

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      print('JSON recibido: $decoded'); // Para depuración

      if (decoded is Map<String, dynamic> && decoded['mensaje'] is List) {
        return (decoded['mensaje'] as List)
            .map<Perfil>((json) => Perfil.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'El formato de los datos no es una lista en la clave "mensaje"');
      }
    } else {
      throw Exception('Error al obtener todos los proyectos');
    }
  }

  Future<Map<String, dynamic>> updateProyecto(
      String id, Map<String, dynamic> updateData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar el proyecto');
    }
  }

  Future<Map<String, dynamic>> deleteProyecto(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al eliminar el proyecto');
    }
  }

  Future<Map<String, dynamic>> updateImage(String id, String imagePath) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/updateImage/$id'));

    if (imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar la imagen del proyecto');
    }
  }

  Future<http.Response> getImage(String img) async {
    final response = await http.get(Uri.parse('$baseUrl/getImage/$img'));

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Error al obtener la imagen');
    }
  }

  Future<void> updateRecord(String id, int newRecord) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get/$id'));
      if (response.statusCode == 200) {
        final perfil = Perfil.fromJson(json.decode(response.body));

        if (newRecord > perfil.record) {
          final updateResponse = await http.put(
            Uri.parse('$baseUrl/updateRecord/$id'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'record': newRecord}),
          );

          print('Respuesta del servidor: ${updateResponse.statusCode}');
          print('Cuerpo de la respuesta: ${updateResponse.body}');

          if (updateResponse.statusCode != 200) {
            throw Exception(
                'Error al actualizar el record: ${updateResponse.body}');
          }
        }
      } else {
        throw Exception('Error al obtener el perfil: ${response.body}');
      }
    } catch (e) {
      print('Excepción al actualizar el record: $e');
      throw Exception('Error al actualizar el record');
    }
  }
}
