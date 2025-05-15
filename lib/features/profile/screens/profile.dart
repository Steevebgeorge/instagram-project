import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/constants/utils.dart';
import 'package:instagram/features/profile/services/follow.dart';
import 'package:instagram/features/profile/widgets/buttons.dart';

// ElevatedButton(
//               onPressed: () {
//                 FirebaseAuth.instance.signOut();
//               },
//               child: Text("logout"))

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  var userdata = {};
  int postLength = 0;
  int followersCount = 0;
  int followingcount = 0;
  bool isFollowing = false;
  bool isLoading = false;
  late final TabController _tabcontroller;

  @override
  void initState() {
    super.initState();
    getData();
    _tabcontroller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabcontroller.dispose();
    super.dispose();
  }

  void getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('nposts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      if (userSnap.exists) {
        userdata = userSnap.data()!;
        postLength = postSnap.docs.length;
        log(postLength.toString());
        followersCount = userdata['followers']?.length ?? 0;
        followingcount = userdata['following']?.length ?? 0;
        isFollowing = userdata['followers']
                ?.contains(FirebaseAuth.instance.currentUser!.uid) ??
            false;
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        customSnackBar(context, e.toString());
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(userdata['userName'] ?? 'loading...'),
        actions: [
          Icon(Icons.menu),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final imageUrl = userdata['photoUrl'];
                              _showEnlargedImage(imageUrl);
                            },
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.grey,
                              backgroundImage: userdata['photoUrl'] != null &&
                                      userdata['photoUrl'].toString().isNotEmpty
                                  ? NetworkImage(userdata['photoUrl'])
                                  : null,
                              child: userdata['photoUrl'] == null ||
                                      userdata['photoUrl'].toString().isEmpty
                                  ? const Icon(Icons.person, size: 45)
                                  : null,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  spacing: 30,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    buildStatColumn(postLength, 'posts'),
                                    buildStatColumn(
                                        followersCount, 'followers'),
                                    buildStatColumn(
                                        followingcount, 'following'),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userdata['userName'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: userdata['bio'] == ""
                            ? const SizedBox.shrink()
                            : Text(
                                userdata['bio'],
                                style: const TextStyle(),
                              ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FirebaseAuth.instance.currentUser!.uid == widget.uid
                        ? ProfileButtons(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            borderColor: Colors.grey,
                            text: 'Edit Profile',
                            textColor: Theme.of(context).primaryColor,
                          )
                        : isFollowing
                            ? ProfileButtons(
                                backgroundColor: Colors.white,
                                borderColor: Colors.grey,
                                text: 'Unfollow',
                                textColor:
                                    Theme.of(context).colorScheme.secondary,
                                function: () async {
                                  ProfileActions().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userdata['uid']);
                                  setState(() {
                                    isFollowing = false;
                                    followersCount--;
                                  });
                                },
                              )
                            : ProfileButtons(
                                backgroundColor: Colors.blue,
                                borderColor: Colors.grey,
                                text: 'Follow',
                                textColor: Theme.of(context).primaryColor,
                                function: () async {
                                  ProfileActions().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userdata['uid']);
                                  setState(() {
                                    isFollowing = true;
                                    followersCount++;
                                  });
                                },
                              ),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: const Text("logout"),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                TabBar(
                  controller: _tabcontroller,
                  tabs: const [
                    Tab(
                      icon: Icon(
                        Icons.grid_on_outlined,
                        size: 30,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.perm_contact_cal_rounded,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    controller: _tabcontroller,
                    children: [
                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('nposts')
                            .where('uid', isEqualTo: widget.uid)
                            .get(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('No posts found'),
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            itemCount: snapshot.data!.docs.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 5,
                                    childAspectRatio: 1),
                            itemBuilder: (context, index) {
                              final post = snapshot.data!.docs[index];
                              return Image.network(
                                post['postUrl'],
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const Center(
                        child: Text('No Tagged Photos'),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 22),
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showEnlargedImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(200),
          ),
        ),
      ),
    );
  }
}
