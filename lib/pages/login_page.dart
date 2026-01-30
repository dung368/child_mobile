// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import 'home_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final userCtrl = TextEditingController();
//   final passCtrl = TextEditingController();
//   bool loading = false;

//   void doLogin() async {
//     setState(() => loading = true);
//     final ok = await ApiService.login(userCtrl.text, passCtrl.text);
//     setState(() => loading = false);
//     if (ok) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => const HomePage()));
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Login failed")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Đăng nhập")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(children: [
//           TextField(
//               controller: userCtrl,
//               decoration: const InputDecoration(labelText: "Username")),
//           TextField(
//               controller: passCtrl,
//               decoration: const InputDecoration(labelText: "Password"),
//               obscureText: true),
//           const SizedBox(height: 16),
//           ElevatedButton(
//               onPressed: loading ? null : doLogin, child: const Text("Login")),
//         ]),
//       ),
//     );
//   }
// }
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

  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  /// If token already exists, go straight to HomePage
  void _autoLogin() async {
  await ApiService.loadToken();
  if (ApiService.token.isEmpty || !mounted) return;

  try {
    await ApiService.getCurrent(); // 🔑 validate token
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } catch (e) {
    // Token invalid or server unreachable
    await ApiService.logout();
  }
}

  void doLogin() async {
    setState(() => loading = true);
    final ok = await ApiService.login(
      userCtrl.text.trim(),
      passCtrl.text,
    );
    setState(() => loading = false);

    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Login failed")),
      );
    }
  }

  void showSignupDialog() {
    final signupUserCtrl = TextEditingController();
    final signupPassCtrl = TextEditingController();
    final camCtrl = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sign up"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: signupUserCtrl,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: signupPassCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: camCtrl,
              decoration: const InputDecoration(labelText: "Number of cameras"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok = await ApiService.signup(
                username: signupUserCtrl.text.trim(),
                password: signupPassCtrl.text,
                numCams: int.tryParse(camCtrl.text) ?? 1,
              );

              if (!mounted) return;

              if (ok) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("❌ Signup failed")),
                );
              }
            },
            child: const Text("Create account"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : doLogin,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: loading ? null : showSignupDialog,
              child: const Text("Create new account"),
            ),
          ],
        ),
      ),
    );
  }
}
