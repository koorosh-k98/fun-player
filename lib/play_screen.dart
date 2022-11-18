import 'package:flutter/material.dart';

class PlayScreen extends StatefulWidget {
  PlayScreen({required this.path, Key? key}) : super(key: key);
  String path;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {

  @override
  void initState() {
    super.initState();
    print(widget.path);
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
