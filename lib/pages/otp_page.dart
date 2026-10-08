import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  TextEditingController otpController = TextEditingController();

  String otp = '';

  @override
  void initState() {
    super.initState();
    buatOtp();
  }

  void buatOtp() {
    Random random = Random();
    otp = (100000 + random.nextInt(900000)).toString();

    print('OTP: $otp');
  }

  void kirimUlang() {
    setState(() {
      buatOtp();
      otpController.clear();
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('OTP baru telah dikirim')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
        backgroundColor: const Color.fromARGB(255, 14, 19, 15),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.lock_outline,
              size: 70,
              color: Color.fromARGB(255, 34, 43, 34),
            ),

            const SizedBox(height: 20),

            const Text(
              'Verifikasi akun',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Masukkan kode OTP',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Kode OTP',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (otpController.text == otp) {
                    context.go('/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kode OTP salah')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Verifikasi'),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: kirimUlang,
              child: const Text('Kirim ulang kode'),
            ),
          ],
        ),
      ),
    );
  }
}
