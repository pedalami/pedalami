import 'dart:io';

import 'package:image_picker/image_picker.dart';

File? _image;
final picker = ImagePicker();

Future<File?> getImageCamera() async {
  final pickedFile =
  await picker.getImage(source: ImageSource.camera, imageQuality: 10);
  if (pickedFile != null) {
    _image = File(pickedFile.path);
  }
  return _image;
}

Future<File?> getImageGallery() async {
  final pickedFile =
  await picker.getImage(source: ImageSource.gallery, imageQuality: 10);
  if (pickedFile != null) {
    _image = File(pickedFile.path);
  }
  return _image;
}
