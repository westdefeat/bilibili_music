import 'package:bilibili_music/bilibili_api/bilibili_core.dart';
import 'package:bilibili_music/bilibili_api/bilibli_api.dart';
import 'package:bilibili_music/player.dart';
import 'package:bilibili_music/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
class MiniControllerModel {
  final String mediaName;
  final bool isPlaying;
  final String imageUrl;
  final String mediaUrl;
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
    state = state.copyWith(mediaName: name, isPlaying: playing);
  }

  Future<void> startPlay(BiliListItem myItem) async {
    state = state.copyWith(isPlaying: !state.isPlaying);
    dynamic brief = await getMediaBrief(myItem.bvid); // data/cid
    String cid = brief['data']['cid'].toString();
    dynamic playUrls = await getPlayUrl(myItem.bvid, cid);
    await player.open(Media(playUrls['data']['dash']['audio'][0]['backupUrl'][0], httpHeaders: ApiConfig.headers));
    state = state.copyWith(isPlaying: true, imageUrl: myItem.coverUrl, mediaName: myItem.title);
  }

  Future<void> togglePlayPause() async {
     state = state.copyWith(isPlaying: !state.isPlaying);
     player.playOrPause();
  }
}

final miniControllerProvider =
    StateNotifierProvider<MiniControllerNotifier, MiniControllerModel>(
        (ref) => MiniControllerNotifier());

final miniControllerWidget = MiniControllerWidget();

class MiniControllerWidget extends  ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miniController = ref.watch(miniControllerProvider);
    
    print("miniController.imageUrl: ");
    print(miniController.imageUrl);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: kToolbarHeight, // Set height same as the navigation bar
      color: Colors.grey[900], // Optional: Set a background color
      child: Row(
        children: [
         CachedNetworkImage(
              imageUrl: miniController.imageUrl,
              // placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error)),
          SizedBox(width: 8), // Optional spacing
          Expanded(
            child: Text(
              miniController.mediaName,
              style: TextStyle(
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
            icon: Icon(Icons.skip_next, color: Colors.white),
            onPressed: ()=>{},
          ),
        ],
      ),
    );
  }
}
