import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/constants/utils.dart';
import 'package:instagram/features/edit%20profile/services/editprofile.dart';
import 'package:instagram/features/edit%20profile/services/storageupload.dart';
import 'package:instagram/providers/userprovider.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final ProfileEdit editp = ProfileEdit();

  Uint8List? _imageFile;
  var user; // Declare the user model variable

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.getuser;
      if (currentUser != null) {
        setState(() {
          user = currentUser;
          usernameController.text = currentUser.userName;
          bioController.text = currentUser.bio;
        });
      }
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    bioController.dispose();
    _imageFile = null;
    super.dispose();
  }

  void selectGalleryImage() async {
    Uint8List imageFile = await getImage(ImageSource.gallery);
    setState(() {
      _imageFile = imageFile;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void selectCameraImage() async {
    Uint8List imageFile = await getImage(ImageSource.camera);
    setState(() {
      _imageFile = imageFile;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Login to continue")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: _showBottomSheet,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _imageFile == null
                              ? CachedNetworkImage(
                                  width: 250,
                                  height: 250,
                                  imageUrl: user.photoUrl,
                                  fit: BoxFit.cover,
                                )
                              : Image.memory(
                                  _imageFile!,
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: -10,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade400,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            iconSize: 30,
                            color: Colors.black,
                            onPressed: _showBottomSheet,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  profileCustomTextField(
                    'Username',
                    'eg. elijah',
                    Icons.person,
                    controller: usernameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  profileCustomTextField(
                    'Bio',
                    'Tell us about yourself...',
                    Icons.info_sharp,
                    isBio: true,
                    controller: bioController,
                    validator: (value) {
                      // No validation — bio can be empty
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      minimumSize: Size(
                        MediaQuery.of(context).size.width * 0.5,
                        MediaQuery.of(context).size.height * 0.05,
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        final updatedUsername = usernameController.text.trim();
                        final updatedBio = bioController.text.trim();
                        String photoUrl = user.photoUrl;

                        if (_imageFile != null) {
                          try {
                            final newPhotoUrl =
                                await ProfileImageUpdateStorageMethod()
                                    .updateProfileImage(_imageFile!);
                            photoUrl =
                                '$newPhotoUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}';
                          } catch (e) {
                            log(e.toString());
                          }
                        }

                        editp
                            .updateProfile(
                          updatedUsername,
                          updatedBio,
                          user.uid,
                          photoUrl,
                        )
                            .then((value) {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                              _imageFile = null;
                              Provider.of<UserProvider>(context, listen: false)
                                  .refreshUser();
                            });
                            Navigator.of(context).pop();
                            customSnackBar(context, 'Profile Updated');
                          }
                        }).catchError((e) {
                          if (mounted) {
                            customSnackBar(
                                context, 'Update failed: ${e.toString()}');
                            setState(() {
                              isLoading = false;
                            });
                          }
                        });
                      }
                    },
                    label: isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            'Update',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget profileCustomTextField(
    String labelText,
    String hintText,
    IconData icon, {
    bool isBio = false,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: controller,
        maxLines: isBio ? 5 : 1,
        validator: validator, // use the passed validator
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
          hintText: hintText,
          labelText: labelText,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Pick Profile Picture",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: 'assets/gallery.png',
                    label: 'choose from gallery',
                    onTap: () => selectGalleryImage(),
                  ),
                  _buildImageOption(
                    icon: 'assets/camera.png',
                    label: 'choose from camera',
                    onTap: () => selectCameraImage(),
                  )
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            child: Image.asset(icon),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
