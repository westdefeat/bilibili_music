import 'package:bilibili_music/controllers/player_contrller.dart';
import 'package:bilibili_music/models/bilibili_list_item_model.dart';
import 'package:bilibili_music/views/common_list_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilibili_music/bilibili_api/bilibli_api.dart';

class FavMediaListPageWidget extends ConsumerStatefulWidget {
  BilibiliListItem selectedItem;
  // Function loadLists;
  // Function deleteSelectedItems;
//   Function onItemSelected;
//  Map<String, List<BilibiliListItem>> cachedLists;
  List<BilibiliListItem> cachedItems = [];
  bool firstLoad = true;

  FavMediaListPageWidget({super.key, required this.selectedItem});

  @override
  FavMediaListPageState createState() => FavMediaListPageState();
}

class FavMediaListPageState extends ConsumerState<FavMediaListPageWidget> {
  int _page = 1;
  bool isSelectionMode = false;
  Set<int> selectedIndices = {};
  bool _loading = false;

  Future<void> loadLists(
      {required List<BilibiliListItem> cachedLists,
      bool? initialize = false}) async {
    if (widget.firstLoad == false && initialize == true) {
      return;
    }
    widget.firstLoad = false;

    // 此处setState将导致报错
    // setState(() {
    // });
    dynamic jsonData = await getFavouredMediaList(widget.selectedItem.media_ids,
        pageNumber: _page++);

    List<dynamic> dataList = jsonData['data']['medias'] ?? [];
    for (var jsonItem in dataList) {
      BilibiliListItem item = BilibiliListItem(
        title: jsonItem['title'],
        coverUrl: jsonItem['cover'],
        intro: jsonItem['intro'],
        id: jsonItem['id'].toString(),
        type: jsonItem['type'].toString(),
        bvid: jsonItem['bvid'].toString(),
        duration: jsonItem['duration'],
      );
      cachedLists.add(item);
    }

    setState(() {
      _loading = false;
    });
  }

  void deleteSelectedItems(
      List<BilibiliListItem> cachedLists, Set<int> selectedIndices) async {
    List<BilibiliListItem> cachedItems = cachedLists;

    dynamic resources = 'resources=';
    for (int element in selectedIndices) {
      resources += '${cachedItems[element].id}:${cachedItems[element].type},';
    }

    await removeBatchFromFav(widget.selectedItem.media_ids, resources);
    for (int index in selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a))) {
      cachedLists.removeAt(index);
    }
    widget.selectedItem.mediaCount -= selectedIndices.length;
    selectedIndices.clear();
    isSelectionMode = false;
    setState(() {
      isSelectionMode = false;
    });
  }

  void onItemTapped(BuildContext context, BilibiliListItem item) {
    // List<BilibiliListItem> cachedItems = cachedLists!;
    ref.read(miniControllerProvider.notifier).startPlay(item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CommonListPageWidget(
        selectedItem: widget.selectedItem,
        cachedLists: widget.cachedItems,
        loadLists: loadLists,
        deleteSelectedItems: deleteSelectedItems,
        onItemSelected: onItemTapped);
  }
}

Map<String, FavMediaListPageWidget> mediaList = {};
