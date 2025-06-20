import 'package:flutter/material.dart';
import 'package:loyalty_program_application/src/pages/main_page.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int targetIndex; // The index of the bottom nav to switch to

  const QuickActionCard({
    required this.icon,
    required this.title,
    required this.targetIndex, // Accept the indesx to switch to
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Trigger onItemTapped on MainPage using GlobalKey
        print(mainPageKey);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(254, 236, 231, 1.0),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Color(0xFFF05024), size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
