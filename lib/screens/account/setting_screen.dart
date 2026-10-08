import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingScreen> {
  bool notifikasi = true;
  bool modeGelap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifikasi'),
            subtitle: const Text('Terima notifikasi aplikasi'),
            value: notifikasi,
            onChanged: (value) {
              setState(() {
                notifikasi = value;
              });
            },
          ),

          const Divider(),

          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Menggunakan tampilan gelap'),
            value: modeGelap,
            onChanged: (value) {
              setState(() {
                modeGelap = value;
              });
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Tokopedia Clone'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Tokopedia Clone',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Aplikasi tugas Flutter',
              );
            },
          ),
        ],
      ),
    );
  }
}