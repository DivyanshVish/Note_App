import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a new note to Firestore
  Future<void> addNotes(String note) async {
    await _firestore.collection('notes').add({'note': note});
  }

  // Method to get a stream of notes from Firestore
  Stream<QuerySnapshot> getNotesStream() {
    return _firestore.collection('notes').snapshots();
  }

  // Method to update a note in Firestore
  Future<void> updateNotes(String id, String note) async {
    await _firestore.collection('notes').doc(id).update({'note': note});
  }

  // Method to delete a note from Firestore
  Future<void> deleteNotes(String id) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}
