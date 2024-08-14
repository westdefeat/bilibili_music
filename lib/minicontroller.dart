import 'package:bilibili_music/bilibili_api/bilibili_core.dart';
import 'package:bilibili_music/bilibili_api/bilibli_api.dart';
import 'package:bilibili_music/player.dart';
import 'package:bilibili_music/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'models/BilibiliListItem.dart';
class MiniControllerModel {
  String mediaName;
  bool isPlaying;
  String imageUrl;
  String mediaUrl;
  Player player = Player();

  MiniControllerModel({required this.mediaName, required this.isPlaying, required this.imageUrl, required this.mediaUrl});

  MiniControllerModel copyWith({String? mediaName, bool? isPlaying, String? imageUrl, String? mediaUrl}) {
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
      : super(MiniControllerModel(mediaName: '', isPlaying: false, imageUrl: '', mediaUrl: ''));

  void updateMedia(String name, bool playing) {
    // state = state.copyWith(mediaName: name, isPlaying: playing);
    state.mediaName = name;
    state.isPlaying = playing;
  }

  Future<void> startPlay(BilibiliListItem selectedItem) async {
    state = state.copyWith(isPlaying: !state.isPlaying);
    dynamic brief = await getMediaBrief(selectedItem.bvid); // data/cid
    String cid = brief['data']['cid'].toString();
    dynamic playUrls = await getPlayUrl(selectedItem.bvid, cid);
    await player.open(Media(playUrls['data']['dash']['audio'][0]['backupUrl'][0], httpHeaders: ApiConfig.headers));
    state = state.copyWith(isPlaying: true, imageUrl: selectedItem.coverUrl, mediaName: selectedItem.title);
    updateMedia(selectedItem.title, true);
  }

  Future<void> togglePlayPause() async {
     state = state.copyWith(isPlaying: !state.isPlaying);
     player.playOrPause();
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
    
    return Container(
      width: MediaQuery.of(context).size.width,
      height: kToolbarHeight, // Set height same as the navigation bar
      color: Theme.of(context).primaryColor, // Optional: Set a background color
      child: Row(
        children: [
         CachedNetworkImage(
              imageUrl: miniController.imageUrl,
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error)),
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
              miniController.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: ref.read(miniControllerProvider.notifier).togglePlayPause,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: ()=>{},
          ),
        ],
      ),
    );
  }
}
