import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notesapp/Services/auth_service.dart';

final imagePicker = ImagePicker();
File? image;
final uid = AuthService().currentUser?.uid;

Future<File?> imagePickerMethod() async {
  final pick = await imagePicker.pickImage(source: ImageSource.gallery);
  if (pick != null) {
    return image = File(pick.path);
  }
  return null;
}

//function to upload image to firestore
Future<String> uploadImage() async {
  Reference ref = FirebaseStorage.instance.ref().child('$uid/images');
  ref.putFile(image!);
  return await ref.getDownloadURL();
}
