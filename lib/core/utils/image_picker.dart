import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImageFile() async {
  final ImagePicker picker = ImagePicker();

  try {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path); // Return File object
    }
  } catch (e) {
    print('Error picking image: $e');
  }

  return null; // No file selected or error
}