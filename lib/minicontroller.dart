import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class MiniControllerModel {
  final String mediaName;
  final bool isPlaying;
  final String imageUrl;

  MiniControllerModel({required this.mediaName, required this.isPlaying, required this.imageUrl});

  MiniControllerModel copyWith({String? mediaName, bool? isPlaying, String? imageUrl}) {
    return MiniControllerModel(
      mediaName: mediaName ?? this.mediaName,
      isPlaying: isPlaying ?? this.isPlaying,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class MiniControllerNotifier extends StateNotifier<MiniControllerModel> {
  MiniControllerNotifier()
      : super(MiniControllerModel(mediaName: '', isPlaying: false, imageUrl: ''));

  void updateMedia(String name, bool playing) {
    state = state.copyWith(mediaName: name, isPlaying: playing);
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }
}

final miniControllerProvider =
    StateNotifierProvider<MiniControllerNotifier, MiniControllerModel>(
        (ref) => MiniControllerNotifier());

class MiniControllerWidget extends  ConsumerWidget {
  // final String mediaName;
  // final VoidCallback onPlayPause;
  // final VoidCallback onNext;
  // final bool isPlaying;
  // final ImageProvider image;

  // MiniControllerWidget({
  //   required this.mediaName,
  //   required this.onPlayPause,
  //   required this.onNext,
  //   required this.isPlaying,
  //   required this.image,
  // });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miniController = ref.watch(miniControllerProvider);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: kToolbarHeight, // Set height same as the navigation bar
      color: Colors.grey[900], // Optional: Set a background color
      child: Row(
        children: [
          Container(
            width: kToolbarHeight, // Same width as height for a square image box
            height: kToolbarHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(miniController.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
