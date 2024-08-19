import 'package:bilibili_music/models/bilibili_list_item_model.dart';
import 'package:bilibili_music/views/common_list_page_widget.dart';
import 'package:bilibili_music/views/fav_media_list_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilibili_music/bilibili_api/bilibli_api.dart';

class FavListPageWidget extends ConsumerStatefulWidget {
  BilibiliListItem selectedItem =
      BilibiliListItem(title: '我的收藏', media_ids: 'fav');

  List<BilibiliListItem> cacheItems = [];
  bool firstLoad = true;
  FavListPageWidget({super.key});

  @override
  FavListPageState createState() => FavListPageState();
}

class FavListPageState extends ConsumerState<FavListPageWidget> {
  bool firstLoad = true;
  bool isSelectionMode = false;
  Set<int> selectedIndices = {};

  Future<void> loadLists(
      {required List<BilibiliListItem> cachedLists,
      bool? initialize = false}) async {
    if (widget.firstLoad == false && initialize == true) {
      return;
    }
    widget.firstLoad = false;
    dynamic data = await fetchFavList();
    List<dynamic> dataList = data['data']['list'];
    // List<BilibiliListItem> items = [];
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
      cachedLists.add(item);
    }
    setState(() {});
  }

  void deleteSelectedItems(
      List<BilibiliListItem> cachedLists, Set<int> selectedIndices) async {
    dynamic cachedItems = cachedLists;
    for (int element in selectedIndices) {
      dynamic res = await removeFav(cachedItems[element].media_ids);
    }

    for (int index in selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a))) {
      cachedItems.removeAt(index);
    }
    selectedIndices.clear();
    isSelectionMode = false;
    setState(() {
      isSelectionMode = false;
    });
  }

  void onItemTapped(BuildContext context, BilibiliListItem item) {
    if (!mediaList.containsKey(item.media_ids)) {
      mediaList[item.media_ids] = FavMediaListPageWidget(
        selectedItem: item,
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => mediaList[item.media_ids]!
          // builder: (context) =>  FavMediaListPage(selectedItem: item,)
          ),
    ).then((result) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonListPageWidget(
        selectedItem: widget.selectedItem,
        cachedLists: widget.cacheItems,
        loadLists: loadLists,
        deleteSelectedItems: deleteSelectedItems,
        onItemSelected: onItemTapped);
  }
}

FavListPageWidget favListPage = FavListPageWidget();
