import 'package:bilibili_music/bilibili_api/bilibli_api.dart';
import 'package:bilibili_music/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'bilibili_api/bilibili_core.dart';
import 'minicontroller.dart';
import 'models/BilibiliListItem.dart';

bool showPlayerController = false;

final Player player = Player();

const playerDetailPage = PlayerDetailPage();

class PlayerDetailPage extends ConsumerWidget {

  const PlayerDetailPage();

 @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miniController = ref.watch(miniControllerProvider);
    final isPlaying = ref.watch(miniControllerProvider).isPlaying;

    return 
    GestureDetector(
      onPanUpdate: (details) {
    // Handle move action
    print('User is moving: ${details.delta}');
    // You can perform any action here, e.g., moving the widget, updating state, etc.
  },
  onPanEnd: (details) {
    // Handle when the move action ends
    print('User finished moving');
    // You can perform any cleanup or state updates here
  },
      child: 
    Scaffold(
      appBar: AppBar(
        title: Text('Controller Page'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image at the top center
          Center(
            child: CachedNetworkImage(
              imageUrl: miniController.imageUrl,
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error)),
          ),
          SizedBox(height: 100),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous),
                iconSize: 50,
                onPressed: () {
                  // Handle prev action
                },
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 70,
                onPressed: ref.read(miniControllerProvider.notifier).togglePlayPause,
              ),
              IconButton(
                icon: Icon(Icons.skip_next),
                iconSize: 50,
                onPressed: () {
                  // Handle next action
                },
              ),
            ],
          ),
        ],
      ),
    )
    );
  }
}
