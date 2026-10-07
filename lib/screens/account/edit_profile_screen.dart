import 'package:flutter/material.dart';

import '../../services/auth_store.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController namaController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    final user = AuthStore.instance.user;

    namaController = TextEditingController(
      text: user?.name ?? '',
    );

    phoneController = TextEditingController(
      text: user?.phone ?? '',
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> simpan() async {
    await AuthStore.instance.updateProfile(
      name: namaController.text,
      phone: phoneController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthStore.instance.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: TextEditingController(
                text: user?.email ?? '',
              ),
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor HP',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}