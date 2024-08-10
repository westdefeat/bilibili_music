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
  int mediaCount;
  final String media_ids; // fav id
  final String id; // video id
  final String type; // video id
  final String bvid; // bv id

  BiliListItem(
      {required this.title,
      this.coverUrl = '',
      this.intro = '',
      this.mediaCount = 0,
      this.media_ids = '',
      this.id = '',
      this.type = '2',
      this.bvid = ''});

}

class ListTileWithImage extends StatefulWidget {
  final String title;
  final String intro;
  final String coverUrl;
  // final VoidCallback? onLongPress; // make it nullable
  VoidCallback? onTap; // make it nullable
  VoidCallback? onLongPress; // make it nullable
  bool isSelected = false;
  Color? tileColor = null;
  ListTileWithImage(
      {required this.title, required this.intro, required this.coverUrl, this.onTap, this.onLongPress, required this.isSelected});
  
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
      trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(Icons.edit, size: 14),
        onPressed: () {
          // handle edit action
        },
      ),
      
    ],
  ),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      tileColor:  widget.isSelected ? Colors.blue.withOpacity(0.2) : null,

      // onLongPress: () => {
      //   setState(() {
      //     _isLongPressed = !_isLongPressed;
      //   })
      // },
      // tileColor: _isLongPressed ? Colors.grey : null,
    );
  }
}
