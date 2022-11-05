import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SensorService {
  Future<Map<String, int>> getSensorData() async {
    const String url = 'http://3.34.4.211/sensors';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    return json;
  }
}
