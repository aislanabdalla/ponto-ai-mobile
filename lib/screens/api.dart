import 'dart:io';
import 'package:http/http.dart' as http;

class Api {
  // 👉 Troque pela SUA URL do Koyeb (com https)
  static const String baseUrl = 'https://pleasant-isadora-dropart-23f2366a.koyeb.app';

  static Uri _u(String path) => Uri.parse('$baseUrl$path');

  /// Cadastra funcionário com selfie (retorna o JSON do funcionário)
  static Future<http.Response> enroll(
    String name,
    File selfie, {
    String? document,
    String? email,
  }) async {
    final req = http.MultipartRequest('POST', _u('/employees'));
    req.fields['name'] = name;
    if (document != null && document.isNotEmpty) req.fields['document'] = document;
    if (email != null && email.isNotEmpty) req.fields['email'] = email;
    req.files.add(await http.MultipartFile.fromPath('selfie', selfie.path));
    final res = await req.send();
    return http.Response.fromStream(res);
  }

  /// Bate ponto para um employeeId com uma selfie (lat/lon opcionais)
  static Future<http.Response> punch(
    int employeeId,
    File selfie, {
    double? lat,
    double? lon,
  }) async {
    final req = http.MultipartRequest('POST', _u('/punches'));
    req.fields['employee_id'] = employeeId.toString();
    if (lat != null) req.fields['lat'] = lat.toString();
    if (lon != null) req.fields['lon'] = lon.toString();
    req.files.add(await http.MultipartFile.fromPath('selfie', selfie.path));
    final res = await req.send();
    return http.Response.fromStream(res);
  }
}
