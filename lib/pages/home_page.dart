import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'camera_list_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";
  String userId = "";
  int numCams = 0;
  bool loading = false;
  bool isFetching = false;
  Timer? timer;
  int _driverTimeoutSec = 1800;
  bool _savingTimeout = false;

  @override
  void initState() {
    super.initState();
    fetch();
    timer = Timer.periodic(const Duration(minutes: 30), (_) => fetch());
    _loadDriverTimeout();
  }
  Future<void> _loadDriverTimeout() async{
    final val = await ApiService.getDriverTimeout();
    if (!mounted) return;
    setState(() => _driverTimeoutSec = val);
  }

  Future<void> fetch() async {
    if (isFetching) return;
    isFetching = true;
    setState(() => loading = true);

    try {
      final data = await ApiService.getCurrent();
      if (!mounted) return;
      setState(() {
        username = data['username'] ?? "";
        userId = data['user_id'] ?? "";
        final cams = data['cameras'];
        if (cams is List) {
          numCams = cams.length;
        } else {
          numCams = data['num_cams'] ?? 0;
        }
      });
    } catch (e) {
      await ApiService.logout();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      });
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
      isFetching = false;
    }
  }

  Future<void> _showEditDriverTimeoutDialog() async {
    final ctrl = TextEditingController(text: _driverTimeoutSec.toString());
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Driver timeout (seconds)"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Seconds (e.g. 1800 = 30 minutes)",
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Enter a number";
              final n = int.tryParse(v);
              if (n == null || n < 1) return "Enter a positive integer";
              if (n > 60 * 60 * 24) return "Too large";
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ctrl.dispose();
              Navigator.pop(context, null);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              final newVal = int.parse(ctrl.text.trim());
              ctrl.dispose();
              Navigator.pop(context, newVal);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null) {
      await _setDriverTimeout(result);
    }
  }

  Future<void> _setDriverTimeout(int seconds) async {
    setState(() => _savingTimeout = true);
    try {
      // Try server update (if endpoint exists) then persist locally
      await ApiService.setDriverTimeout(seconds);
      if (!mounted) return;
      setState(() => _driverTimeoutSec = seconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Driver timeout set to $seconds seconds")),
      );
    } catch (e) {
      // If server fails, ApiService still saves locally; show a friendly message
      if (!mounted) return;
      setState(() => _driverTimeoutSec = seconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved locally: $seconds seconds (server update failed: $e)")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _savingTimeout = false);
    }
  }

  void showAddCameraDialog() {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add Camera"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Camera name"),
            ),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: "Camera URL",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // unfocus first so TextField releases any focus/dependents
              FocusScope.of(dialogContext).unfocus();

              // pop dialog immediately
              Navigator.of(dialogContext).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final url = urlCtrl.text.trim();

              if (name.isEmpty || url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Name and URL are required")),
                );
                return;
              }
              FocusScope.of(dialogContext).unfocus();

              // close dialog
              Navigator.of(dialogContext).pop();

              // now do the async work (API call) with captured values
              setState(() => loading = true);
              try {
                final cam = await ApiService.createCamera(name: name, url: url);
                await fetch(); // refresh list
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Camera added")));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error adding camera: $e")),
                );
              } finally {
                if (!mounted) return;
                setState(() => loading = false);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text("Username"),
                    trailing: Text(username),
                  ),
                  ListTile(
                    title: const Text("User ID"),
                    subtitle: Text(
                      userId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ListTile(
                    title: const Text("Number of cameras"),
                    trailing: Text("$numCams"),
                  ),
                  const SizedBox(height: 12),
                  // New setting tile: driver timeout
                  ListTile(
                    title: const Text("Driver timeout"),
                    subtitle: Text("Seconds until driver missing check triggers"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_savingTimeout) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text("$_driverTimeoutSec s"),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: "Change driver timeout",
                          onPressed: _showEditDriverTimeoutDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add camera"),
                      onPressed: showAddCameraDialog,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.videocam),
                      label: const Text("View cameras"),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CameraListPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}