import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F7FA), // Light grayish background
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3.0),
          child: Column(
            children: [
              _buildDrawerItem(
                icon: Icons.lightbulb_outline,
                title: 'Notes',
                onTap: () {
                  // Handle notes tap
                },
              ),
              const SizedBox(height: 8), // Reduced height
              _buildDrawerItem(
                icon: Icons.notifications_none,
                title: 'Reminders',
                onTap: () {
                  // Handle reminders tap
                },
              ),
              const SizedBox(height: 8), // Reduced height
              _buildDrawerItem(
                icon: Icons.archive_outlined,
                title: 'Archive',
                onTap: () {
                  // Handle archive tap
                },
              ),
              const SizedBox(height: 8), // Reduced height
              _buildDrawerItem(
                icon: Icons.delete_outline,
                title: 'Trash',
                onTap: () {
                  // Handle trash tap
                },
              ),
              const SizedBox(height: 8), // Reduced height
              _buildDrawerItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  // Handle settings tap
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.black,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
