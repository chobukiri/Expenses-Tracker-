import 'package:flutter/material.dart';
import 'package:assignment_2/screens/change_email_page.dart';
import 'package:assignment_2/screens/change_password_page.dart';

class SettingsPage extends StatelessWidget {
  final int userId; 

  const SettingsPage({super.key, required this.userId}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.email, color: Colors.lightBlue),
            title: const Text("Change Gmail"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeEmailPage(userId: userId),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.lock, color: Colors.lightBlue),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordPage(userId: userId),
                ),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
