import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:player/home.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandle extends StatefulWidget{
  static const id = 'permission_screen';

  const PermissionHandle({Key? key}) : super(key: key);

  @override
  State<PermissionHandle> createState() => _PermissionHandleState();
}

class _PermissionHandleState extends State<PermissionHandle>  with WidgetsBindingObserver {
  requestPermission(BuildContext context) async {
    await Permission.storage.request();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    if(state == AppLifecycleState.resumed){
      var status = await Permission.storage.status;
      if (status.isGranted) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) {
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
                    Text(
                      msg,
                      style: const TextStyle(fontSize: 22),
                    ),
                    MaterialButton(
                        child: const Text("OK, Close the Application"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          SystemNavigator.pop();
                        }),
                    MaterialButton(
                      child: const Text("Go to settings?"),
                      onPressed: () {
                        openAppSettings();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Permission")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Please grant storage permission in order to play music.",
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () => requestPermission(context),
                  child: const Text(
                    "Ask Permission?",
                    style: TextStyle(fontSize: 20),
                  ))
            ]),
      ),
    );
  }
}
