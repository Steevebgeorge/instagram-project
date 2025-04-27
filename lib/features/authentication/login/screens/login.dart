import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram/constants/utils.dart';
import 'package:instagram/features/authentication/login/services/login.dart';
import 'package:instagram/features/authentication/signup/screens/signup.dart';
import 'package:instagram/features/authentication/widgets/textfield.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void login() async {
    setState(() {
      _isLoading = true;
    });
    String res = await Login().logInUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res == 'success') {
      //success signing in
      if (mounted) {
        customSnackBar(context, "Successfully logged in");
      }
    } else {
      if (mounted) {
        customSnackBar(context, res);
      }
    }
    setState(() {
      _isLoading = false;
    });
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
                Flexible(flex: 2, child: Container()),
                Text("FrameClub",
                    style: GoogleFonts.xanhMono(
                        fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
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
                  onTap: login,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.blue),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const Text("Log In",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Flexible(flex: 2, child: Container()),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Dont have an account?'),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ));
                      },
                      child: const Text('sign up',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
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
