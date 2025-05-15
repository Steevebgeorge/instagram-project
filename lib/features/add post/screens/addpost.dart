import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/constants/utils.dart';
import 'package:instagram/features/add post/services/addpost.dart';
import 'package:instagram/features/authentication/models/usermodel.dart';
import 'package:instagram/providers/userprovider.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController postCaptionController = TextEditingController();
  final TextEditingController postLocationController =
      TextEditingController(); // ✅ New controller

  Uint8List? image;
  bool isLoading = false;

  @override
  void dispose() {
    postCaptionController.dispose();
    postLocationController.dispose(); // ✅ Dispose location controller
    super.dispose();
  }

  void clearImage() {
    setState(() {
      image = null;
      postCaptionController.clear();
      postLocationController.clear();
    });
  }

  void postImage(String uid, String userName, String profileImage) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await PostStoreMethods().uploadPost(
        image!,
        postCaptionController.text,
        uid,
        userName,
        profileImage,
        postLocationController.text,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          customSnackBar(context, 'Post uploaded successfully');
          clearImage();
        }
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          customSnackBar(context, res.toString());
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        customSnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserProvider>(context).getuser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Post",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: InkWell(
                onTap: () {
                  if (image == null) {
                    customSnackBar(context, 'Select an Image');
                    return;
                  }
                  postImage(user.uid, user.userName, user.photoUrl);
                },
                child: Container(
                  height: 40,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            height: 15,
                            width: 15,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            "Post",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Preview Container
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: image == null
                    ? const Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Choose Image From",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 20),

              // Image Picker Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Uint8List file = await getImage(ImageSource.gallery);
                        setState(() {
                          image = file;
                        });
                      },
                      icon: Icon(
                        Icons.photo_library,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      label: const Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                        foregroundColor:
                            isDarkMode ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Uint8List file = await getImage(ImageSource.camera);
                        setState(() {
                          image = file;
                        });
                      },
                      icon: Icon(
                        Icons.camera_alt,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      label: const Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                        foregroundColor:
                            isDarkMode ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Caption TextField
              TextField(
                controller: postCaptionController,
                decoration: InputDecoration(
                  hintText: "Write your caption here...",
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                maxLines: 10,
                minLines: 6,
              ),

              const SizedBox(height: 20),

              // ✅ Location TextField
              TextField(
                controller: postLocationController,
                decoration: InputDecoration(
                  hintText: "Add location...",
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
