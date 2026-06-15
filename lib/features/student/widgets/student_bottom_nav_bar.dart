import 'package:flutter/material.dart';

class StudentBottomNavBar extends StatelessWidget {
  const StudentBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

        BottomNavigationBarItem(
          icon: Transform.translate(
            offset: const Offset(0, -6),
            child: Image.asset(
              "assets/images/mbman_app_icon.png",
              width: 24,
              height: 24,
            ),
          ),
          label: "Courses",
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Results",
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
