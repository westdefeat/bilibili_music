import 'dart:async';

import 'package:bilibili_music/bilibili_api/bilibili_core.dart';
import 'package:bilibili_music/bilibili_api/bilibli_api.dart';
import 'package:bilibili_music/player.dart';
import 'package:bilibili_music/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'models/BilibiliListItem.dart';
import 'views/home_page.dart';

class MiniControllerModel {
  String mediaName;
  bool isPlaying;
  String imageUrl;
  String mediaUrl;
  Player player = Player();

  MiniControllerModel(
      {required this.mediaName,
      required this.isPlaying,
      required this.imageUrl,
      required this.mediaUrl});

  MiniControllerModel copyWith(
      {String? mediaName,
      bool? isPlaying,
      String? imageUrl,
      String? mediaUrl}) {
    return MiniControllerModel(
      mediaName: mediaName ?? this.mediaName,
      isPlaying: isPlaying ?? this.isPlaying,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }
}

class MiniControllerNotifier extends StateNotifier<MiniControllerModel> {
  MiniControllerNotifier()
      : super(MiniControllerModel(
            mediaName: 'Bibilibi音乐',
            isPlaying: false,
            imageUrl:
                'https://i0.hdslb.com/bfs/static/jinkela/long/images/512.png',
            mediaUrl: '')) {
    player.stream.playing.listen(
      (bool playing) {
        // final miniController = ref.watch(miniControllerProvider);
        if (!playing) {
          // This allows us to create a new instance of the model with updated fields, which is crucial for triggering state updates in Riverpod.
          state = state.copyWith(isPlaying: false);
        }
      },
    );
  }

  Future<void> startPlay(BilibiliListItem selectedItem) async {
    // state = state.copyWith(isPlaying: true);
    dynamic brief = await getMediaBrief(selectedItem.bvid); // data/cid
    String cid = brief['data']['cid'].toString();
    dynamic playUrls = await getPlayUrl(selectedItem.bvid, cid);
    String mediaUrl =
        playUrls['data']['dash']['audio'][0]['backupUrl'][0].toString();
    await player.open(Media(mediaUrl, httpHeaders: ApiConfig.headers));
    state = state.copyWith(
        isPlaying: true,
        imageUrl: selectedItem.coverUrl,
        mediaName: selectedItem.title,
        mediaUrl: mediaUrl);
  }

  Future<void> togglePlayPause() async {
    if (state.mediaUrl == '') {
      return;
    }
    state = state.copyWith(isPlaying: !state.isPlaying);
    player.playOrPause();
  }

  Future<void> updatePlayingStatus(bool isPlaying) async {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }
}

final miniControllerProvider =
    StateNotifierProvider<MiniControllerNotifier, MiniControllerModel>(
        (ref) => MiniControllerNotifier());

const miniControllerWidget = MiniControllerWidget();

class MiniControllerWidget extends ConsumerWidget {
  const MiniControllerWidget({super.key});

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
