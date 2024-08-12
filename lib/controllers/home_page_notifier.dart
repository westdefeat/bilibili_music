
import 'package:bilibili_music/models/home_page_model.dart';
import 'package:bilibili_music/views/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePageNotifier extends StateNotifier<HomePageModel> {
  HomePageNotifier()
      : super(HomePageModel(showMiniController: false));

  void updateMedia(bool showMiniController) {
    state = state.copyWith(showMiniController: showMiniController);
  }

}

final homePageProvider =
    StateNotifierProvider<HomePageNotifier, HomePageModel>(
        (ref) => HomePageNotifier());