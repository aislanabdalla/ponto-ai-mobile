import 'dart:io';
import 'package:http/http.dart' as http;

class Api {
  // Ajuste para o IP/porta onde o backend estiver rodando
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // Em dispositivo físico na mesma rede do PC, use o IP local do PC, ex: 'http://192.168.0.10:8000'

  static Future<http.Response> enroll(String name, File selfie) async {
    var req = http.MultipartRequest('POST', Uri.parse('$baseUrl/employees'));
    req.fields['name'] = name;
    req.files.add(await http.MultipartFile.fromPath('selfie', selfie.path));
    var res = await req.send();
    return http.Response.fromStream(res);
  }

  static Future<http.Response> punch(int employeeId, File selfie, {double? lat, double? lon}) async {
    var req = http.MultipartRequest('POST', Uri.parse('$baseUrl/punches'));
    req.fields['employee_id'] = employeeId.toString();
    if (lat != null) req.fields['lat'] = lat.toString();
    if (lon != null) req.fields['lon'] = lon.toString();
    req.files.add(await http.MultipartFile.fromPath('selfie', selfie.path));
    var res = await req.send();
    return http.Response.fromStream(res);
  }
}
