// // // import 'dart:async';
// // // import 'package:flutter/material.dart';
// // // import '../services/api_service.dart';
// // // import '../services/notification_service.dart';
// // // import 'camera_list_page.dart';

// // // class HomePage extends StatefulWidget {
// // //   const HomePage({super.key});
// // //   @override
// // //   State<HomePage> createState() => _HomePageState();
// // // }

// // // class _HomePageState extends State<HomePage> {
// // //   int children = 0, adults = 0;
// // //   Timer? timer;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     fetch();
// // //     timer = Timer.periodic(const Duration(minutes: 30), (_) => fetch());
// // //   }

// // //   void fetch() async {
// // //     final data = await ApiService.getCurrent();
// // //     setState(() {
// // //       children = data['children'];
// // //       adults = data['adults'];
// // //     });
// // //     if (children > 0) {
// // //       NotificationService.show("⚠️ Cảnh báo", "Có $children trẻ trên xe!");
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     timer?.cancel();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text("Dashboard")),
// // //       body: Column(children: [
// // //         ListTile(title: const Text("Trẻ em"), trailing: Text("$children")),
// // //         ListTile(title: const Text("Người lớn"), trailing: Text("$adults")),
// // //         ElevatedButton(
// // //           onPressed: () => Navigator.push(context,
// // //               MaterialPageRoute(builder: (_) => const CameraListPage())),
// // //           child: const Text("Xem Camera"),
// // //         )
// // //       ]),
// // //     );
// // //   }
// // // }
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import '../services/api_service.dart';
// // import '../services/notification_service.dart';
// // import 'camera_list_page.dart';
// // import 'login_page.dart';

// // class HomePage extends StatefulWidget {
// //   const HomePage({super.key});

// //   @override
// //   State<HomePage> createState() => _HomePageState();
// // }

// // class _HomePageState extends State<HomePage> {
// //   String username = "";
// //   String userId = "";
// //   int numCams = 0;

// //   bool loading = false;
// //   Timer? timer;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetch();
// //     timer = Timer.periodic(const Duration(minutes: 30), (_) => fetch());
// //   }

// //   Future<void> fetch() async {
// //     try {
// //       final data = await ApiService.getCurrent();
// //       setState(() {
// //         username = data['username'] ?? "";
// //         userId = data['user_id'] ?? "";
// //         numCams = data['num_cams'] ?? 0;
// //       });
// //     } catch (e) {
// //       // token expired / network error → logout
// //       await ApiService.logout();
// //       if (!mounted) return;
// //       Navigator.pushAndRemoveUntil(
// //         context,
// //         MaterialPageRoute(builder: (_) => const LoginPage()),
// //         (_) => false,
// //       );
// //     }
// //   }

// //   void showUpdateCameraDialog() {
// //     final ctrl = TextEditingController(text: numCams.toString());

// //     showDialog(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         title: const Text("Update number of cameras"),
// //         content: TextField(
// //           controller: ctrl,
// //           keyboardType: TextInputType.number,
// //           decoration: const InputDecoration(labelText: "Number of cameras"),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text("Cancel"),
// //           ),
// //           ElevatedButton(
// //             onPressed: () async {
// //               final newVal = int.tryParse(ctrl.text);
// //               if (newVal == null || newVal < 1) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(content: Text("Invalid number")),
// //                 );
// //                 return;
// //               }

// //               Navigator.pop(context);
// //               setState(() => loading = true);

// //               try {
// //                 final updated = await ApiService.updateNumCam(newVal);
// //                 setState(() => numCams = updated);

// //                 NotificationService.show(
// //                   "Camera updated",
// //                   "You now have $updated cameras",
// //                 );
// //               } catch (e) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(content: Text("Failed to update cameras")),
// //                 );
// //               } finally {
// //                 setState(() => loading = false);
// //               }
// //             },
// //             child: const Text("Save"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void logout() async {
// //     await ApiService.logout();
// //     if (!mounted) return;
// //     Navigator.pushAndRemoveUntil(
// //       context,
// //       MaterialPageRoute(builder: (_) => const LoginPage()),
// //       (_) => false,
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     timer?.cancel();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Dashboard"),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             onPressed: logout,
// //           ),
// //         ],
// //       ),
// //       body: loading
// //           ? const Center(child: CircularProgressIndicator())
// //           : Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   ListTile(
// //                     title: const Text("Username"),
// //                     trailing: Text(username),
// //                   ),
// //                   ListTile(
// //                     title: const Text("User ID"),
// //                     subtitle: Text(
// //                       userId,
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),
// //                   ListTile(
// //                     title: const Text("Number of cameras"),
// //                     trailing: Text("$numCams"),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton.icon(
// //                       icon: const Icon(Icons.settings),
// //                       label: const Text("Update number of cameras"),
// //                       onPressed: showUpdateCameraDialog,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton.icon(
// //                       icon: const Icon(Icons.videocam),
// //                       label: const Text("View cameras"),
// //                       onPressed: () => Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (_) => const CameraListPage(),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../services/notification_service.dart';
// import 'camera_list_page.dart';
// import 'login_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String username = "";
//   String userId = "";
//   int numCams = 0;
//   bool loading = false;
//   bool isFetching = false;
//   Timer? timer;

//   @override
//   void initState() {
//     super.initState();
//     fetch();
//     timer = Timer.periodic(const Duration(minutes: 30), (_) => fetch());
//   }

