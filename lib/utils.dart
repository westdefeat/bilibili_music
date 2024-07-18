import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> getProjectDirectory() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  return path;
}

class BiliListItem {
  final String title;
  final String coverUrl;
  final String intro;
  final int mediaCount;
  final String media_ids;

  BiliListItem(
      {required this.title,
      this.coverUrl = '',
      this.intro = '',
      this.mediaCount = 0,
      this.media_ids = ''});

  factory BiliListItem.fromJson(Map<String, dynamic> json) {
    return BiliListItem(
      title: json['title'],
      coverUrl: json['cover_url'],
      intro: json['intro'],
      mediaCount: json['media_count'],
    );
  }
}

class ListTileWithImage extends StatefulWidget {
  final String title;
  final String intro;
  final String coverUrl;
  // final VoidCallback? onLongPress; // make it nullable
  VoidCallback? onTap; // make it nullable
  VoidCallback? onLongPress; // make it nullable
  bool _isSelected = false;
  Color? tileColor = null;
  ListTileWithImage(
      {required this.title, required this.intro, required this.coverUrl, this.onTap, this.onLongPress, this.tileColor});
  
  @override
  State<StatefulWidget> createState() => ListTileWithImageState();
}


class ListTileWithImageState extends State<ListTileWithImage> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: Image.network(widget.coverUrl, fit: BoxFit.fill),
      ),
      title: Text(widget.title.length > 10 ? '${widget.title.substring(0, 10)}...' : widget.title),
      subtitle: Text(widget.intro.length > 10 ? '${widget.intro.substring(0, 10)}...' : widget.intro),    
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      tileColor: widget.tileColor,

      // onLongPress: () => {
      //   setState(() {
      //     _isLongPressed = !_isLongPressed;
      //   })
      // },
      // tileColor: _isLongPressed ? Colors.grey : null,
    );
  }
}
