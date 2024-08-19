import 'package:bilibili_music/controllers/player_contrller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilibili_music/views/player_page_widget.dart';

const miniControllerWidget = MiniPlayerWidget();

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miniController = ref.watch(miniControllerProvider);
    final isPlaying = ref.watch(miniControllerProvider).isPlaying;

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => playerDetailPage),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: kToolbarHeight, // Set height same as the navigation bar
          color: Theme.of(context)
              .primaryColor, // Optional: Set a background color
          child: Row(
            children: [
              CachedNetworkImage(
                  imageUrl: miniController.imageUrl,
                  // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error)),
              const SizedBox(width: 8), // Optional spacing
              Expanded(
                child: Text(
                  miniController.mediaName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle long text
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed:
                    ref.read(miniControllerProvider.notifier).togglePlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () => {},
              ),
            ],
          ),
        ));
  }
}
