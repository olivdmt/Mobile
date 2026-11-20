import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

abstract interface class CatalogPhotoPicker {
  Future<String?> takePhoto();
  Future<String?> chooseFromGallery();
  Future<String?> retrieveLostPhoto();
}

class ImagePickerCatalogPhotoPicker implements CatalogPhotoPicker {
  ImagePickerCatalogPhotoPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> takePhoto() => _pick(ImageSource.camera);

  @override
  Future<String?> chooseFromGallery() => _pick(ImageSource.gallery);

  @override
  Future<String?> retrieveLostPhoto() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) return null;
    final files = response.files;
    if (files == null || files.isEmpty) {
      _throwPickerError(response.exception);
    }
    return _compressAndEncode(files.first);
  }

  Future<String?> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 55,
        requestFullMetadata: false,
      );
      return file == null ? null : await _compressAndEncode(file);
    } on PlatformException catch (error) {
      if (source == ImageSource.camera &&
          (error.code == 'camera_access_denied' ||
              error.code == 'camera_access_denied_without_prompt')) {
        throw const CatalogPhotoPermissionDenied();
      }
      throw const CatalogPhotoPickerFailure();
    }
  }

  Future<String> _compressAndEncode(XFile file) async =>
      base64Encode(await file.readAsBytes());

  Never _throwPickerError(Object? error) {
    if (error is PlatformException &&
        (error.code == 'camera_access_denied' ||
            error.code == 'camera_access_denied_without_prompt')) {
      throw const CatalogPhotoPermissionDenied();
    }
    throw const CatalogPhotoPickerFailure();
  }
}

class CatalogPhotoPermissionDenied implements Exception {
  const CatalogPhotoPermissionDenied();
}

class CatalogPhotoPickerFailure implements Exception {
  const CatalogPhotoPickerFailure();
}
