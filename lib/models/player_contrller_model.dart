class PlayerControllerModel {
  String mediaName;
  bool isPlaying;
  String imageUrl;
  String mediaUrl;
  int duration;
  int position;
  PlayerControllerModel({
    required this.mediaName,
    required this.isPlaying,
    required this.imageUrl,
    required this.mediaUrl,
    required this.duration,
    required this.position,
  });

  PlayerControllerModel copyWith({
    String? mediaName,
    bool? isPlaying,
    String? imageUrl,
    String? mediaUrl,
    int? duration,
    int? position,
  }) {
    return PlayerControllerModel(
      mediaName: mediaName ?? this.mediaName,
      isPlaying: isPlaying ?? this.isPlaying,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      duration: duration ?? this.duration,
      position: position ?? this.position,
    );
  }
}
