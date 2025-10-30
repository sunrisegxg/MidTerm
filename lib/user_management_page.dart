import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:midterm/login_page.dart';

import 'add_user_page.dart';
import 'edit_user_page..dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> allUsers = [];
  List<QueryDocumentSnapshot> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    // Lắng nghe Firestore
    FirebaseFirestore.instance.collection('users').snapshots().listen((
      snapshot,
    ) {
      allUsers = snapshot.docs;
      filteredUsers = allUsers;
      if (mounted) setState(() {});
    });
  }

  void filterUsers(String input) {
    setState(() {
      filteredUsers =
          allUsers.where((user) {
            final username = user['username'].toString().toLowerCase();
            final email = user['email'].toString().toLowerCase();
            final query = input.toLowerCase();
            return username.contains(query) || email.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Builder(
          builder: (context) {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return const Center(child: Text('No admin logged in'));
            }
            return StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('admin')
                      .doc(user.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Admin not found'));
                }
                final adminData = snapshot.data!;
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 16.0, top: 50.0),
                      color: Colors.green.shade300,
                      height: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: adminData['image'],
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            adminData['username'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            adminData['email'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        height: 50,
                        width: 20,
                        margin: EdgeInsets.only(left: 16.0, right: 140.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Text(
                            "Log out",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'User management page',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        leadingWidth: 50,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: filterUsers,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                //default
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.green.shade100,
                    width: 1,
                  ),
                ),
                //border focus
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.green.shade100,
                hintStyle: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w400,
                ),
                hintText: 'Search by username or email',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child:
                filteredUsers.isEmpty
                    ? Center(child: Text("No users found"))
                    : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('Confirm Deletion'),
                                          content: Text(
                                            'Are you sure you want to delete this user?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                // Xóa user khỏi Firestore
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(user.id)
                                                    .delete();

                                                // Xóa user khỏi allUsers
                                                allUsers.removeWhere(
                                                  (u) => u.id == user.id,
                                                );

                                                // Cập nhật lại filteredUsers theo search hiện tại
                                                filterUsers(
                                                  searchController.text,
                                                );

                                                Navigator.of(context).pop();

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'User deleted successfully',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditUserPage(
                                        username: user['username'],
                                        password: user['password'],
                                        email: user['email'],
                                        image: user['image'],
                                      ),
                                ),
                              );
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: user['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(user['username']),
                            subtitle: Text(user['email']),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade300,
        onPressed:
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => AddUserPage())),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
