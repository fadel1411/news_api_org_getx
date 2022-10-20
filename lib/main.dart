import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<News>> fetchNews(http.Client client) async {
  final response = await client.get(Uri.parse(
      'https://newsapi.org/v2/top-headlines?country=us&apiKey=aa5ed9f35e8b4897bd2d7c53a0f202cd'));
  // Use the compute function to run parseNews in a separate isolate.
  return compute(parseNews, response.body);
}

// A function that converts a response body into a List<Photo>.
List<News> parseNews(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<News>((json) => News.fromJson(json)).toList();
}

class News {
  final String id;
  final String name;
  final String title;

  const News({
    required this.id,
    required this.name,
    required this.title,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<News>>(
        future: fetchNews(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
              return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return NewsList(news: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class NewsList extends StatelessWidget {
  const NewsList({super.key, required this.news});

  final List<News> news;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: news.length,
      itemBuilder: (context, index) {
        return Image.network(news[index].title);
      },
    );
  }
}
