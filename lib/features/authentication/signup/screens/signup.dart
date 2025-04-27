import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/constants/utils.dart';
import 'package:instagram/features/authentication/signup/services/signupmethods.dart';
import 'package:instagram/features/authentication/widgets/textfield.dart';
import 'package:instagram/features/home/screens/homescreen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
  }

  void selectProfileImage() async {
    Uint8List image = await getImage(ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _signUp() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a profile image')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final result = await Signup().signUp(
      email: emailController.text,
      password: passwordController.text,
      userName: userNameController.text,
      file: _image!,
    );
    if (result == "success creating account") {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
      }
    }

    if (mounted) {
      customSnackBar(context, result);
    }
    setState(
      () {
        _isLoading = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 25),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Container(),
                ),
                Text("FrameClub",
                    style: GoogleFonts.xanhMono(
                        fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _image != null
                          ? MemoryImage(_image!)
                          : const NetworkImage(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/340px-Default_pfp.svg.png?20220226140232")
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: -10,
                      child: IconButton(
                        onPressed: selectProfileImage,
                        icon: const Icon(
                          Icons.add_a_photo,
                          size: 30,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: 'Enter your Username',
                  textFieldController: userNameController,
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: 'Enter your Email',
                  textFieldController: emailController,
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: 'Enter your Password',
                  textFieldController: passwordController,
                  textInputType: TextInputType.text,
                  isObscure: true,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _signUp,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.blue),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              value: 15,
                            ),
                          )
                        : const Text("Sign In",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: Container(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Login'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
