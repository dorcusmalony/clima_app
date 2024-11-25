// weather_service_screen.dart
// weather_service_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherServiceScreen extends StatefulWidget {
  const WeatherServiceScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeatherServiceScreenState createState() => _WeatherServiceScreenState();
}

class _WeatherServiceScreenState extends State<WeatherServiceScreen> {
  final TextEditingController _cityController = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _getDetailedWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final weatherService = WeatherService();
    try {
      final data = await weatherService.fetchWeather(_cityController.text);
      setState(() {
        _isLoading = false;
        if (data != null) {
          _weatherData = data;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/download.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Enter City',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getDetailedWeather,
                child: const Text('Get Weather Details'),
              ),
              const SizedBox(height: 16),
              if (_isLoading) 
                const CircularProgressIndicator(),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 26),
                ),
              if (_weatherData != null && _errorMessage.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'City: ${_weatherData!['city']['name']}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Temperature: ${_weatherData!['list'][0]['main']['temp']}°C',
                      style: const TextStyle(fontSize: 26, color: Colors.white),
                    ),
                    Text(
                      'Condition: ${_weatherData!['list'][0]['weather'][0]['description']}',
                      style: const TextStyle(fontSize: 26, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Days Forecast:',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          var forecast = _weatherData!['list'][index * 8];
                          var date = DateTime.fromMillisecondsSinceEpoch(
                              forecast['dt'] * 1000);
                          return Card(
                            color: Colors.white70,
                            margin: const EdgeInsets.only(right: 16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              width: 160,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${date.day}/${date.month}',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${forecast['main']['temp']}°C',
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    forecast['weather'][0]['description'],
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}

class WeatherService {
  final String _apiKey = 'dae3ad72e7a748c140e48967b213929d';
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    final url = Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw 'Failed to load weather data. Status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error fetching weather: $e';
    }
  }
}