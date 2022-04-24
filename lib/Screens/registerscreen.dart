import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:notesapp/Screens/loading_screen.dart';
import 'package:notesapp/Services/auth_service.dart';
import 'package:notesapp/Services/image_picker.dart';
import 'package:notesapp/styles/formstyles.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isLoading = false;
  final _formkey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    File? avatar;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return _isLoading
        ? const LoadingScreen()
        : Scaffold(
            body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FormBuilder(
                key: _formkey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      SizedBox(
                        height: height / 3,
                        width: width,
                        child: Image.asset(
                          'lib/assets/3.jpg',
                          alignment: Alignment.bottomRight,
                          colorBlendMode: BlendMode.clear,
                        ),
                      ),
                      const Text(
                        'Register.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      const SizedBox(height: 10),
                      Stack(children: [
                        Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey,
                              child: avatar == null
                                  ? const Image(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          'https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg',
                                          scale: 2))
                                  : Image(
                                      fit: BoxFit.fill,
                                      image: FileImage(avatar)),
                            )),
                        Positioned(
                            bottom: -15,
                            right: 130,
                            child: IconButton(
                              icon: const Icon(Icons.add_a_photo),
                              onPressed: () async {
                                final selectedImage = await imagePickerMethod();
                                setState(() {
                                  avatar = selectedImage;
                                });
                              },
                            ))
                      ]),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'username',
                        decoration: formStyle(
                            labeltext: 'Username', icon: Icons.person_outline),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'email',
                        decoration: formStyle(
                            labeltext: 'Email', icon: Icons.email_outlined),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        name: 'password',
                        decoration: formStyle(
                            labeltext: 'Password', icon: Icons.lock_outline),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          style: buttonStyle(width),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            String? photoURL;
                            if (avatar != null) {
                              photoURL = await uploadImage();
                            }
                            _formkey.currentState?.save();
                            if (_formkey.currentState?.validate() ?? false) {
                              final data = _formkey.currentState?.value;

                              await AuthService().register(
                                  email: data?['email'],
                                  password: data?['password'],
                                  username: data?['username'],
                                  photoURL: photoURL);
                              // NotesService().openDbase;
                              // await NotesService().createUser(
                              //     email: data?['email'], name: data?['username']);
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          child: const Text('Register')),
                      TextButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false),
                          child: const Text(
                              "Already have an account? Click here to log in")),
                    ]),
              ),
            ),
          ));
  }
}
