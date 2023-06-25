import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final user = FirebaseAuth.instance.currentUser!;
  Future<void> addFavorite(
      String title, String imageUrl, String description, String url) async {
    var collection =
        FirebaseFirestore.instance.collection('Users/${user.uid}/favorites');
    collection.doc(title).set({
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'url': url
    });
  }

  Future<void> addComment(String text, String title) async {
    var collection =
        FirebaseFirestore.instance.collection('Posts/$title/comment');
    collection.add({'text': text, 'email': user.email});
  }

  Future<void> deleteFavorite(String title) async {
    var collection =
        FirebaseFirestore.instance.collection('Users/${user.uid}/favorites');
    collection.doc(title).delete();
  }

  Future<bool> getFavorite(String title) async {
    try {
      var collectionuser =
          FirebaseFirestore.instance.collection('Users/${user.uid}/favorites');
      var docSnapshotuser = await collectionuser.doc(title).get();
      if (docSnapshotuser.exists) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
