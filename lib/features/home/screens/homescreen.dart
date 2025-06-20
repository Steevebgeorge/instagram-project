import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/features/feed/screens/feedscreen.dart';
import 'package:instagram/features/home/services/activites.dart';
import 'package:instagram/features/notification/screens/notification.dart';
import 'package:instagram/features/profile/screens/profile.dart';
import 'package:instagram/features/search/screens/searchscreen.dart';
import 'package:instagram/providers/userprovider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _userId;
  bool _isLoading = true;

  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    AppActivities().updateOnlineStatus(true);
    SystemChannels.lifecycle.setMessageHandler(
      (message) {
        log(message.toString());
        if (FirebaseAuth.instance.currentUser != null) {
          if (message.toString().contains('pause')) {
            AppActivities().updateOnlineStatus(false);
          }
          if (message.toString().contains('resume')) {
            AppActivities().updateOnlineStatus(true);
          }
        }
        return Future.value(message);
      },
    );
    _initialize();
  }

  void _initialize() async {
    await addData();
    await getuserData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void navigationTap(int page) {
    _pageController.jumpToPage(page);
  }

  // Handle Page View change
  void onPageChanged(int page) {
    setState(() {
      _selectedIndex = page;
    });
  }

  // Refresh user data
  Future<void> addData() async {
    try {
      UserProvider userprovider =
          Provider.of<UserProvider>(context, listen: false);
      await userprovider.refreshUser();
      log('Provider in HomeScreen called');
    } catch (e) {
      log('Error refreshing user data: ${e.toString()}');
    }
  }

  // Fetch current user data
  Future<void> getuserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        setState(() {
          _userId = currentUser.uid;
        });
      }
    } catch (e) {
      log('Error fetching user data: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          const FeedScreen(),
          const SearchScreen(),
          const NotificationScreen(),
          _userId != null
              ? ProfileScreen(
                  uid: _userId!) // Display ProfileScreen if userId is available
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: navigationTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
