import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  void doLogin() async {
    setState(() => loading = true);
    final ok = await ApiService.login(userCtrl.text, passCtrl.text);
    setState(() => loading = false);
    if (ok) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: "Username")),
          TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: loading ? null : doLogin, child: const Text("Login")),
        ]),
      ),
    );
  }
}
