import 'package:flutter/material.dart';
import 'package:news_app/news_article.dart';
import 'package:news_app/news_api.dart';
import 'package:news_app/text_summarizer.dart';
import 'package:news_app/text_to_speech.dart';
import 'package:news_app/language_translator.dart';

class NewsFeed extends StatefulWidget {
  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  List<NewsArticle> _articles = [];
  List<String> _topics = ['Business', 'Entertainment', 'Health', 'Science', 'Sports', 'Technology'];
  String _selectedTopic = 'Business';
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  void _fetchArticles() async {
    List<NewsArticle> articles = await NewsAPI.fetchArticles();
    setState(() {
      _articles = articles;
    });
  }

  void _filterArticles(String topic) {
    setState(() {
      _selectedTopic = topic;
    });
  }

  void _translateArticle(NewsArticle article) async {
    String translatedContent = await LanguageTranslator.translate(article.content, _selectedLanguage);
    setState(() {
      article.content = translatedContent;
    });
  }

  void _summarizeArticle(NewsArticle article) async {
    String summarizedContent = await TextSummarizer.summarize(article.content);
    setState(() {
      article.content = summarizedContent;
    });
  }

  void _speakArticle(NewsArticle article) async {
    await TextToSpeech.speak(article.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News App'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return _topics.map((topic) {
                return PopupMenuItem(
                  value: topic,
                  child: Text(topic),
                );
              }).toList();
            },
            onSelected: _filterArticles,
            icon: Icon(Icons.filter_list),
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return ['en', 'es', 'fr', 'de', 'it', 'ja', 'ko', 'pt', 'ru', 'zh'].map((language) {
                return PopupMenuItem(
                  value: language,
                  child: Text(language),
                );
              }).toList();
            },
            onSelected: (String language) {
              setState(() {
                _selectedLanguage = language;
              });
              for (NewsArticle article in _articles) {
                _translateArticle(article);
              }
            },
            icon: Icon(Icons.language),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (BuildContext context, int index) {
          NewsArticle article = _articles[index];
          if (article.topic == _selectedTopic) {
            return ListTile(
              title: Text(article.title),
              subtitle: Text(article.author),
              trailing: PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      child: Text('Summarize'),
                      value: 'summarize',
                    ),
                    PopupMenuItem(
                      child: Text('Text-to-Speech'),
                      value: 'speak',
                    ),
                  ];
                },
                onSelected: (String value) {
                  if (value == 'summarize') {
                    _summarizeArticle(article);
                  } else if (value == 'speak') {
                    _speakArticle(article);
                  }
                },
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
