import 'package:bilibili_music/bilibili_api/bilibili_core.dart';
import 'package:bilibili_music/bilibili_api/bilibli_api.dart';
import 'package:bilibili_music/models/bilibili_list_item_model.dart';
import 'package:bilibili_music/models/player_contrller_model.dart';
import 'package:bilibili_music/views/player_page_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

class PlayerControllerNotifier extends StateNotifier<PlayerControllerModel> {
  PlayerControllerNotifier()
      : super(PlayerControllerModel(
            mediaName: 'Bibilibi音乐',
            isPlaying: false,
            imageUrl:
                'https://i0.hdslb.com/bfs/static/jinkela/long/images/512.png',
            mediaUrl: '',
            duration: 0,
            position: 0)) {
    player.stream.playing.listen(
      (bool playing) {
        // final miniController = ref.watch(miniControllerProvider);
        if (!playing) {
          // This allows us to create a new instance of the model with updated fields, which is crucial for triggering state updates in Riverpod.
          state = state.copyWith(isPlaying: false);
        }
      },
    );
    player.stream.position.listen(
      (Duration position) {
        state = state.copyWith(position: position.inSeconds);
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
      mediaUrl: mediaUrl,
      duration: selectedItem.duration,
      position: 0,
    );
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

  Future<void> updatePlayPosition(int position) async {
    player.seek(Duration(seconds: position));
    state = state.copyWith(position: position);
  }
}

final miniControllerProvider =
    StateNotifierProvider<PlayerControllerNotifier, PlayerControllerModel>(
        (ref) => PlayerControllerNotifier());
