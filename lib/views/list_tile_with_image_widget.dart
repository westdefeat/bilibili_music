import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getProjectDirectory() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  return path;
}

class ListTileWithImageWidget extends StatefulWidget {
  final String title;
  final String intro;
  final String coverUrl;
  // final VoidCallback? onLongPress; // make it nullable
  VoidCallback? onTap; // make it nullable
  VoidCallback? onLongPress; // make it nullable
  bool isSelected = false;
  Color? tileColor;
  ListTileWithImageWidget(
      {super.key,
      required this.title,
      required this.intro,
      required this.coverUrl,
      this.onTap,
      this.onLongPress,
      required this.isSelected});

  @override
  State<StatefulWidget> createState() => ListTileWithImageWidgetState();
}

class ListTileWithImageWidgetState extends State<ListTileWithImageWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(1.0),
      minVerticalPadding: 0,
      leading: LayoutBuilder(
        builder: (context, constraints) {
          // Dynamically set the size of the image based on the constraints
          return SizedBox(
            width: constraints.maxHeight *
                1.5, // Make the width equal to the height of the ListTile
            height:
                constraints.maxHeight, // Height matches the ListTile's height
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(4.0), // Optional: add some rounding
              child: CachedNetworkImage(
                imageUrl: widget.coverUrl,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover, // Ensure the image covers the container
              ),
            ),
          );
        },
      ),
      title: Text(
        widget.title.length > 20
            ? '${widget.title.substring(0, 20)}...'
            : widget.title,
        style: const TextStyle(
          fontSize: 16, // Customize the font size
          fontWeight: FontWeight.normal, // Customize the font weight
        ),
        maxLines: 1,
      ),
      subtitle: Text(
        widget.intro.length > 100
            ? '${widget.intro.substring(0, 100)}...'
            : widget.intro,
        style: const TextStyle(
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
      tileColor: widget.isSelected ? Colors.blue.withOpacity(0.2) : null,
    );
  }
}
