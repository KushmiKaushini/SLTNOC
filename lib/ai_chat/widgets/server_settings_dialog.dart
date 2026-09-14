import 'package:flutter/material.dart';
import 'package:sltnoc/secure_storage_service.dart';
import '../constants/chat_constants.dart';

class ServerSettingsDialog {
  static void show({
    required BuildContext context,
    required String currentUrl,
    required void Function(String newUrl) onUrlSaved,
  }) {
    final controller = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kChatSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi, color: kChatAccent2),
            SizedBox(width: 8),
            Text('Server Connection', style: TextStyle(color: kChatText)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kChatGlass,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kChatBorder),
              ),
              child: const Text(
                '📱 On physical phones, use your laptop/server IP:\nhttp://192.168.x.x:3000\n\n💻 Find IP: ipconfig or ifconfig',
                style: TextStyle(fontSize: 12, color: kChatTextSec, height: 1.5),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: const TextStyle(color: kChatText),
              decoration: InputDecoration(
                labelText: 'Server URL',
                labelStyle: const TextStyle(color: kChatTextSec),
                hintText: 'http://192.168.1.x:3000',
                hintStyle: const TextStyle(color: kChatTextTer),
                prefixIcon: const Icon(Icons.link, color: kChatAccent2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kChatBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kChatAccent1, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kChatTextSec)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save & Connect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kChatAccent1,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                try {
                  final Uri uri = Uri.parse(newUrl);
                  final String cleanUrl = uri.replace(userInfo: null).toString();
                  final bool hadCredentials = uri.userInfo.isNotEmpty;

                  final storage = SecureStorageService();
                  await storage.setServerUrl(cleanUrl);
                  onUrlSaved(cleanUrl);
                  Navigator.pop(ctx);

                  if (context.mounted) {
                    final String message = hadCredentials
                        ? 'Credentials removed for security. Only base URL stored.'
                        : 'Connected to $cleanUrl';
                    final Color color = hadCredentials ? kChatAccent1 : kChatGreen;

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                      backgroundColor: color,
                      duration: const Duration(seconds: 2),
                    ));
                  }
                } on FormatException catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Invalid URL format'),
                      backgroundColor: kChatError,
                      duration: const Duration(seconds: 2),
                    ));
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
