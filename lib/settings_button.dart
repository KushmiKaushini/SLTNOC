// settings_icon_button.dart

import 'package:flutter/material.dart';
import 'package:sltnoc/settings_page.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6.0), // Adjust the right margin as needed
      child: IconButton(
        icon: const Icon(Icons.settings, color: Colors.white, size: 30),
        onPressed: () {
          // Navigate to the SettingsPage when the settings icon is tapped
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
        },
      ),
    );
  }
}

