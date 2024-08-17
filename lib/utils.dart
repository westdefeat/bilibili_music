import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> getProjectDirectory() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  return path;
}

class ListTileWithImage extends StatefulWidget {
  final String title;
  final String intro;
  final String coverUrl;
  // final VoidCallback? onLongPress; // make it nullable
  VoidCallback? onTap; // make it nullable
  VoidCallback? onLongPress; // make it nullable
  bool isSelected = false;
  Color? tileColor;
  ListTileWithImage(
      {super.key, required this.title, required this.intro, required this.coverUrl, this.onTap, this.onLongPress, required this.isSelected});
  
  @override
  State<StatefulWidget> createState() => ListTileWithImageState();
}


class ListTileWithImageState extends State<ListTileWithImage> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(1.0),
      minVerticalPadding: 0,
      leading: 
      LayoutBuilder(
        builder: (context, constraints) {
          // Use the constraints to dynamically set the size of the image
          double sideLength = constraints.maxHeight;
          return SizedBox(
            width: 90, // Match the width with the ListTile's height
            height: 56, // Match the height with the ListTile's height
        child: 
        CachedNetworkImage(
            imageUrl: widget.coverUrl,
            // placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.fill, 
        )
          );
        }
      ),
      title: Text(
        widget.title.length > 20 ? '${widget.title.substring(0, 20)}...' : widget.title,
        style: TextStyle(
          fontSize: 16, // Customize the font size
          fontWeight: FontWeight.normal, // Customize the font weight
        ),
        maxLines: 1,
      ),
      subtitle: Text(
        widget.intro.length > 100 ? '${widget.intro.substring(0, 100)}...' : widget.intro,
        style: TextStyle(
          fontSize: 14, // Customize the font size
          color: Colors.grey, // Customize the color
        ),
        maxLines: 2,
      ),    
      trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.more_vert, size: 14),
        onPressed: () {
          // handle edit action
        },
      ),
    ],
  ),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      tileColor:  widget.isSelected ? Colors.blue.withOpacity(0.2) : null,
    );
  }
}


