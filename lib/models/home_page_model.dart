class HomePageModel {
  bool showMiniController = false;
  HomePageModel({required this.showMiniController});

  HomePageModel copyWith({bool? showMiniController}) {
    return HomePageModel(
      showMiniController: showMiniController ?? this.showMiniController,
    );
  }
}
