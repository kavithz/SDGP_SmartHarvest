// lib/features/crop_management/data/datasources/crop_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/crop_model.dart';

abstract class CropRemoteDataSource {
  Future<List<CropModel>> getCrops();
  Future<CropModel>       getCropById(String id);
  Future<CropModel>       addCrop(CropModel crop);
  Future<CropModel>       updateCrop(CropModel crop);
  Future<void>            deleteCrop(String id);
  Stream<List<CropModel>> watchCrops();
}

class CropRemoteDataSourceImpl implements CropRemoteDataSource {
  final ApiClient _api;
  final FirebaseFirestore _firestore;

  CropRemoteDataSourceImpl({
    ApiClient? apiClient,
    FirebaseFirestore? firestore,
  })  : _api       = apiClient  ?? ApiClient.instance,
        _firestore  = firestore  ?? FirebaseFirestore.instance;

  // Guard: throw early if user is not logged in.
  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw const AuthException(message: 'User is not authenticated.');
    }
    return uid;
  }

  // ── REST-backed CRUD ───────────────────────────────────────────────────────

  @override
  Future<List<CropModel>> getCrops() async {
    try {
      final data = await _api.get(ApiConstants.cropsAll) as List<dynamic>;
      return data
          .map((e) => CropModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch crops: $e');
    }
  }

  @override
  Future<CropModel> getCropById(String id) async {
    try {
      final data = await _api.get(ApiConstants.cropById(id));
      return CropModel.fromJson(data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch crop: $e');
    }
  }

  @override
  Future<CropModel> addCrop(CropModel crop) async {
    try {
      final body = {
        'name':        crop.name,
        'type':        crop.type,
        'quantity':    crop.quantity,
        'unit':        crop.unit,
        'location':    crop.location,
        'plantedDate': crop.plantedDate.toIso8601String(),
        if (crop.harvestDate != null)
          'harvestDate': crop.harvestDate!.toIso8601String(),
        'status':      crop.status,
        if (crop.notes != null) 'notes': crop.notes,
      };
      final data = await _api.post(ApiConstants.cropsAdd, body);
      return CropModel.fromJson(data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to add crop: $e');
    }
  }

  @override
  Future<CropModel> updateCrop(CropModel crop) async {
    try {
      final body = {
        'name':        crop.name,
        'type':        crop.type,
        'quantity':    crop.quantity,
        'unit':        crop.unit,
        'location':    crop.location,
        'plantedDate': crop.plantedDate.toIso8601String(),
        if (crop.harvestDate != null)
          'harvestDate': crop.harvestDate!.toIso8601String(),
        'status':      crop.status,
        if (crop.notes != null) 'notes': crop.notes,
      };
      final data = await _api.put(ApiConstants.updateCrop(crop.id), body);
      return CropModel.fromJson(data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update crop: $e');
    }
  }

  @override
  Future<void> deleteCrop(String id) async {
    try {
      await _api.delete(ApiConstants.deleteCrop(id));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to delete crop: $e');
    }
  }

  // ── Real-time stream (Firestore — REST doesn't support streaming) ──────────
  // Uses the UID guard so an unauthenticated caller gets an early exception
  // rather than a silent empty-string query.
  @override
  Stream<List<CropModel>> watchCrops() {
    final uid = _uid; // throws AuthException if not logged in
    return _firestore
        .collection('crops')
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CropModel.fromFirestore).toList())
        .handleError((e) {
      throw ServerException(
        message: e is FirebaseException
            ? (e.message ?? 'Stream error.')
            : e.toString(),
      );
    });
  }
}
