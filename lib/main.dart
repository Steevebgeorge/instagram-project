import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/features/authentication/login/screens/login.dart';
import 'package:instagram/features/home/screens/homescreen.dart';
import 'package:instagram/firebase_options.dart';
import 'package:instagram/providers/userprovider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Frame Club',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.black,
          scaffoldBackgroundColor: lightModeBackgroundColor,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey[400],
            backgroundColor: lightModeBackgroundColor,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: lightModeBackgroundColor,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.white,
          scaffoldBackgroundColor: darkModeBackgroundColor,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey[800],
            backgroundColor: Colors.black,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: darkModeBackgroundColor,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              return const HomeScreen();
            }

            return const Loginscreen();
          },
        ),
      ),
    );
  }
}
