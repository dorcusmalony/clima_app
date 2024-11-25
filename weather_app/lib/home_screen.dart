// home_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _apiKey = 'dae3ad72e7a748c140e48967b213929d';
  
  Future<Map<String, dynamic>?> fetchWeather(String cityName) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchWeatherByCoordinates(double lat, double lon) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  String? _temperature;
  String? _description;
  String? _cityName;
  bool _isLoading = false;

  Future<void> _getWeatherForCity() async {
    setState(() {
      _isLoading = true;
    });

    final service = WeatherService();
    final data = await service.fetchWeather(_cityController.text);

    setState(() {
      _isLoading = false;
      if (data != null) {
        _temperature = '${data['main']['temp']} °C';
        _description = data['weather'][0]['description'];
        _cityName = data['name'];
      } else {
        _temperature = null;
        _description = 'Invalid city name';
      }
    });
  }

  String _getAdvice(String condition) {
    if (condition.contains('rain')) {
      return 'Carry an umbrella and wear a jacket.';
    } else if (condition.contains('clear')) {
      return 'It\'s clear outside. Enjoy the sunshine!';
    } else if (condition.contains('snow')) {
      return 'Wear warm clothing and be careful on the roads.';
    } else {
      return 'Stay prepared for any weather!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/location_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to the Weather App!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _cityController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
                decoration: const InputDecoration(
                  labelText: 'Enter City Name',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _getWeatherForCity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Get Weather for City'),
              ),
              if (_isLoading) 
                const CircularProgressIndicator(),
              if (_temperature != null && _description != null) ...[
                Text(
                  'City: ${_cityName ?? 'N/A'}',
                  style: const TextStyle(fontSize: 26, color: Colors.white),
                ),
                Text(
                  'Temperature: $_temperature',
                  style: const TextStyle(fontSize: 26, color: Colors.white),
                ),
                Text(
                  'Condition: $_description',
                  style: const TextStyle(fontSize: 26, color: Colors.white),
                ),
                const SizedBox(height: 28),
                Text(
                  'Advice: ${_getAdvice(_description!)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}