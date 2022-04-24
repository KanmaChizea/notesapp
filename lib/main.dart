import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/Screens/loginscreen.dart';
import 'package:notesapp/Screens/new_note.dart';
import 'package:notesapp/Screens/notes_screen.dart';
import 'package:notesapp/Screens/registerscreen.dart';
import 'package:notesapp/Screens/settings.dart';
import 'package:notesapp/Services/auth_service.dart';
import 'package:notesapp/Utils/wrapper.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider<User?>.value(
            value: AuthService().user,
            initialData: null,
          ),
          StreamProvider<User?>.value(
            value: AuthService().userid,
            initialData: null,
          ),
        ],
        builder: (context, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.orange,
                appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: IconThemeData(color: Colors.black, size: 23),
                    titleTextStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 23)),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: Colors.orangeAccent),
              ),
              home: const Wrapper(),
              routes: {
                '/login': (context) => const Login(),
                '/register': (context) => const Register(),
                '/notesview': (context) => const Notes(),
                '/new_note': (context) => NewNote(),
                '/settings': (context) => const Settings()
              });
        });
  }
}
