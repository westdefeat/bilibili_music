import 'package:bilibili_music/bilibili_api/bilibli_api.dart';
import 'package:bilibili_music/ListTileWithImage.dart';
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

// State provider for the slider value
final sliderValueProvider = StateProvider<double>((ref) => 0.0);

class PlayerDetailPage extends ConsumerWidget {

  const PlayerDetailPage();

 @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the slider value
    final sliderValue = ref.watch(sliderValueProvider);
    final miniController = ref.watch(miniControllerProvider);
    // final isPlaying = ref.watch(miniControllerProvider).isPlaying;
    double buttonWidth = MediaQuery.of(context).size.width * 0.3;
    print("miniController.duration");
    print(miniController.duration);

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CachedNetworkImage(
                imageUrl: miniController.imageUrl,
                width: double.infinity,
                // height: 600,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              miniController.mediaName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'xxxxxxx',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Slider(
              // value: 0,
              value: miniController.position.toDouble(),
              onChanged: (value) {
                // Add your slider logic here
                // ref.read(sliderValueProvider.notifier).state = value;
                print("new value: ${value}");
                ref.read(miniControllerProvider.notifier).updatePlayPosition(value.toInt());
              },
              min: 0.0,
              max: miniController.duration.toDouble(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    // Add your previous button logic here
                  },
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 36.0,
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                  onPressed: () {
                    // Toggle play/pause state
                    print("tapped");
                    ref.read(miniControllerProvider.notifier).togglePlayPause();
                  },
                  icon: Icon(miniController.isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 36.0,
                  color: Colors.white,
                ),
                ),
                IconButton(
                  onPressed: () {
                    // Add your next button logic here
                  },
                  icon: const Icon(Icons.skip_next),
                  iconSize: 36.0,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: buttonWidth / 3,
                  child: IconButton(
                    onPressed: () {
                      // Add your list button logic here
                    },
                    icon: const Icon(Icons.list),
                  ),
                ),
                SizedBox(
                  width: buttonWidth / 3,
                  child: IconButton(
                    onPressed: () {
                      // Add your queue button logic here
                    },
                    icon: const Icon(Icons.queue_music),
                  ),
                ),
                SizedBox(
                  width: buttonWidth / 3,
                  child: IconButton(
                    onPressed: () {
                      // Add your more button logic here
                    },
                    icon: const Icon(Icons.more_horiz),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
    );
  }
}
