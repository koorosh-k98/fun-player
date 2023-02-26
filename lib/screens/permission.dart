import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/screens/home.dart';

class PermissionHandle extends StatefulWidget {
  static const id = 'permission_screen';

  const PermissionHandle({Key? key}) : super(key: key);

  @override
  State<PermissionHandle> createState() => _PermissionHandleState();
}

class _PermissionHandleState extends State<PermissionHandle>
    with WidgetsBindingObserver {
  requestPermission(BuildContext context) async {
    await Permission.storage.request();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      var status = await Permission.storage.status;
      print(status.toString());
      if (status.isGranted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return const HomePage();
        }));
      } else {
        showAlertDialog(context,
            "Unfortunately we don't have access to your device storage.");
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  showAlertDialog(context, String msg) {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      size: 40,
                      color: Colors.amber,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      msg,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    customButton(
                        child: const Text(
                          "OK, Close the Application",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          SystemNavigator.pop();
                        },
                        color: Colors.red),
                    const SizedBox(
                      height: 12,
                    ),
                    customButton(
                        child: const Text(
                          "Go to settings?",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          openAppSettings();
                          Navigator.of(context).pop();
                        },
                        color: Colors.green)
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Permission")),
      body: Center(
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Please grant storage permission in order to play music.",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 15,
                ),
                customButton(
                    onPressed: () => requestPermission(context),
                    child: const Text(
                      "Ask Permission?",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    color: Colors.green)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget customButton({onPressed, child, color}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        shape: BoxShape.rectangle,
        color: color[400],
      ),
      child: child,
    ),
  );
}
