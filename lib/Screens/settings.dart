import 'package:flutter/material.dart';
import 'package:notesapp/Services/database_service.dart';
import 'package:notesapp/database/sqlite-database.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late DatabaseService _databaseService;
  late NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    _databaseService = DatabaseService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: [
            buildHeader('ACCOUNT'),
            buildComponent('Change user information', Icons.account_circle),
            buildComponent('Change Password', Icons.password),
            const Divider(
              height: 20,
              color: Colors.orange,
              thickness: 0.5,
            ),
            buildHeader('THEMES'),
            buildComponent('Light Theme', Icons.light_mode),
            buildComponent('Dark Mode', Icons.dark_mode),
            const Divider(
              height: 20,
              color: Colors.orange,
              thickness: 0.5,
            ),
            buildHeader('DELETE'),
            buildComponent('Delete all notes', Icons.delete_sweep),
            buildComponent('Delete account', Icons.person_remove),
            const Divider(
              height: 20,
              color: Colors.orange,
              thickness: 0.5,
            ),
            buildHeader('SYNCHRONIZE'),
            buildComponent('Sync with cloud', Icons.cloud_upload)
          ],
        ),
      ),
    );
  }

  ListTile buildComponent(String text, IconData icon) {
    return ListTile(
      onTap: () {
        switch (text) {
          case 'Sync with cloud':
            return _sync();
        }
      },
      title: Text(text),
      trailing: Icon(icon, size: 27),
    );
  }

  Text buildHeader(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.orange.withOpacity(0.6)),
    );
  }

  _sync() async {
    final allnotes = await _notesService.getAllNotes();
    return FutureBuilder(
        future: _databaseService.syncWithCloud(allnotes),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              // TODO: Handle this case.
              break;
            case ConnectionState.waiting:
              // TODO: Handle this case.
              break;
            case ConnectionState.active:
              // TODO: Handle this case.
              break;
            case ConnectionState.done:
              // TODO: Handle this case.
              break;
          }
          return Container();
        });
  }
}
