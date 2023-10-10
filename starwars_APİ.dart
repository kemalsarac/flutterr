import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FilmBilgiSayfasi(),
    );
  }
}

class FilmBilgiSayfasi extends StatefulWidget {
  @override
  _FilmBilgiSayfasiState createState() => _FilmBilgiSayfasiState();
}

class _FilmBilgiSayfasiState extends State<FilmBilgiSayfasi> {
  TextEditingController filmAdiController = TextEditingController();
  String filmBilgileri = "";
  String filmYonetmen = "";
  List<String> oyuncuIsimleri = [];

  Future<void> getFilmBilgileri(String filmAdi) async {
    final response = await http.get(
      Uri.parse('https://swapi.dev/api/films/?search=$filmAdi'),
    );

    if (response.statusCode == 200) {
      final veri = json.decode(response.body);
      final filmler = veri['results'] as List<dynamic>;

      final film = filmler.firstWhere(
        (film) => film['title'].toLowerCase().contains(filmAdi.toLowerCase()),
        orElse: () => null,
      );

      if (film != null) {
        List<String> oyuncuURLs = List<String>.from(film['characters']);

        oyuncuIsimleri = [];

        for (String oyuncuURL in oyuncuURLs) {
          final oyuncuResponse = await http.get(Uri.parse(oyuncuURL));
          if (oyuncuResponse.statusCode == 200) {
            final oyuncuVeri = json.decode(oyuncuResponse.body);
            oyuncuIsimleri.add(oyuncuVeri['name']);
          }
        }

        setState(() {
          filmYonetmen = "Yönetmen: ${film['director']}";
          filmBilgileri = "Film Adı: ${film['title']}";
        });
      } else {
        setState(() {
          filmBilgileri = "Belirtilen film bulunamadı.";
          filmYonetmen = "";
          oyuncuIsimleri.clear();
        });
      }
    } else {
      setState(() {
        filmBilgileri = "API isteği sırasında bir hata oluştu.";
        filmYonetmen = "";
        oyuncuIsimleri.clear();
      });
    }
  }

  void showOyuncuFilmleri(String oyuncuAdi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oyuncunun Filmleri'),
          content: FutureBuilder(
            future: getOyuncuFilmleri(oyuncuAdi),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}');
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (String filmAdi in oyuncuIsimleri) Text(filmAdi),
                  ],
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  Future<void> getOyuncuFilmleri(String oyuncuAdi) async {
    final response = await http
        .get(Uri.parse('https://swapi.dev/api/people/?search=$oyuncuAdi'));

    if (response.statusCode == 200) {
      final veri = json.decode(response.body);
      final oyuncular = veri['results'] as List<dynamic>;

      final oyuncu = oyuncular.firstWhere(
        (oyuncu) => oyuncu['name'].toLowerCase() == oyuncuAdi.toLowerCase(),
        orElse: () => null,
      );

      if (oyuncu != null) {
        List<String> filmURLs = List<String>.from(oyuncu['films']);

        oyuncuIsimleri = [];

        for (String filmURL in filmURLs) {
          final filmResponse = await http.get(Uri.parse(filmURL));
          if (filmResponse.statusCode == 200) {
            final filmVeri = json.decode(filmResponse.body);
            oyuncuIsimleri.add(filmVeri['title']);
          }
        }
      } else {
        oyuncuIsimleri = ["Oyuncu bulunamadı."];
      }
    } else {
      oyuncuIsimleri = ["API isteği sırasında bir hata oluştu."];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Star Wars Film Bilgileri'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: filmAdiController,
                decoration: InputDecoration(labelText: 'Film Adı'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                getFilmBilgileri(filmAdiController.text);
              },
              child: Text('Film Bilgilerini Getir'),
            ),
            SizedBox(height: 20),
            Text(
              filmBilgileri,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              filmYonetmen,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Oyuncular:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Column(
              children: oyuncuIsimleri.map((oyuncu) {
                return GestureDetector(
                  onTap: () {
                    showOyuncuFilmleri(oyuncu);
                  },
                  child: Text(
                    oyuncu,
                    style: TextStyle(
                        fontSize: 16, decoration: TextDecoration.underline),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
