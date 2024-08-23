import 'package:bilibili_music/controllers/player_contrller.dart';
import 'package:bilibili_music/models/bilibili_list_item_model.dart';
import 'package:bilibili_music/views/common_list_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilibili_music/bilibili_api/bilibli_api.dart';

class SearchMediaListPageWidget extends ConsumerStatefulWidget {
  BilibiliListItem selectedItem;

  List<BilibiliListItem> cachedItems = [];
  bool firstLoad = true;

  SearchMediaListPageWidget({super.key, required this.selectedItem});

  @override
  SearchMediaListPageState createState() => SearchMediaListPageState();
}

class SearchMediaListPageState
    extends ConsumerState<SearchMediaListPageWidget> {
  bool _loading = false;
  int _page = 1;
  bool isSelectionMode = false;
  Set<int> selectedIndices = {};

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
    dynamic jsonData =
        await getSearchResults(widget.selectedItem.media_ids, page: _page++);
    widget.selectedItem.mediaCount = jsonData['data']['numResults'];

    String removeContentsInAngleBrackets(String input) {
      // Regular expression to match content within angle brackets
      final RegExp regExp = RegExp(r'<[^>]*>');
      return input.replaceAll(regExp, '');
    }

    List<dynamic> dataList = jsonData['data']['result'] ?? [];
    for (var jsonItem in dataList) {
      BilibiliListItem item = BilibiliListItem(
        title: removeContentsInAngleBrackets(jsonItem['title']),
        coverUrl: jsonItem['pic'].toString().startsWith('http')
            ? jsonItem['pic'].toString()
            : "https:" + jsonItem['pic'],
        intro: jsonItem['description'],
        id: jsonItem['id'].toString(),
        type: jsonItem['type'].toString(),
        bvid: jsonItem['bvid'].toString(),
        duration: decodeDurationToSeconds(jsonItem['duration']),
      );
      cachedLists.add(item);
    }

    setState(() {
      _loading = false;
    });
  }

  void deleteSelectedItems(
      List<BilibiliListItem> cachedLists, Set<int> selectedIndices) async {}

  void onItemTapped(BuildContext context, List<BilibiliListItem> items, int index) {
    BilibiliListItem item = items[index];
    // List<BilibiliListItem> cachedItems = cachedLists!;
    ref.read(miniControllerProvider.notifier).startPlay(items, index);
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

Map<String, SearchMediaListPageWidget> searchMediaList = {};
