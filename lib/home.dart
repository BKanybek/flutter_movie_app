import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Movie> movies = [];
  TextEditingController searchController = TextEditingController();
  final String apiKey = '581ddb014e9b987b297ca1db210f13a5';


  @override
  void initState() {
    super.initState();
    fetchMovies();
  }


  Future<void> fetchMovies() async {
    final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey');
    final response = await http.get(url);


    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> moviesData = jsonData['results'];

      List<Movie> movies =
      moviesData.map((data) => Movie.fromJson(data)).toList();

      setState(() {
        this.movies = movies;
      });
      print(movies);
    } else {
      throw Exception('Ошибка при загрузке фильмов');
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      fetchMovies();
    } else {
      final url = Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> moviesData = jsonData['results'];
        List<Movie> movies = moviesData.map((data) => Movie.fromJson(data)).toList();
        setState(() {
          this.movies = movies;
        });
      } else {
        throw Exception('Ошибка при выполнении поиска');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Movie app', style: TextStyle(fontSize: 24)),
            centerTitle: true,
            backgroundColor: Colors.green,
          ),
          body: Column(
            children: [
              Padding(
                padding:  const EdgeInsets.all(10.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (text) {
                    searchMovies(text);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Поиск фильмов...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2/2.3,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                          child: Image.network(
                            movie.backDropPath != 'Нет изображения'
                                ? 'https://image.tmdb.org/t/p/w500${movie.backDropPath}'
                                : 'https://sklad-vlk.ru/d/cml_b29980cb_b3733bd1.jpg',
                            fit: BoxFit.cover,
                            height: 150,
                          )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 7.0, 5.0, 0.0),
                        child: Text(
                          movie.originalTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  );
                },
              ))
            ],
          )
      ),
    );
  }
}

class Movie {
  String title;
  String backDropPath;
  String originalTitle;

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
