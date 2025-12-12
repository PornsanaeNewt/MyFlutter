import 'package:flutter_app_test1/config/app_config.dart';
import 'package:logarte/logarte.dart';
import 'package:flutter/material.dart';

final Logarte logarte = Logarte(
  password: '1234',
  customTab: const MyCustomTab(),
  onRocketDoubleTapped: (context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('onRocketDoubleTapped'),
          content: Text(
            'This callback is useful when you want to quickly access some pages or perform actions without leaving the currently page (toggle theme, change language and etc.).',
          ),
        );
      },
    );
  },
  onRocketLongPressed: (context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('onRocketLongPressed'),
          content: Text(
            'This callback is useful when you want to quickly access some pages or perform actions without leaving the currently page (toggle theme, change language and etc.).',
          ),
        );
      },
    );
  },
);

class MyCustomTab extends StatefulWidget {
  const MyCustomTab({super.key});

  @override
  State<MyCustomTab> createState() => _MyCustomTabState();
}

class _MyCustomTabState extends State<MyCustomTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined),
            title: const Text('${AppConfig.env}'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('FCM token'),
            subtitle: const Text(
              'dJkH8Hs9_dKpQm2nLxY:APA91bGj8g_QxL3xJ2K9pQm2nLxYdJkH8Hs9_dKpQm2nLxY',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: TextButton(onPressed: () {}, child: const Text('Copy')),
          ),

          // Cache size and clear button
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Local cache'),
            subtitle: const Text('100 MB'),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Clear All'),
            ),
          ),

          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(
              text: 'https://api.example.com/v3/',
            ),
            decoration: const InputDecoration(
              labelText: 'API URL',
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}
