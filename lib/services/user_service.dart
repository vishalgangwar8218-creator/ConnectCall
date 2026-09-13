import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _cloudinaryCloudName = 'ncxmts2l';
  static const String _cloudinaryUploadPreset = 'ConnectCall';

  Future<String> uploadProfilePhoto(String uid, File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _cloudinaryUploadPreset
      ..fields['public_id'] = 'profile_photos/$uid'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Upload failed (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }

  Stream<List<UserModel>> streamContacts() {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    return _firestore
        .collection(AppConstants.usersCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.id != myUid)
            .map((doc) => UserModel.fromMap(doc.id, doc.data()))
            .toList()
    );
  }

  List<UserModel> filterByName(List<UserModel> users, String query) {
    if (query.trim().isEmpty) return users;
    final lower = query.toLowerCase();
    return users.where((u) => u.name.toLowerCase().contains(lower)).toList();
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateProfile(String uid, {String? name, String? photoUrl}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (data.isEmpty) return;
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }
}