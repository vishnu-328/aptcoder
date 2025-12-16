import 'package:aptcoder/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _allUsers = [];
  bool _isLoading = false;

  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;

  // Fetch all users (admin)
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      _allUsers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update user points
  Future<void> updatePoints(String userId, int points) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'totalPoints': FieldValue.increment(points),
      });
    } catch (e) {
      debugPrint('Error updating points: $e');
    }
  }
}
