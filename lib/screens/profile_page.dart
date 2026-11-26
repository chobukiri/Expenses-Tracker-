import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assignment_2/screens/edit_profile_page.dart';
import 'package:assignment_2/screens/settings_page.dart';
import 'package:assignment_2/screens/about_info_page.dart';
import 'package:assignment_2/routes/app_routes.dart';
import 'package:assignment_2/services/database_helper.dart'; 
import 'package:assignment_2/user_model.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "Loading...";
  String email = "";
  int? currentUserId; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('currentUserId');

    if (userId != null) {
      User? user = await DatabaseHelper.instance.getUser(userId);

      if (mounted) {
        setState(() {
          currentUserId = userId;
          if (user != null) {
            username = user.name;
            email = user.email;
          }
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId'); 

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(email, style: const TextStyle(color: Colors.grey)),

                    const SizedBox(height: 25),

                    Expanded(
                      child: ListView(
                        children: [
                          _buildProfileOption(
                            Icons.person,
                            "Edit Profile",
                            onTap: () async {
                              if (currentUserId == null) return;

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(userId: currentUserId!),
                                ),
                              );
                              if (result == true) {
                                _loadUserData();
                              }
                            },
                          ),

                          _buildProfileOption(
                            Icons.settings,
                            "Settings",
                            onTap: () async {
                              if (currentUserId == null) return;

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SettingsPage(userId: currentUserId!),
                                ),
                              );
                              if (result == true) {
                                _loadUserData();
                              }
                            },
                          ),

                          _buildProfileOption(
                            Icons.info,
                            "About & Info",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutInfoPage(),
                                ),
                              );
                            },
                          ),

                          _buildProfileOption(
                            Icons.logout,
                            "Logout",
                            onTap: _handleLogout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
