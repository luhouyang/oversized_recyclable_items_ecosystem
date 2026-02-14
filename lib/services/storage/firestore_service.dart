import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oversized_recyclable_items_ecosystem/entities/item_entity.dart';
import 'package:oversized_recyclable_items_ecosystem/entities/user_entity.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- USER OPERATIONS ---

  Future<void> saveUser(UserEntity user) async {
    // Merge to avoid overwriting existing points if we only have basic info
    await _db.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserEntity?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserEntity.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> addPoints(String uid, int amount) async {
    await _db.collection('users').doc(uid).update({
      'points': FieldValue.increment(amount),
    });
  }

  // --- ITEM OPERATIONS ---

  Future<void> addItem(ItemEntity item) async {
    await _db.collection('items').add(item.toMap());
  }
  
  Future<void> updateItem(ItemEntity item) async {
    await _db.collection('items').doc(item.id).update(item.toMap());
  }

  Stream<List<ItemEntity>> getUserItems(String userId) {
    return _db
        .collection('items')
        .where('userId', isEqualTo: userId)
        .orderBy('dateCreated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ItemEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<ItemEntity>> getStoreItems() {
    return _db
        .collection('items')
        .where('available', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ItemEntity.fromMap(doc.data(), doc.id)).toList());
  }
  
  Stream<List<ItemEntity>> getAllItemsForAdmin() {
    return _db
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ItemEntity.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateItemAvailability(String itemId, bool isAvailable) async {
    await _db.collection('items').doc(itemId).update({'available': isAvailable});
  }

  Future<void> deleteItem(String itemId) async {
    await _db.collection('items').doc(itemId).delete();
  }
}