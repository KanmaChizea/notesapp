import 'package:flutter/material.dart';
import 'package:notesapp/Screens/new_note.dart';
import 'package:notesapp/Services/auth_service.dart';
import 'package:notesapp/database/sqlite-database.dart';

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  String get userEmail => AuthService().currentUser!.email ?? '';

  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.openDbase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final username = currentUser?.displayName ?? '';
    final displayUsername =
        username.replaceFirst(username[0], username[0].toUpperCase());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            currentUser?.photoURL ??
                'https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg',
          ),
          radius: 20,
        ),
        title: Text("$displayUsername's Notes"),
        actions: [
          PopupMenuButton(
              onSelected: (value) {
                if (value == 'Logout') {
                  AuthService().signOut();
                }
                if (value == 'Settings') {
                  Navigator.of(context).pushNamed('/settings');
                }
              },
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text('Settings'),
                      value: 'Settings',
                    ),
                    const PopupMenuItem(
                      child: Text('Logout'),
                      value: 'Logout',
                    )
                  ])
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/new_note'),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
          future: NotesService().getOrCreateUser(
              email: currentUser!.email ?? '',
              name: currentUser.displayName ?? ''),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: _notesService.allnotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Center(child: Text('You have no notes'));
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final data = snapshot.data as List<DatabaseNote>;

                            return ListView.builder(
                                itemCount: data.length,
                                itemBuilder: ((context, index) {
                                  return Dismissible(
                                      key: ValueKey(data[index].id),
                                      direction: DismissDirection.horizontal,
                                      confirmDismiss: (_) => prompt(),
                                      onDismissed: (_) =>
                                          onDismissedNote(data[index]),
                                      background: Container(
                                        color: Colors.red,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0),
                                            child: Row(
                                              children: const [
                                                Icon(Icons.delete,
                                                    color: Colors.white,
                                                    size: 30),
                                                Text(
                                                  'DELETE',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: GestureDetector(
                                          child: Card(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15.0,
                                                      vertical: 5),
                                              elevation: 1.5,
                                              shadowColor: Theme.of(context)
                                                  .primaryColor,
                                              child: Container(
                                                width: double.infinity,
                                                height: 80,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 10, 8, 8),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      data[index].title,
                                                      style: const TextStyle(
                                                          fontSize: 17.5,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Text(
                                                      ' ${data[index].body.replaceAll("\n", " ")}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey.shade800),
                                                    ),
                                                    Text(
                                                      "Last updated on ${data[index].lastUpdated}",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors
                                                              .grey.shade700),
                                                    )
                                                  ],
                                                ),
                                              )),
                                          onTap: () =>
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: ((context) =>
                                                        NewNote(
                                                          oldNote: data[index],
                                                        ))),
                                              )));
                                }));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        default:
                          return Container();
                      }
                    });
              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }

  Future onDismissedNote(DatabaseNote deletedNote) async {
    await _notesService.deleteNote(id: deletedNote.id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Deleted.'),
      duration: Duration(seconds: 2),
    ));
  }

  Future<bool> prompt() async {
    return await showModalBottomSheet<bool>(
          backgroundColor: Colors.white.withOpacity(0.8),
          elevation: 2,
          barrierColor: Theme.of(context).primaryColor.withOpacity(0.2),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          context: context,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.25,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                'Delete',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1),
              ),
              const Spacer(),
              const Text('Are you sure you want to delete this note?',
                  style: TextStyle(fontSize: 18, letterSpacing: 1)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel',
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.grey,
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          minimumSize: const Size(120, 50))),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete',
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          minimumSize: const Size(120, 50)))
                ],
              )
            ]),
          ),
        ) ??
        false;
  }
}
