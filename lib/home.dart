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
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
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

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      fetchMovies();
    } else {
      final url = Uri.parse(
          'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query');
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
        throw Exception('Ошибка при выполнении поиска');
      }
    }
  }

  Widget buildNoResultsFound() {
    return const Center(
      child: Text(
        'Фильм не найден',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.amber,
        appBar: AppBar(
          elevation: 0,
          title: _isSearching
              ? TextField(
                  controller: searchController,
                  onChanged: (text) {
                    searchMovies(text);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Найти фильм...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                )
              : const Text(
                  'КиноПоиск',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
          centerTitle: true,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.cancel_outlined : Icons.search_sharp,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    searchMovies('');
                  }
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: movies.isEmpty
              ? buildNoResultsFound()
              : GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return Card(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Image.network(
                                  movie.backDropPath != 'Нет изображения'
                                      ? 'https://image.tmdb.org/t/p/w500${movie.backDropPath}'
                                      : 'https://sklad-vlk.ru/d/cml_b29980cb_b3733bd1.jpg',
                                  fit: BoxFit.cover,
                                )),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Рейтинг',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    const Icon(Icons.star, color: Colors.amber),
                                    Text(
                                      '${movie.voteAverage.toStringAsFixed(1)}/10',
                                      style: const TextStyle(color: Colors.black),
                                    )
                                  ],
                                )
                              ],
                            ),

                      ),
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 0.0,
                    mainAxisSpacing: 5,
                    mainAxisExtent: 250,
                  ),
                ),
        ),
      ),
    );
  }
}

class Movie {
  String title;
  String backDropPath;
  String originalTitle;
  double voteAverage;

  Movie({
    required this.title,
    required this.backDropPath,
    required this.originalTitle,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json["title"] ?? 'Нет названия',
      backDropPath: json["backdrop_path"] ?? 'Нет изображения',
      originalTitle: json["original_title"] ?? 'Нет оригинального названия',
      voteAverage: (json["vote_average"] as num).toDouble(),
    );
  }
}
