import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nama =
        GoRouterState.of(context).uri.queryParameters['nama'] ??
        'Nama Pengguna';

    final email =
        GoRouterState.of(context).uri.queryParameters['email'] ??
        'user@email.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: const Color.fromARGB(255, 32, 48, 33),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),

          const CircleAvatar(
            radius: 50,
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            nama,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            email,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 30),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profil'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Alamat'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Pengaturan'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () {
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}