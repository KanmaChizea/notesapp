import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:notesapp/Screens/loading_screen.dart';
import 'package:notesapp/Services/auth_service.dart';
import 'package:notesapp/styles/formstyles.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  static final _formkey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return _isLoading
        ? const LoadingScreen()
        : Scaffold(
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
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
                          'Login.',
                          style: TextStyle(
                              //  color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 40),
                        ),
                        const SizedBox(height: 40),
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
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            _formkey.currentState?.save();
                            if (_formkey.currentState?.validate() ?? false) {
                              final data = _formkey.currentState?.value;

                              await AuthService().signIn(
                                  email: data?['email'],
                                  password: data?['password']);
                            }
                          },
                          child: const Text('Login'),
                          style: buttonStyle(width),
                        ),
                        TextButton(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                                context, '/register', (route) => false),
                            child: const Text(
                                "Don't have an account? Click here to register")),
                      ]),
                ),
              ),
            ),
          );
  }
}
