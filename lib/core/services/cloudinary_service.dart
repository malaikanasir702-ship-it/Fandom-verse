import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// Cloudinary CDN Service for Fandom Verse Pocket Edition
/// Cloud: hpihaiub
class CloudinaryService {
  static const String _cloudName = 'hpihaiub';
  static const String _apiKey = '637556628869215';
  static const String _apiSecret = 'leKpBv-BJWrIvbTAjB8sfHEL6aAye';
  static const String _uploadBaseUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName';

  // ── Folder constants ──────────────────────────────────────────────────────
  static const String folderAvatars = 'fandom_verse/avatars';
  static const String folderPosts = 'fandom_verse/posts';
  static const String folderEvents = 'fandom_verse/events';
  static const String folderMerchandise = 'fandom_verse/merchandise';
  static const String folderHeroStories = 'fandom_verse/hero_stories';
  static const String folderPodcasts = 'fandom_verse/podcasts';
  static const String folderVideos = 'fandom_verse/videos';
  static const String folderCategories = 'fandom_verse/categories';

  static final CloudinaryService _instance = CloudinaryService._();
  CloudinaryService._();
  static CloudinaryService get instance => _instance;

  // ── Upload Image from File ────────────────────────────────────────────────
  Future<String> uploadImage(File imageFile, {String folder = folderPosts}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // All params that will be sent (excluding file & api_key, sorted alpha)
    final params = <String, String>{
      'folder': folder,
      'timestamp': timestamp.toString(),
    };
    final signature = _sign(params);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadBaseUrl/image/upload'),
    );

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp.toString();
    request.fields['folder'] = folder;
    request.fields['signature'] = signature;

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    debugPrint('[Cloudinary] Uploading image → $folder');
    final response = await request.send().timeout(const Duration(seconds: 30));
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final url = data['secure_url'] as String;
      debugPrint('[Cloudinary] ✅ Image uploaded: $url');
      return url;
    } else {
      debugPrint('[Cloudinary] ❌ Upload failed (${response.statusCode}): $body');
      throw Exception('Cloudinary upload failed (${response.statusCode}): $body');
    }
  }

  // ── Upload Image from Bytes ───────────────────────────────────────────────
  Future<String> uploadImageBytes(
    Uint8List bytes,
    String filename, {
    String folder = folderPosts,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final params = <String, String>{
      'folder': folder,
      'timestamp': timestamp.toString(),
    };
    final signature = _sign(params);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadBaseUrl/image/upload'),
    );

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp.toString();
    request.fields['folder'] = folder;
    request.fields['signature'] = signature;

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final response = await request.send().timeout(const Duration(seconds: 30));
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    } else {
      throw Exception('Cloudinary image bytes upload failed (${response.statusCode}): $body');
    }
  }

  // ── Upload Video from File ────────────────────────────────────────────────
  Future<String> uploadVideo(File videoFile, {String folder = folderVideos}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final params = <String, String>{
      'folder': folder,
      'resource_type': 'video',
      'timestamp': timestamp.toString(),
    };
    final signature = _sign(params);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadBaseUrl/video/upload'),
    );

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp.toString();
    request.fields['folder'] = folder;
    request.fields['resource_type'] = 'video';
    request.fields['signature'] = signature;

    request.files.add(
      await http.MultipartFile.fromPath('file', videoFile.path),
    );

    debugPrint('[Cloudinary] Uploading video → $folder');
    final response = await request.send().timeout(const Duration(seconds: 120));
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final url = data['secure_url'] as String;
      debugPrint('[Cloudinary] ✅ Video uploaded: $url');
      return url;
    } else {
      throw Exception('Cloudinary video upload failed (${response.statusCode}): $body');
    }
  }

  // ── Upload Audio from File ────────────────────────────────────────────────
  Future<String> uploadAudio(File audioFile, {String folder = folderPodcasts}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final params = <String, String>{
      'folder': folder,
      'resource_type': 'video',
      'timestamp': timestamp.toString(),
    };
    final signature = _sign(params);

    // Cloudinary treats audio as 'video' resource type
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadBaseUrl/video/upload'),
    );

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp.toString();
    request.fields['folder'] = folder;
    request.fields['resource_type'] = 'video';
    request.fields['signature'] = signature;

    request.files.add(
      await http.MultipartFile.fromPath('file', audioFile.path),
    );

    debugPrint('[Cloudinary] Uploading audio → $folder');
    final response = await request.send().timeout(const Duration(seconds: 120));
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final url = data['secure_url'] as String;
      debugPrint('[Cloudinary] ✅ Audio uploaded: $url');
      return url;
    } else {
      throw Exception('Cloudinary audio upload failed (${response.statusCode}): $body');
    }
  }

  // ── Upload via URL ────────────────────────────────────────────────────────
  Future<String> uploadFromUrl(String sourceUrl, {String folder = folderPosts}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final params = <String, String>{
      'folder': folder,
      'timestamp': timestamp.toString(),
    };
    final signature = _sign(params);

    final response = await http.post(
      Uri.parse('$_uploadBaseUrl/image/upload'),
      body: {
        'file': sourceUrl,
        'api_key': _apiKey,
        'timestamp': timestamp.toString(),
        'folder': folder,
        'signature': signature,
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    } else {
      debugPrint('[Cloudinary] uploadFromUrl failed (${response.statusCode}): ${response.body}');
      return sourceUrl; // fallback — return original URL
    }
  }

  // ── Delete Asset ─────────────────────────────────────────────────────────
  Future<bool> deleteAsset(String publicId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final params = <String, String>{
      'public_id': publicId,
      'timestamp': timestamp.toString(),
    };
    final signature = _sign(params);

    final response = await http.post(
      Uri.parse('$_uploadBaseUrl/image/destroy'),
      body: {
        'public_id': publicId,
        'api_key': _apiKey,
        'timestamp': timestamp.toString(),
        'signature': signature,
      },
    );

    return response.statusCode == 200;
  }

  // ── URL Optimization Helpers ──────────────────────────────────────────────
  static String optimizeUrl(
    String url, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'fill',
  }) {
    if (!url.contains('res.cloudinary.com')) return url;
    final transforms = <String>['q_$quality', 'f_$format'];
    if (width != null) transforms.add('w_$width');
    if (height != null) transforms.add('h_$height');
    if (width != null || height != null) transforms.add('c_$crop');
    return url.replaceFirst('/upload/', '/upload/${transforms.join(',')}/');
  }

  static String thumbnail(String url, {int width = 400}) =>
      optimizeUrl(url, width: width);

  static String avatar(String url) =>
      optimizeUrl(url, width: 200, height: 200, crop: 'fill');

  static String banner(String url) =>
      optimizeUrl(url, width: 800);

  static bool isCloudinaryUrl(String url) =>
      url.contains('res.cloudinary.com') && url.contains(_cloudName);

  // ── HMAC-SHA1 Signature (Cloudinary spec) ────────────────────────────────
  /// Cloudinary signed upload signature:
  ///   SHA1( "param1=val1&param2=val2" + apiSecret )
  /// where params are all non-file, non-api_key fields, sorted alphabetically.
  String _sign(Map<String, String> params) {
    // Sort keys alphabetically
    final sortedKeys = params.keys.toList()..sort();
    final paramString =
        sortedKeys.map((k) => '$k=${params[k]}').join('&');
    final toSign = '$paramString$_apiSecret';
    return sha1.convert(utf8.encode(toSign)).toString();
  }
}
