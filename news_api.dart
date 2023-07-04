import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/news_article.dart';

class NewsAPI {
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl = 'https://newsapi.org/v2/top-headlines';
  static const List<String> _sources = ['bbc-news', 'cnn', 'fox-news', 'the-new-york-times', 'the-washington-post'];

  static Future<List<NewsArticle>> fetchArticles() async {
    List<NewsArticle> articles = [];
    for (String source in _sources) {
      String url = '$_baseUrl?sources=$source&apiKey=$_apiKey';
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> articlesData = data['articles'];
        for (dynamic articleData in articlesData) {
          String title = articleData['title'];
          String author = articleData['author'] ?? 'Unknown';
          String content = articleData['content'] ?? '';
          String topic = _getSourceTopic(source);
          NewsArticle article = NewsArticle(title: title, author: author, content: content, topic: topic);
          articles.add(article);
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
    return articles;
  }

  static String _getSourceTopic(String source) {
    switch (source) {
      case 'bbc-news':
        return 'Business';
      case 'cnn':
        return 'Entertainment';
      case 'fox-news':
        return 'Health';
      case 'the-new-york-times':
        return 'Science';
      case 'the-washington-post':
        return 'Sports';
      default:
        return 'Technology';
    }
  }
}
