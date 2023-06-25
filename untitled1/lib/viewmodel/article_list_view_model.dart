import 'package:flutter/cupertino.dart';
import 'package:untitled1/models/articles.dart';
import 'package:untitled1/services/news_service.dart';
import 'package:untitled1/viewmodel/article_view_model.dart';

enum Status { initial, loading, loaded }

class ArticleListViewModel extends ChangeNotifier {
  ArticleViewModel viewModel = ArticleViewModel('general', []);
  Status status = Status.initial;



  ArticleListViewModel() {
    getNews('general');
  }

  Future<void> getNews(String category) async {
    status = Status.loading;
    notifyListeners();
    viewModel.articles = await NewsService().fetchNews(category) as List<Articles>;
    status = Status.loaded;
    notifyListeners();
  }
}