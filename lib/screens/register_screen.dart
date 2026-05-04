import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget { const RegisterScreen({super.key}); @override State<RegisterScreen> createState() => _RegisterScreenState(); }
class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(); final email = TextEditingController(); final password = TextEditingController();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daftar Akun')),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
      const Text('Buat akun mahasiswa', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
      Form(key: formKey, child: Column(children: [
        TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v != null && v.length > 2 ? null : 'Nama wajib diisi'),
        const SizedBox(height: 14),
        TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), validator: (v) => v != null && v.contains('@') ? null : 'Email tidak valid'),
        const SizedBox(height: 14),
        TextFormField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)), validator: (v) => v != null && v.length >= 6 ? null : 'Password minimal 6 karakter'),
        const SizedBox(height: 22),
        ElevatedButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen())); }, child: const Text('Daftar dan Masuk')),
      ])),
    ])),
  );
}
