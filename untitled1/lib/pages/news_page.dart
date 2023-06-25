import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/pages/comments_page.dart';
import 'package:untitled1/services/firebase_service.dart';
import 'package:untitled1/viewmodel/article_list_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<Category> categories = [
    Category('business', 'Business'),
    Category('entertainment', 'Entertainment'),
    Category('general', 'General'),
    Category('health', 'Health'),
    Category('science', 'Science'),
    Category('sports', 'Sports'),
    Category('technology', 'Technology'),
  ];

  String selectedCategory = 'general';
  bool addedFavorite = false;
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ArticleListViewModel>(context);
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 60,
            width: double.infinity,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: getCategoriesTab(),
            ),
          ),
          getWidgetByStatus(vm)
        ],
      ),
    );
  }

  List<GestureDetector> getCategoriesTab() {
    List<GestureDetector> list = [];
    for (int i = 0; i < categories.length; i++) {
      list.add(GestureDetector(
        onTap: () => onCategorySelected(categories[i].key),
        child: Card(
          color: selectedCategory == categories[i].key
              ? Colors.blue // Highlight selected category
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              categories[i].title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ));
    }
    return list;
  }

  void onCategorySelected(String categoryKey) {
    setState(() {
      selectedCategory = categoryKey; // Update selected category
    });
    final vm = Provider.of<ArticleListViewModel>(context, listen: false);
    vm.getNews(categoryKey); // Fetch news for selected category
  }

  Widget getWidgetByStatus(ArticleListViewModel vm) {
    switch (vm.status.index) {
      case 2:
        return Expanded(
          child: ListView.builder(
            itemCount: vm.viewModel.articles.length,
            itemBuilder: (context, index) {
              return Card(
                child: Column(
                  children: [
                    Image.network(vm.viewModel.articles[index].urlToImage ??
                        'https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132484366.jpg'),
                    ListTile(
                      title: Text(
                        vm.viewModel.articles[index].title ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        vm.viewModel.articles[index].description ?? '',
                      ),
                    ),
                    ButtonBar(
                      children: [
                        MaterialButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommentsPage(
                                      image: vm.viewModel.articles[index]
                                              .urlToImage ??
                                          'https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132484366.jpg',
                                      title:
                                          vm.viewModel.articles[index].title ??
                                              '',
                                      description: vm.viewModel.articles[index]
                                              .description ??
                                          '',
                                      url: vm.viewModel.articles[index].url ??
                                          '')),
                            );
                          },
                          child: Row(
                            children: [
                              MaterialButton(
                                onPressed: () async {
                                  setState(() {
                                    if (addedFavorite == false) {
                                      FirebaseService().addFavorite(
                                          vm.viewModel.articles[index].title
                                              .toString(),
                                          vm.viewModel.articles[index]
                                              .urlToImage
                                              .toString(),
                                          vm.viewModel.articles[index]
                                              .description
                                              .toString(),
                                          vm.viewModel.articles[index].url
                                              .toString());
                                    } else {
                                      FirebaseService().deleteFavorite(vm
                                          .viewModel.articles[index].title
                                          .toString());
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    FutureBuilder(
                                      future: FirebaseService().getFavorite(vm
                                          .viewModel.articles[index].title
                                          .toString()),
                                      builder: (context,
                                          AsyncSnapshot<Object> snapshot) {
                                        if (snapshot.hasData) {
                                          addedFavorite =
                                              (snapshot.data == true)
                                                  ? true
                                                  : false;
                                        }
                                        return AnimatedOpacity(
                                          opacity:
                                              (snapshot.hasData) ? 1.0 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 400),
                                          child: (snapshot.hasData)
                                              ? (snapshot.data == true)
                                                  ? Row(
                                                      children: const [
                                                        Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                        ),
                                                        Text(
                                                          'Favorite',
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      children: const [
                                                        Icon(Icons
                                                            .favorite_border),
                                                        Text(
                                                          'Add to favorites',
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ],
                                                    )
                                              : Container(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.comment,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: const Text(
                                  'Comments',
                                ),
                              ),
                            ],
                          ),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            await launchUrl(Uri.parse(
                                vm.viewModel.articles[index].url ?? ''));
                          },
                          child: const Text(
                            'Go To News',
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }
}
