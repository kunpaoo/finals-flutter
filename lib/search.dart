import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a search term to user's search history
  Future<void> addSearchToHistory(String searchTerm) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('user_search_history')
          .doc(currentUser.uid)
          .collection('searches')
          .add({
        'term': searchTerm,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding search to history: $e');
    }
  }

  // Retrieve search history for the current user
  Stream<List<String>> getSearchHistory() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('user_search_history')
        .doc(currentUser.uid)
        .collection('searches')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['term'] as String).toList());
  }
}
