import 'package:untitled1/models/source.dart';

class Articles {
  Source? source;
  String? author;
  String? title;
  String? description;
  String? url;
  String? urlToImage;
  String? publishedAt;
  String? content;

  Articles(
      {this.source,
        this.author,
        this.title,
        this.description,
        this.url,
        this.urlToImage,
        this.publishedAt,
        this.content});

  Articles.fromJson(Map<String, dynamic> json) {
    source = json['source'] != null ? Source.fromJson(json['source']) : null;
    author = json['author'];
    title = json['title'];
    description = json['description'];
    url = json['url'];
    urlToImage = json['urlToImage'];
    publishedAt = json['publishedAt'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (source != null) {
      data['source'] = source!.toJson();
    }
    data['author'] = author;
    data['title'] = title;
    data['description'] = description;
    data['url'] = url;
    data['urlToImage'] = urlToImage;
    data['publishedAt'] = publishedAt;
    data['content'] = content;
    return data;
  }
}
class Article {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final String category;
  final List<Comment> comments;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.category,
    this.comments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'url': url,
      'category': category,
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      url: map['url'],
      category: map['category'],
      comments: List<Comment>.from(
          map['comments']?.map((x) => Comment.fromMap(x)) ?? []),
    );
  }
}

class Comment {
  final String id;
  final String articleId;
  final String username;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.articleId,
    required this.username,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'articleId': articleId,
      'username': username,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      articleId: map['articleId'],
      username: map['username'],
      text: map['text'],
      timestamp: map['timestamp'].toDate(),
    );
  }
}