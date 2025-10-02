// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _sensorsCollection =
      FirebaseFirestore.instance.collection('sensors');

  Stream<DocumentSnapshot<Map<String, dynamic>>> getEnvironmentStream() {
    return _sensorsCollection.doc('environment').snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getEnvironmentOnce() {
    return _sensorsCollection.doc('environment').get();
  }

  Future<void> updateEnvironmentData(Map<String, dynamic> newData) {
    return _sensorsCollection.doc('environment').update(newData);
  }
}
