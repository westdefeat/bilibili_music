import 'dart:convert';
import 'dart:io';

import 'package:bilibili_music/bilibili_api/bilibli_api.dart';
import 'package:bilibili_music/minicontroller.dart';
import 'package:bilibili_music/player.dart';
import 'package:bilibili_music/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final PageStorageBucket _bucket = PageStorageBucket();
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
      selectedIndices.clear();
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

  final Map<String, Widget> _pageCache = {};

  final Map<String, GlobalKey<_DetailedPageState>> _pageStateKeys = {};

  void _navigateToDetailPage(BuildContext context, BiliListItem item) {
    if (!_pageStateKeys.containsKey(item.media_ids)) {
      _pageStateKeys[item.media_ids] = GlobalKey<_DetailedPageState>();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedPage(
          key: _pageStateKeys[item.media_ids],
          myItem: item,
        ),
      ),
    ).then((result) {
          // if (result != null) {
          // Update your state here
          setState(() {
            // Update your data based on the result
          });
  });
  }
  @override
  Widget build(BuildContext context) {
    // set outer gesture detector, inner gesture detector will take precedence
    return GestureDetector(
        onTap: () {
          isSelectionMode = false;
          selectedIndices.clear();
          setState(() {});
        },
        child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (KeyEvent event) {
              print("esc");

              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                isSelectionMode = false;
                selectedIndices.clear();

                setState(() {});
                // _setFlag();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: PageStorage(
                bucket: _bucket,
                child: Stack(
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
                                        _navigateToDetailPage(
                                            context, _cachedItems[index])
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => DetailedPage(
                                        //         myItem: _cachedItems[index]),
                                        //   ),
                                        // )
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
                          heroTag: 'btn3',
                          onPressed: deleteSelectedItems,
                          child: Icon(Icons.delete),
                          backgroundColor: Colors.red,
                        ),
                      ),
                    if (showPlayerController)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: FloatingActionButton(
                          heroTag: 'btn4',

                          onPressed: deleteSelectedItems,
                          child: MiniControllerWidget(),
                          backgroundColor: Colors.blueGrey,
                        ),
                      )
                  ],
                ),
              ),
              floatingActionButton: isSelectionMode
                  ? FloatingActionButton(
                          heroTag: 'btn41',

                      child: const Icon(Icons.undo),
                      onPressed: () => _handleRefresh(),
                    )
                  : FloatingActionButton(
                          heroTag: 'btn41',
                      child: const Icon(Icons.add),
                      onPressed: () => _showInputDialog(),
                    ),
            )));
  }
}


Map<String, List<BiliListItem>> _detailedPageMediaList = {};

class DetailedPage extends ConsumerStatefulWidget {
  final BiliListItem myItem;

  DetailedPage({Key? key, required this.myItem}) : super(key: key) {
    if (!_detailedPageMediaList.containsKey(myItem.media_ids)) {
      _detailedPageMediaList[myItem.media_ids] = [];
    }
  }

  @override
  _DetailedPageState createState() => _DetailedPageState();
}


