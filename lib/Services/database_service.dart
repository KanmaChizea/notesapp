import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesapp/Services/image_picker.dart';
import 'package:notesapp/database/sqlite-database.dart';

class DatabaseService {
  Future syncWithCloud(List<DatabaseNote> notes) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(uid!);
    final snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
    for (int i = 0; i < notes.length; i++) {
      await FirebaseFirestore.instance
          .collection(uid!)
          .doc(notes[i].id.toString())
          .set({'title': notes[i].title, 'body': notes[i].body});
    }
  }
}
