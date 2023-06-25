import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:untitled1/pages/comments_page.dart';
import 'package:untitled1/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users/${user.uid}/favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            bool addedFavorite = false;
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return Card(
                  child: Column(
                    children: [
                      Image.network(doc['imageUrl'] ??
                          'https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132484366.jpg'),
                      ListTile(
                        title: Text(
                          doc['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          doc['description'] ?? '',
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
                                        image: doc['imageUrl'] ??
                                            'https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132484366.jpg',
                                        title: doc['title'] ?? '',
                                        description: doc['description'] ?? '',
                                        url: doc['url'] ?? '')),
                              );
                            },
                            child: Row(
                              children: [
                                MaterialButton(
                                  onPressed: () async {
                                    setState(() {
                                      if (addedFavorite == false) {
                                        FirebaseService().addFavorite(
                                            doc['title'].toString(),
                                            doc['imageUrl'],
                                            doc['description'],
                                            doc['url']);
                                      } else {
                                        FirebaseService().deleteFavorite(
                                            doc['title'].toString());
                                      }
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      FutureBuilder(
                                        future: FirebaseService().getFavorite(
                                            doc['title'].toString()),
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
                                            duration: const Duration(
                                                milliseconds: 400),
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
                                                                color: Colors
                                                                    .black,
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
                                                                color: Colors
                                                                    .black),
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
                              await launchUrl(Uri.parse(doc['url'] ?? ''));
                            },
                            child: const Text(
                              'Go To News',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
