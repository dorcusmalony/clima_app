// home_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _apiKey = 'dae3ad72e7a748c140e48967b213929d';
  
  Future<Map<String, dynamic>?> fetchWeather(String cityName) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$_apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchWeatherByCoordinates(double lat, double lon) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      return null;
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  String? _temperature;
  String? _description;
  String? _cityName;
  bool _isLoading = false;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _getWeatherForCity() async {
    if (_cityController.text.isEmpty) {
      _showErrorSnackBar('Please enter a city name');
      return;
    }

    setState(() {
      _isLoading = true;
      _temperature = null;
      _description = null;
      _cityName = null;
    });

    final service = WeatherService();
    try {
      final data = await service.fetchWeather(_cityController.text);

      if (data != null) {
        setState(() {
          _temperature = '${data['main']['temp'].toStringAsFixed(1)} °C';
          _description = data['weather'][0]['description'];
          _cityName = data['name'];
        });
        _fadeController.forward(from: 0.0); // Trigger the fade animation when data is loaded
      } else {
        _showErrorSnackBar('City not found. Please check the name and try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred. Please check your internet connection.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getAdvice(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('rain')) {
      return 'Carry an umbrella and wear a jacket.';
    } else if (condition.contains('clear')) {
      return 'It\'s clear outside. Enjoy the sunshine!';
    } else if (condition.contains('snow')) {
      return 'Wear warm clothing and be careful on the roads.';
    } else if (condition.contains('cloud')) {
      return 'Cloudy day. Might want to carry a light jacket.';
    } else {
      return 'Stay prepared for any weather!';
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('images/location_background.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(_fadeController.value),
                      BlendMode.darken,
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
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
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Enter City Name',
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
                  const SizedBox(height: 20),
                  if (_isLoading) 
                    const Center(child: CircularProgressIndicator()),
                  if (_temperature != null && _description != null) ...[
                    AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: Text(
                        'City: ${_cityName ?? 'N/A'}',
                        key: ValueKey(_cityName),
                        style: const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: Text(
                        'Temperature: $_temperature',
                        key: ValueKey(_temperature),
                        style: const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: Text(
                        'Condition: $_description',
                        key: ValueKey(_description),
                        style: const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: Text(
                        'Advice: ${_getAdvice(_description!)}',
                        key: ValueKey(_getAdvice(_description!)),
                        style: const TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
