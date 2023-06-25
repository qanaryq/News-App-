import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/firebase_service.dart';

class CommentsPage extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final String url;
  const CommentsPage(
      {super.key,
      required this.image,
      required this.title,
      required this.description,
      required this.url});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  bool addedFavorite = false;
  var commentController = TextEditingController();
  String commentText = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Comments"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Card(
                  child: Column(
                    children: [
                      Image.network(widget.image ??
                          'https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132484366.jpg'),
                      ListTile(
                        title: Text(
                          widget.title ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          widget.description ?? '',
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
                                        image: widget.image ??
                                            'https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132484366.jpg',
                                        title: widget.title ?? '',
                                        description: widget.description ?? '',
                                        url: widget.url ?? '')),
                              );
                            },
                            child: Row(
                              children: [
                                MaterialButton(
                                  onPressed: () async {
                                    setState(() {
                                      if (addedFavorite == false) {
                                        FirebaseService().addFavorite(
                                            widget.title.toString(),
                                            widget.image,
                                            widget.description,
                                            widget.url);
                                      } else {
                                        FirebaseService().deleteFavorite(
                                            widget.title.toString());
                                      }
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      FutureBuilder(
                                        future: FirebaseService().getFavorite(
                                            widget.title.toString()),
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
                              await launchUrl(Uri.parse(widget.url ?? ''));
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
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Posts/${widget.title}/comment')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.data!.docs.map((doc) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, top: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.account_circle_rounded,
                                        size: 30,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc!['email'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(doc!['text']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        }).toList(),
                      );
                    }
                  },
                )
              ],
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  controller: commentController,
                  onChanged: (value) {
                    setState(() {
                      commentText = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    hintText: 'Write a review...',
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      FirebaseService().addComment(commentText, widget.title);
                      commentController.text = "";
                      commentText = "";
                    });
                  },
                  icon: Icon(
                    Icons.send,
                    color: (commentText == "")
                        ? Colors.grey.shade400
                        : Colors.blue,
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
