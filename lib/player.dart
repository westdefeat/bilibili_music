
import 'package:bilibili_music/bilibili_api/bilibli_api.dart';
import 'package:bilibili_music/utils.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'bilibili_api/bilibili_core.dart';
import 'models/BilibiliListItem.dart';       

bool showPlayerController = false;

final Player player = Player();
class ControllerPage extends StatefulWidget {
  final BilibiliListItem selectedItem;

  ControllerPage({required this.selectedItem});


  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  bool isPlaying = false;
  late String audioPlayUrl = '';

  void loadMedia() async {
    dynamic brief = await getMediaBrief(widget.selectedItem.bvid); // data/cid
    String cid = brief['data']['cid'].toString();
    dynamic playUrls = await getPlayUrl(widget.selectedItem.bvid, cid);
    audioPlayUrl = playUrls['data']['dash']['audio'][0]['backupUrl'][0];
    await player.open(Media(audioPlayUrl, httpHeaders: ApiConfig.headers));
    setState(() {
      isPlaying = true;
    });
  }
  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    loadMedia();
    showPlayerController |= true;
  }

  void togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
    
    player.playOrPause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controller Page'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image at the top center
          Center(
            child: Image.network(
              widget.selectedItem.coverUrl, // Replace with your image URL
              height: 150,
              width: 150,
            ),
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
                onPressed: togglePlayPause,
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
    );
  }
}


