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
  Set<int> selectedIndexes = {};
  bool xx = false;
  bool isSelected = false;
  List<BiliListItem> _cachedItems = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _introController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Print debug information here
    print('FavorPageState has been created');
  }

  Future<List<BiliListItem>> loadJson() async {
    print(_cachedItems);
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

    return items;
  }

  Future<void> _handleRefresh() async {
    // Update the list of items and refresh the UI
    setState(() {
      print('1');
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
                  print(data);
                  if (data != null &&
                      data['code'] != null &&
                      data['message'] != null) {
                    await _handleRefresh();
                    _showSnackBar(
                      data['code'] == 0 ? '创建成功！' : data['message'],
                    );
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

  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: loadJson(),
        builder: (context, AsyncSnapshot<List<BiliListItem>> snapshot) {
          if (snapshot.hasData) {
            List<BiliListItem> items = snapshot.data ?? [];
            return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTileWithImage(
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailedPage(myItem: items[index]),
                          ),
                        )
                      },
                      onLongPress: () => {
                        setState(() {
                          isSelected =
                              !isSelected; // Toggle the selection state
                        })
                      },
                      title: items[index].title,
                      intro: items[index].intro,
                      coverUrl: items[index].coverUrl,
                      tileColor: isSelected ? Colors.grey : null,
                    );
                  },
                ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showInputDialog(),
      ),
    );
  }
}

class ListTileWithImage extends StatefulWidget {
  final String title;
  final String intro;
  final String coverUrl;
  // final VoidCallback? onLongPress; // make it nullable
  VoidCallback? onTap; // make it nullable
  VoidCallback? onLongPress; // make it nullable
  bool _isSelected = false;
  Color? tileColor = null;
  ListTileWithImage(
      {required this.title,
      required this.intro,
      required this.coverUrl,
      this.onTap,
      this.onLongPress,
      this.tileColor});

  @override
  State<StatefulWidget> createState() => ListTileWithImageState();
}

class ListTileWithImageState extends State<ListTileWithImage> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: Image.network(widget.coverUrl, fit: BoxFit.fill),
      ),
      title: Text(widget.title.length > 10
          ? '${widget.title.substring(0, 10)}...'
          : widget.title),
      subtitle: Text(widget.intro.length > 10
          ? '${widget.intro.substring(0, 10)}...'
          : widget.intro),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      tileColor: widget.tileColor,

      // onLongPress: () => {
      //   setState(() {
      //     _isLongPressed = !_isLongPressed;
      //   })
      // },
      // tileColor: _isLongPressed ? Colors.grey : null,
    );
  }
}

class BiliListItem {
  final String title;
  final String coverUrl;
  final String intro;
  final int mediaCount;
  final String media_ids;

  BiliListItem(
      {required this.title,
      this.coverUrl = '',
      this.intro = '',
      this.mediaCount = 0,
      this.media_ids = ''});

  factory BiliListItem.fromJson(Map<String, dynamic> json) {
    return BiliListItem(
      title: json['title'],
      coverUrl: json['cover_url'],
      intro: json['intro'],
      mediaCount: json['media_count'],
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

    dynamic jsonData = await getFavouredMediaList(widget.myItem.media_ids,
        pageNumber: _page++);
    List<dynamic> dataList = jsonData['data']['medias'];
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
                  );
                },
              ),
            ),
      bottomNavigationBar: _loading ? const LinearProgressIndicator() : null,
    );
  }
}
