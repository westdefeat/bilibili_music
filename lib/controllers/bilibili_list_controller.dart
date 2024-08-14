import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bilibili_api/bilibli_api.dart';
import '../models/BilibiliListItem.dart';
import '../models/bilibili_list_model.dart';
import '../models/home_page_model.dart';

class BilibiliListNotifier extends StateNotifier<BilibiliListModel> {
  BilibiliListNotifier(Function? loadItems, Function? deleteItem)
      : super(BilibiliListModel(
          loadItems: loadItems,
          deleteItem: deleteItem,
          isSelectionMode: false,
          mediaLists: [],
          selectedIndices: {},
          pageNumber: 0,
          currentItem: BilibiliListItem(title: 'dummy'),
        )) {
    addMoreItems();

  }

  void updateSelectionMode(bool isSelectionMode) {
    // state = state.copyWith(isSelectionMode: isSelectionMode);
    state.isSelectionMode = isSelectionMode;
    if (isSelectionMode == false) {
      state.selectedIndices.clear();
    }
  }

  void addToSelectIndices(int index) {
    state.selectedIndices.add(index);
    // state = state.copyWith(selectedIndices: state.selectedIndices);
  }

  void rmFromSelectedIndices(int index) {}

  Future<void> addMoreItems() async {
    var items = await state.loadItems!();
    print(items);
    state.mediaLists.addAll(items);
  }

  void toggleSelectionMode(int index) {
    if (state.isSelectionMode) {
      if (state.selectedIndices.contains(index)) {
        state.selectedIndices.remove(index);
      } else {
        state.selectedIndices.add(index);
      }
      if (state.selectedIndices.isEmpty) {
        state.isSelectionMode = false;
      }
    } else {
      state.isSelectionMode = true;
      state.selectedIndices.add(index);
    }
  }
}

// final favListProvider =
//     StateNotifierProvider<BilibiliListNotifier, BilibiliListModel>(
//         (ref) => BilibiliListNotifier());

// final searchListProvider =
//     StateNotifierProvider<BilibiliListNotifier, BilibiliListModel>(
//         (ref) => BilibiliListNotifier());

Future<List<BilibiliListItem>> loadFavList() async {
  dynamic data = await fetchFavList();
  List<dynamic> dataList = data['data']['list'];
  List<BilibiliListItem> items = [];
  for (var jsonItem in dataList) {
    String id = jsonItem['id'].toString();
    dynamic detailJson =
        await fetchFavInfo(id); // load detail JSON for each item

    BilibiliListItem item = BilibiliListItem(
        title: jsonItem['title'],
        coverUrl: detailJson['data']['cover'],
        intro: detailJson['data']['intro'],
        mediaCount: detailJson['data']['media_count'],
        media_ids: id);

    items.add(item);
  }
  return items;
}

Future<List<BilibiliListItem>> loadMediaList(BilibiliListModel? model) async {
  if (model == null) {
    return [];
  }
  List<BilibiliListItem> items = [];
  dynamic jsonData = await getFavouredMediaList(model.currentItem.media_ids,
      pageNumber: model.pageNumber++);
  List<dynamic> dataList = jsonData['data']['medias'] ?? [];

  for (var jsonItem in dataList) {
    BilibiliListItem item = BilibiliListItem(
      title: jsonItem['title'],
      coverUrl: jsonItem['cover'],
      intro: jsonItem['intro'],
      id: jsonItem['id'].toString(),
      type: jsonItem['type'].toString(),
      bvid: jsonItem['bvid'].toString(),
    );

    items.add(item);
  }

  return items;
}

void deleteFavs(BilibiliListModel? model) async {
  if (model == null) {
    return;
  }
  for (int element in model.selectedIndices) {
    await removeFav(model.mediaLists[element].media_ids);
  }
  for (int index in model.selectedIndices.toList()
    ..sort((a, b) => b.compareTo(a))) {
    model.mediaLists.removeAt(index);
  }
}

final Map<String, StateNotifierProvider<BilibiliListNotifier, BilibiliListModel>>
    mediaListProviders = {
  "fav": StateNotifierProvider<BilibiliListNotifier, BilibiliListModel>(
      (ref) => BilibiliListNotifier(loadFavList, deleteFavs)),
  // "search": StateNotifierProvider<BilibiliListNotifier, BilibiliListModel>(
  //     (ref) => BilibiliListNotifier())
};