class _DetailedPageState extends ConsumerState<DetailedPage> {
  bool _loading = false;
  int _page = 1;
  bool firstLoad = true;
  bool isSelectionMode = false;
  Set<int> selectedIndices = {};
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    bool useCache = _detailedPageMediaList[widget.myItem.media_ids]!.isNotEmpty;
    _loadLists(useCache: useCache);
    _focusNode.requestFocus();
  }

  Future<List<BiliListItem>> _loadLists({bool useCache = false}) async {

      List<BiliListItem> _cachedItems = _detailedPageMediaList[widget.myItem.media_ids]!;
      if (useCache) {
      setState(() {
        _loading = false;
      });
      print("use cache");
        return _cachedItems;
      }
      setState(() {
        if (widget.myItem.mediaCount != 0) {
          _loading = true;
        }
      });

      dynamic jsonData = await getFavouredMediaList(widget.myItem.media_ids,
          pageNumber: _page++);
      List<dynamic> dataList = jsonData['data']['medias'] ?? [];

      for (var jsonItem in dataList) {
        BiliListItem item = BiliListItem(
          title: jsonItem['title'],
          coverUrl: jsonItem['cover'],
          intro: jsonItem['intro'],
          id: jsonItem['id'].toString(),
          type: jsonItem['type'].toString(),
          bvid: jsonItem['bvid'].toString(),
        );

      _cachedItems.add(item);
      }


    setState(() {
      _loading = false;
    });
    return _cachedItems;
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
      List<BiliListItem> _cachedItems = _detailedPageMediaList[widget.myItem.media_ids]!;

    dynamic resources = 'resources=';
    for (int element in selectedIndices) {
      resources += _cachedItems[element].id.toString() +
          ':' +
          _cachedItems[element].type.toString() +
          ',';
    }
    print(resources);
    dynamic res = await removeBatchFromFav(widget.myItem.media_ids, resources);
    print(res);
    for (int index in selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a))) {
      _cachedItems.removeAt(index);
    }
    widget.myItem.mediaCount -= selectedIndices.length;
    selectedIndices.clear();
    isSelectionMode = false;
    setState(() {
      isSelectionMode = false;
    });
  }

  Future<void> _handleRefresh() async {
    // Update the list of items and refresh the UI
    setState(() {
      print('1');
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
      List<BiliListItem> _cachedItems = _detailedPageMediaList[widget.myItem.media_ids]!;
    final miniController = ref.watch(miniControllerProvider);
    return GestureDetector(
        onTap: () {
          isSelectionMode = false;
          selectedIndices.clear();
          setState(() {});
        },
        child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                isSelectionMode = false;
                selectedIndices.clear();

                setState(() {});
                // _setFlag();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.myItem.title),
              ),
              body: Stack(
                children: [
                  _cachedItems.isEmpty && widget.myItem.mediaCount != 0
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            if (notification is ScrollEndNotification &&
                                notification.metrics.extentAfter == 0 &&
                                _cachedItems.length <
                                    widget.myItem.mediaCount) {
                              print("here!!");
                              print(_cachedItems.isEmpty);
                              print(widget.myItem.mediaCount);
                              print(_cachedItems.length);
                              _loadLists();
                            }
                            return true;
                          },
                          child: ListView.builder(
                            key: PageStorageKey(widget.myItem.media_ids),
                            itemCount: _cachedItems.length,
                            itemBuilder: (context, index) {
                              return ListTileWithImage(
                                title: _cachedItems[index].title,
                                intro: _cachedItems[index].intro,
                                coverUrl: _cachedItems[index].coverUrl,
                                onTap: () => {
                                  if (isSelectionMode)
                                    {toggleSelectionMode(index)}
                                  else
                                    {
                                       ref.read(miniControllerProvider.notifier).startPlay(_cachedItems[index]),
                                      setState(() {
                                       showPlayerController = true;
                                      }),
                                      // miniController.isPlaying = true
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) =>
                                      //           ControllerPage(
                                      //               myItem:
                                      //                   _cachedItems[index]),
                                      //     )).then((result) {
                                      //   // if (result != null) {
                                      //   // Update your state here
                                      //   setState(() {
                                      //     // Update your data based on the result
                                      //   });
                                      //   // }
                                      // })
                                    }
                                },
                                onLongPress: () => toggleSelectionMode(index),
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
                        heroTag: "btn2",
                        onPressed: deleteSelectedItems,
                        child: Icon(Icons.delete),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  if (isSelectionMode)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        heroTag: "btn1",
                        onPressed: deleteSelectedItems,
                        child: Icon(Icons.add),
                        backgroundColor: Colors.blueGrey,
                      ),
                    ),
                  if (showPlayerController)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child:  miniControllerWidget,
                    )
                ],
              ),
              bottomNavigationBar:
                  _loading ? const LinearProgressIndicator() : null,
            )));
  }
}
