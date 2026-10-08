import 'package:flutter/material.dart';

import '../../services/auth_store.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();

    addressController = TextEditingController(
      text: AuthStore.instance.user?.address ?? '',
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  Future<void> simpanAlamat() async {
    await AuthStore.instance.updateProfile(
      address: addressController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat berhasil disimpan'),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: addressController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap',
                hintText: 'Masukkan alamat kamu',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: simpanAlamat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan Alamat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}