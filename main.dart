import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String location = "Ankara"; // Varsayılan konum
  String weatherData = "Hava durumu bilgisi yükleniyor...";

  void fetchWeatherData(String location) async {
    final apiKey = "a1a635e5a466ce500db448ac4bd1fb12"; // OpenWeatherMap API key
    final apiUrl =
        "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final mainWeather = data['weather'][0]['main'];
      final description = data['weather'][0]['description'];
      final temperature = (data['main']['temp'] - 273.15)
          .toStringAsFixed(2); // Kelvin'i Celsius'a çevir

      setState(() {
        weatherData =
            'Hava Durumu: $mainWeather\nAçıklama: $description\nSıcaklık: $temperature °C';
      });
    } else {
      setState(() {
        weatherData = 'Hava durumu bilgileri alınamadı.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hava Durumu Uygulaması'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Konum: $location',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                weatherData,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  fetchWeatherData(location);
                },
                child: Text('Hava Durumu Güncelle'),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  location = value;
                },
                decoration: InputDecoration(
                  labelText: 'Konum Girin',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
