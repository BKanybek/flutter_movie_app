import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: Home(),
    // Другие настройки вашего приложения
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Movie> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final apiKey =
        '581ddb014e9b987b297ca1db210f13a5'; // Замените YOUR_API_KEY на свой API ключ TMDb.
    final url =
        Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> moviesData = jsonData['results'];

      List<Movie> movies =
          moviesData.map((data) => Movie.fromJson(data)).toList();

      setState(() {
        this.movies = movies;
      });
    } else {
      throw Exception('Ошибка при загрузке фильмов');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Movie app', style: TextStyle(fontSize: 30)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return ListTile(
            title: Text(movie.title),
            subtitle: Text('Original Title: ${movie.originalTitle}'),
            leading: movie.backDropPath != 'Нет изображения'
                ? Image.network(
                    'https://image.tmdb.org/t/p/w200/${movie.backDropPath}')
                : null,
          );
        },
      ),
    );
  }
}

class Movie {
  final String title;
  final String backDropPath;
  final String originalTitle;

  Movie({
    required this.title,
    required this.backDropPath,
    required this.originalTitle,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json["title"] ?? 'Нет названия',
      backDropPath: json["backdrop_path"] ?? 'Нет изображения',
      originalTitle: json["original_title"] ?? 'Нет оригинального названия',
    );
  }
}
