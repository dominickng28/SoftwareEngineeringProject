import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  Future<void> sendFriendRequest(
      String senderUsername, String receiverUsername) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Sending a friend request
    await users.doc(senderUsername).update({
      'sent_requests': FieldValue.arrayUnion([receiverUsername]),
    });

    // Receiving a friend request
    await users.doc(receiverUsername).update({
      'received_requests': FieldValue.arrayUnion([senderUsername]),
    });
  }

  Stream<String?> userProfilePictureStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.data()?['profile_picture'] as String?;
    });
  }

  Future<String?> loadUserProfilePicture(String username) async {
    // Removed the underscore

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    return userDoc[
        'profile_picture']; // assuming the field name is 'profile_picture'
  }

  Future<void> acceptFriendRequest(
      String username, String friendUsername) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Accepting a friend request
    await users.doc(username).update({
      'friends': FieldValue.arrayUnion([friendUsername]),
      'received_requests': FieldValue.arrayRemove([friendUsername]),
    });

    // Becoming a friend
    await users.doc(friendUsername).update({
      'friends': FieldValue.arrayUnion([username]),
      'sent_requests': FieldValue.arrayRemove([username]),
    });
  }

  Future<void> cancelFriendRequest(
      String senderUsername, String receiverUsername) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Canceling a sent friend request
    await users.doc(senderUsername).update({
      'sent_requests': FieldValue.arrayRemove([receiverUsername]),
    });

    // Removing a received friend request
    await users.doc(receiverUsername).update({
      'received_requests': FieldValue.arrayRemove([senderUsername]),
    });
  }

  Future<void> removeFriend(String username, String friendUsername) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Removing a friend
    await users.doc(username).update({
      'friends': FieldValue.arrayRemove([friendUsername]),
    });

    // Being removed as a friend
    await users.doc(friendUsername).update({
      'friends': FieldValue.arrayRemove([username]),
    });
  }

  Stream<List<String>> sentFriendRequestsStream(String username) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .snapshots()
        .map((snap) => List<String>.from(snap.data()?['sent_requests'] ?? []));
  }

  Stream<List<String>> receivedFriendRequestsStream(String username) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .snapshots()
        .map((snapshot) {
      // Using null-aware operator to avoid error if 'received_requests' field doesn't exist
      List<String> friendRequests =
          snapshot.data()?['received_requests']?.cast<String>() ?? [];
      return friendRequests;
    });
  }

  Stream<List<String>> friendsStream(String username) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .snapshots()
        .map((snapshot) {
      // Using null-aware operator to avoid error if 'friends' field doesn't exist
      List<String> friends = snapshot.data()?['friends']?.cast<String>() ?? [];
      return friends;
    });
  }
}
