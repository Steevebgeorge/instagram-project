import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/services/get_user_details.dart';

class UserProvider with ChangeNotifier {
  final GetUserDetails _getuserdetails = GetUserDetails();
  UserModel? _user;

  UserModel? get getuser => _user;

  Future<void> refreshUser() async {
    try {
      UserModel userModel = await _getuserdetails.getUserDetails();
      _user = userModel;
      notifyListeners();
      log('user provider called');
    } catch (e) {
      print(e);
    }
  }
}
