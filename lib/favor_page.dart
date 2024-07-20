import 'dart:convert';
import 'dart:io';

import 'package:bilibili_music/bilibili_api/bilibli_api.dart';
import 'package:bilibili_music/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class FavorPage extends StatefulWidget {
  final String title;

  const FavorPage({
    super.key,
    required this.title,
  });

  @override
  State<FavorPage> createState() => _FavorPageState();
}

class _FavorPageState extends State<FavorPage> {
  bool firstLoad = true;
  bool isSelectionMode = false;
  List<BiliListItem> _cachedItems = [];
  Set<int> selectedIndices = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _introController = TextEditingController();
FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    loadJson();
    super.initState();
    // Print debug information here
    print('FavorPageState has been created');
    _focusNode.requestFocus();
  
  }

  Future<List<BiliListItem>> loadJson() async {
    print("load json");
    if (!firstLoad) {
      print('first load');
    } else {
      firstLoad = false;

      dynamic data = await fetchFavList();
      List<dynamic> dataList = data['data']['list'];
      List<BiliListItem> items = [];
      for (var jsonItem in dataList) {
        String id = jsonItem['id'].toString();
        dynamic detailJson =
            await fetchFavInfo(id); // load detail JSON for each item

        BiliListItem item = BiliListItem(
            title: jsonItem['title'],
            coverUrl: detailJson['data']['cover'],
            intro: detailJson['data']['intro'],
            mediaCount: detailJson['data']['media_count'],
            media_ids: id);

        items.add(item);
      }
      _cachedItems = items;
      print('cache items: $_cachedItems');
      
    }
      setState(() {

      print('1');

    });
      return _cachedItems;

  }

  Future<void> _handleRefresh() async {
    // Update the list of items and refresh the UI
    setState(() {
      print('1');
      isSelectionMode = false;
    });
  }

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('输入详情'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '名称'),
              ),
              TextField(
                controller: _introController,
                decoration: const InputDecoration(labelText: '介绍'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  dynamic data = await createFav(
                      _nameController.text, _introController.text, 0);

                  if (data != null &&
                      data['code'] != null &&
                      data['message'] != null) {
                    await _handleRefresh();
                    _showSnackBar(
                      data['code'] == 0 ? '创建成功！' : data['message'],
                    );
                    if (data['code'] == 0) {
                      print(data);
                      print(_cachedItems[0].media_ids);
                      _cachedItems.add(BiliListItem(
                          title: _nameController.text,
                          intro: _introController.text,
                          mediaCount: 0,
                          media_ids: data['data']['id'].toString()));
                    }
                  } else {
                    _showSnackBar('Unknown error');
                  }
                } catch (e) {
                  _showSnackBar('Error: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void toggleSelectionMode(int index) {
    setState(() {
    if (isSelectionMode) {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
      if (selectedIndices.isEmpty) {
        isSelectionMode = false;
      }
    } else {
      isSelectionMode = true;
      selectedIndices.add(index);
    }
    });
  }

  void deleteSelectedItems() async {
    for (int element in selectedIndices) {
      dynamic res = await removeFav(_cachedItems[element].media_ids);
      print(res);
      print(_cachedItems[element].media_ids);
    }
    for (int index in selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a))) {
      _cachedItems.removeAt(index);
    }
    selectedIndices.clear();
    isSelectionMode = false;
        setState(() {
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // set outer gesture detector, inner gesture detector will take precedence
    return GestureDetector(
      onTap: () {
            // print("esc");
          isSelectionMode = false;
selectedIndices.clear();
        setState(() {
        });
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent  && event.logicalKey == LogicalKeyboardKey.escape) {
              isSelectionMode = false;
selectedIndices.clear();

            setState(() {
            });
            // _setFlag();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _handleRefresh,
                child: _cachedItems.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _cachedItems.length,
                        itemBuilder: (context, index) {
                          return ListTileWithImage(
                            onTap: () => {
                              if (isSelectionMode)
                                {toggleSelectionMode(index)}
                              else
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailedPage(myItem: _cachedItems[index]),
                                    ),
                                  )
                                }
                            },
                            onLongPress: () => toggleSelectionMode(index),
                            title: _cachedItems[index].title,
                            intro: _cachedItems[index].intro,
                            coverUrl: _cachedItems[index].coverUrl,
                            isSelected: selectedIndices.contains(index),
                          );
                        },
                      ),
              ),
              if (isSelectionMode)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: FloatingActionButton(
                    onPressed: deleteSelectedItems,
                    child: Icon(Icons.delete),
                    backgroundColor: Colors.red,
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _showInputDialog(),
          ),
        )
      )
    );
  }
}

class DetailedPage extends StatefulWidget {
  final BiliListItem myItem;

  DetailedPage({required this.myItem});

  @override
  _DetailedPageState createState() => _DetailedPageState();
}

class _DetailedPageState extends State<DetailedPage> {
  List<BiliListItem> _lists = [];
  bool _loading = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<List<BiliListItem>> _loadLists() async {
    setState(() {
      if (widget.myItem.mediaCount != 0) {
        _loading = true;
      }
    });
    print(widget.myItem.media_ids);
    dynamic jsonData = await getFavouredMediaList(widget.myItem.media_ids,
        pageNumber: _page++);
    print(jsonData);
    List<dynamic> dataList = jsonData['data']['medias'] ?? [];
    List<BiliListItem> items = [];

    for (var jsonItem in dataList) {
      BiliListItem item = BiliListItem(
        title: jsonItem['title'],
        coverUrl: jsonItem['cover'],
        intro: jsonItem['intro'],
      );

      items.add(item);
    }
    setState(() {
      _lists.addAll(items);
      _loading = false;
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.myItem.title),
      ),
      body: _lists.isEmpty && widget.myItem.mediaCount != 0
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter == 0 &&
                    _lists.length < widget.myItem.mediaCount) {
                  _loadLists();
                }
                return true;
              },
              child: ListView.builder(
                itemCount: _lists.length,
                itemBuilder: (context, index) {
                  return ListTileWithImage(
                    title: _lists[index].title,
                    intro: _lists[index].intro,
                    coverUrl: _lists[index].coverUrl,
                    onTap: null,
                    isSelected: false,
                  );
                },
              ),
            ),
      bottomNavigationBar: _loading ? const LinearProgressIndicator() : null,
    );
  }
}
