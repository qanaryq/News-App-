import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/pages/favorites_page.dart';
import 'package:untitled1/pages/news_page.dart';
import 'package:untitled1/viewmodel/article_list_view_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final user = FirebaseAuth.instance.currentUser!;
  int pageCount = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text((pageCount == 0) ? 'Daily News' : 'Favorites'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(''),
                accountEmail: Text('user Email:' + user.email!),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () async {
                  setState(() {
                    pageCount = 0;
                  });
                  // Navigate to login screen
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favorites'),
                onTap: () async {
                  setState(() {
                    pageCount = 1;
                  });
                  // Navigate to login screen
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log Out'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  // Navigate to login screen
                },
              ),
            ],
          ),
        ),
        body: ChangeNotifierProvider(
          create: (context) => ArticleListViewModel(),
          child: (pageCount == 0) ? const NewsPage() : const FavoritesPage(),
        ),
      ),
    );
  }
}
