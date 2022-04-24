import 'package:flutter/material.dart';

import 'package:notesapp/Services/auth_service.dart';
import 'package:notesapp/database/sqlite-database.dart';

class NewNote extends StatefulWidget {
  DatabaseNote? oldNote;
  NewNote({
    Key? key,
    this.oldNote,
  }) : super(key: key);

  @override
  State<NewNote> createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    _note = widget.oldNote;
    _notesService = NotesService();
    _notesService.openDbase();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    initializeTextFields();
    super.initState();
  }

  void initializeTextFields() {
    if (_note != null) {
      _titleController.text = _note!.title;
      _bodyController.text = _note!.body;
    }
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final user = AuthService().currentUser!;
    final email = user.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteWithEmptyBody() async {
    final note = _note;
    if (_bodyController.text.isEmpty && note != null) {
      await _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteWithoutEmptyBody() async {
    final note = _note;
    if (_bodyController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        note: note,
        newBody: _bodyController.text,
        newTitle: _titleController.text,
      );
    }
  }

  void _bodyControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final body = _bodyController.text;
    await _notesService.updateNote(note: note, newBody: body);
  }

  void _titleControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    } else {
      final title = _titleController.text;
      await _notesService.updateNote(note: note, newTitle: title);
    }
  }

  void setupBodyController() {
    _bodyController.removeListener(_bodyControllerListener);
    _bodyController.addListener(_bodyControllerListener);
  }

  void setupTitleController() {
    _titleController.removeListener(_titleControllerListener);
    _titleController.addListener(_titleControllerListener);
  }

  @override
  void dispose() {
    _deleteNoteWithEmptyBody();
    _saveNoteWithoutEmptyBody();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
          future: createNewNote(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _note = snapshot.data as DatabaseNote;
                return ListView(shrinkWrap: true, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 0, 15, 0),
                    child: TextField(
                        controller: _titleController,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                        decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: const TextStyle(fontSize: 20),
                            enabledBorder: const UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.5)))),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bodyController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 30,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    decoration: const InputDecoration(
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ]);

              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          }),
    );
  }
}