//   Future<void> fetch() async {
//     if (isFetching) return;
//     isFetching = true;
//     setState(() => loading = true);

//     try {
//       final data = await ApiService.getCurrent();
//       if (!mounted) return;
//       setState(() {
//         username = data['username'] ?? "";
//         userId = data['user_id'] ?? "";
//         // prefer cameras length if available
//         final cams = data['cameras'];
//         if (cams is List) {
//           numCams = cams.length;
//         } else {
//           numCams = data['num_cams'] ?? 0;
//         }
//       });
//     } catch (e) {
//       // token expired / network error → logout
//       await ApiService.logout();
//       if (!mounted) return;
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//         (_) => false,
//       );
//     } finally {
//       if (!mounted) return;
//       setState(() => loading = false);
//       isFetching = false;
//     }
//   }

//   void showUpdateCameraDialog() {
//     final ctrl = TextEditingController(text: numCams.toString());

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Update number of cameras"),
//         content: TextField(
//           controller: ctrl,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(labelText: "Number of cameras"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               ctrl.dispose();
//               Navigator.pop(context);
//             },
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final newVal = int.tryParse(ctrl.text);
//               if (newVal == null || newVal < 1) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Invalid number")),
//                 );
//                 return;
//               }

//               Navigator.pop(context);
//               ctrl.dispose();
//               setState(() => loading = true);

//               try {
//                 final updated = await ApiService.updateNumCam(newVal);
//                 setState(() => numCams = updated);

//                 NotificationService.show(
//                   "Camera updated",
//                   "You now have $updated cameras",
//                 );
//               } catch (e) {
//                 if (!mounted) return;
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Failed to update cameras")),
//                 );
//               } finally {
//                 if (!mounted) return;
//                 setState(() => loading = false);
//               }
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }

//   void showAddCameraDialog() {
//     final nameCtrl = TextEditingController();
//     final urlCtrl = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Add Camera"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameCtrl,
//               decoration: const InputDecoration(labelText: "Camera name"),
//             ),
//             TextField(
//               controller: urlCtrl,
//               decoration: const InputDecoration(labelText: "HLS URL (index.m3u8)"),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               nameCtrl.dispose();
//               urlCtrl.dispose();
//               Navigator.pop(context);
//             },
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final name = nameCtrl.text.trim();
//               final url = urlCtrl.text.trim();

//               if (name.isEmpty || url.isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Name and URL are required")),
//                 );
//                 return;
//               }

//               if (!(url.startsWith("http://") || url.startsWith("https://")) ||
//                   !url.contains(".m3u8")) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("URL must be an HLS .m3u8 http(s) URL")),
//                 );
//                 return;
//               }

//               // close dialog first
//               Navigator.pop(context);

//               // dispose controllers
//               nameCtrl.dispose();
//               urlCtrl.dispose();

//               setState(() => loading = true);
//               try {
//                 // NOTE: ApiService.createCamera should be implemented in ApiService
//                 final cam = await ApiService.createCamera(name: name, url: url);
//                 // cam can be Map or bool depending on your ApiService implementation
//                 if (cam != null) {
//                   // refresh user info
//                   await fetch();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Camera added")),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Failed to add camera")),
//                   );
//                 }
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Error adding camera: $e")),
//                 );
//               } finally {
//                 if (!mounted) return;
//                 setState(() => loading = false);
//               }
//             },
//             child: const Text("Add"),
//           ),
//         ],
//       ),
//     );
//   }

//   void logout() async {
//     await ApiService.logout();
//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (_) => false,
//     );
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Dashboard"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: logout,
//             tooltip: "Logout",
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ListTile(
//                     title: const Text("Username"),
//                     trailing: Text(username),
//                   ),
//                   ListTile(
//                     title: const Text("User ID"),
//                     subtitle: Text(
//                       userId,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   ListTile(
//                     title: const Text("Number of cameras"),
//                     trailing: Text("$numCams"),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.add),
//                       label: const Text("Add camera"),
//                       onPressed: showAddCameraDialog,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.settings),
//                       label: const Text("Update number of cameras"),
//                       onPressed: showUpdateCameraDialog,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.videocam),
//                       label: const Text("View cameras"),
//                       onPressed: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const CameraListPage(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
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

  @override
  void initState() {
    super.initState();
    fetch();
    timer = Timer.periodic(const Duration(minutes: 30), (_) => fetch());
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
                labelText: "HLS URL (index.m3u8)",
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

              // if (!(url.startsWith("http://") || url.startsWith("https://")) ||
              //     !url.contains(".m3u8")) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text("URL must be an HLS .m3u8 http(s) URL"),
              //     ),
              //   );
              //   return;
              // }

              // capture values before popping
              // unfocus first
              FocusScope.of(dialogContext).unfocus();

              // close dialog
              Navigator.of(dialogContext).pop();

              // dispose after frame
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   nameCtrl.dispose();
              //   urlCtrl.dispose();
              // });

              // now do the async work (API call) with captured values
              setState(() => loading = true);
              try {
                final cam = await ApiService.createCamera(name: name, url: url);
                if (cam != null) {
                  await fetch(); // refresh list
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Camera added")));
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to add camera")),
                  );
                }
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

  // @override
  // void dispose() {
  //   timer?.cancel();
  //   super.dispose();
  // }
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
