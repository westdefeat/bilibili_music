

// class FavorPage extends StatefulWidget {
//   final String title;

//   const FavorPage({
//     super.key,
//     required this.title,
//   });

//   @override
//   State<FavorPage> createState() => _FavorPageState();
// }

// class _FavorPageState extends State<FavorPage> {
//   bool firstLoad = true;
//   bool isSelectionMode = false;
//   List<BilibiliListItem> _cachedItems = [];
//   Set<int> selectedIndices = {};
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _introController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   final PageStorageBucket _bucket = PageStorageBucket();
//   @override
//   void initState() {
//     loadJson();
//     super.initState();
//     // Print debug information here
//     _focusNode.requestFocus();
//   }

//   Future<List<BilibiliListItem>> loadJson() async {
//     if (firstLoad) {
//       firstLoad = false;

//       dynamic data = await fetchFavList();
//       List<dynamic> dataList = data['data']['list'];
//       List<BilibiliListItem> items = [];
//       for (var jsonItem in dataList) {
//         String id = jsonItem['id'].toString();
//         dynamic detailJson =
//             await fetchFavInfo(id); // load detail JSON for each item

//         BilibiliListItem item = BilibiliListItem(
//             title: jsonItem['title'],
//             coverUrl: detailJson['data']['cover'],
//             intro: detailJson['data']['intro'],
//             mediaCount: detailJson['data']['media_count'],
//             media_ids: id);

//         items.add(item);
//       }
//       _cachedItems = items;
//     }
//     setState(() {});
//     return _cachedItems;
//   }

//   Future<void> _handleRefresh() async {
//     // Update the list of items and refresh the UI
//     setState(() {
//       isSelectionMode = false;
//       selectedIndices.clear();
//     });
//   }

//   void _showInputDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('输入详情'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: '名称'),
//               ),
//               TextField(
//                 controller: _introController,
//                 decoration: const InputDecoration(labelText: '介绍'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: const Text('取消'),
//               onPressed: () => Navigator.of(dialogContext).pop(),
//             ),
//             TextButton(
//               child: const Text('确认'),
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();
//                 try {
//                   dynamic data = await createFav(
//                       _nameController.text, _introController.text, 0);

//                   if (data != null &&
//                       data['code'] != null &&
//                       data['message'] != null) {
//                     await _handleRefresh();
//                     _showSnackBar(
//                       data['code'] == 0 ? '创建成功！' : data['message'],
//                     );
//                     if (data['code'] == 0) {
//                       print(data);
//                       print(_cachedItems[0].media_ids);
//                       _cachedItems.add(BilibiliListItem(
//                           title: _nameController.text,
//                           intro: _introController.text,
//                           mediaCount: 0,
//                           media_ids: data['data']['id'].toString()));
//                     }
//                   } else {
//                     _showSnackBar('Unknown error');
//                   }
//                 } catch (e) {
//                   _showSnackBar('Error: $e');
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           duration: const Duration(milliseconds: 500),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _introController.dispose();
//     super.dispose();
//   }

//   void toggleSelectionMode(int index) {
//     setState(() {
//       if (isSelectionMode) {
//         if (selectedIndices.contains(index)) {
//           selectedIndices.remove(index);
//         } else {
//           selectedIndices.add(index);
//         }
//         if (selectedIndices.isEmpty) {
//           isSelectionMode = false;
//         }
//       } else {
//         isSelectionMode = true;
//         selectedIndices.add(index);
//       }
//     });
//   }

//   void deleteSelectedItems() async {
//     for (int element in selectedIndices) {
//       await removeFav(_cachedItems[element].media_ids);
//     }
//     for (int index in selectedIndices.toList()
//       ..sort((a, b) => b.compareTo(a))) {
//       _cachedItems.removeAt(index);
//     }
//     selectedIndices.clear();
//     isSelectionMode = false;
//     setState(() {
//       isSelectionMode = false;
//     });
//   }

//   final Map<String, GlobalKey<_DetailedPageState>> _pageStateKeys = {};

//   void _navigateToDetailPage(BuildContext context, BilibiliListItem item) {
//     if (!_pageStateKeys.containsKey(item.media_ids)) {
//       _pageStateKeys[item.media_ids] = GlobalKey<_DetailedPageState>();
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DetailedPage(
//           key: _pageStateKeys[item.media_ids],
//           selectedItem: item,
//         ),
//       ),
//     ).then((result) {
//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // set outer gesture detector, inner gesture detector will take precedence
//     return GestureDetector(
//         onTap: () {
//           isSelectionMode = false;
//           selectedIndices.clear();
//           setState(() {});
//         },
//         child: KeyboardListener(
//             focusNode: _focusNode,
//             onKeyEvent: (KeyEvent event) {
//               if (event is KeyDownEvent &&
//                   event.logicalKey == LogicalKeyboardKey.escape) {
//                 isSelectionMode = false;
//                 selectedIndices.clear();
//                 setState(() {});
//               }
//             },
//             child: Scaffold(
//               appBar: AppBar(
//                 title: Text(widget.title),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.add),
//                     onPressed: () {
//                       // Add your onPressed code here!
//                       print('Add button pressed');
//                     },
//                   ),
//                   if (isSelectionMode)
//                     IconButton(
//                       icon: const Icon(Icons.delete),
//                       onPressed: () {
//                         // Add your onPressed code here!
//                         print('delete button pressed');
//                       },
//                     ),
//                 ],
//               ),
//               body: Stack(
//                 children: [
//                   RefreshIndicator(
//                     onRefresh: _handleRefresh,
//                     child: _cachedItems.isEmpty
//                         ? const Center(child: CircularProgressIndicator())
//                         : ListView.builder(
//                             itemCount: _cachedItems.length,
//                             itemBuilder: (context, index) {
//                               return ListTileWithImage(
//                                 onTap: () => {
//                                   if (isSelectionMode)
//                                     {toggleSelectionMode(index)}
//                                   else
//                                     {
//                                       _navigateToDetailPage(
//                                           context, _cachedItems[index])
//                                     }
//                                 },
//                                 onLongPress: () => toggleSelectionMode(index),
//                                 title: _cachedItems[index].title,
//                                 intro: _cachedItems[index].intro,
//                                 coverUrl: _cachedItems[index].coverUrl,
//                                 isSelected: selectedIndices.contains(index),
//                               );
//                             },
//                           ),
//                   ),
//                   if (isSelectionMode)
//                     Positioned(
//                       bottom: 16,
//                       left: 16,
//                       child: FloatingActionButton(
//                         heroTag: 'btn3',
//                         onPressed: deleteSelectedItems,
//                         backgroundColor: Colors.red,
//                         child: const Icon(Icons.delete),
//                       ),
//                     ),
//                   if (showPlayerController)
//                     Positioned(
//                       left: 0,
//                       right: 0,
//                       bottom: 0,
//                       child: FloatingActionButton(
//                         heroTag: 'deleteSelectedItems',
//                         onPressed: deleteSelectedItems,
//                         backgroundColor: Colors.blueGrey,
//                         child: const MiniPlayerWidget(),
//                       ),
//                     )
//                 ],
//               ),
//               floatingActionButton: isSelectionMode
//                   ? FloatingActionButton(
//                       heroTag: 'undo',
//                       child: const Icon(Icons.undo),
//                       onPressed: () => _handleRefresh(),
//                     )
//                   : FloatingActionButton(
//                       heroTag: 'add',
//                       child: const Icon(Icons.add),
//                       onPressed: () => _showInputDialog(),
//                     ),
//             )));
//   }
// }

// Map<String, List<BilibiliListItem>> detailedPageMediaList = {};
// Map<String, List<BilibiliListItem>> favList = {};

// class DetailedPage extends ConsumerStatefulWidget {
//   final BilibiliListItem selectedItem;

//   DetailedPage({super.key, required this.selectedItem}) {
//     if (!detailedPageMediaList.containsKey(selectedItem.media_ids)) {
//       detailedPageMediaList[selectedItem.media_ids] = [];
//     }
//   }

//   @override
//   _DetailedPageState createState() => _DetailedPageState();
// }

// class _DetailedPageState extends ConsumerState<DetailedPage> {
//   bool _loading = false;
//   int _page = 1;
//   bool firstLoad = true;
//   bool isSelectionMode = false;
//   Set<int> selectedIndices = {};
//   final FocusNode _focusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     bool useCache =
//         detailedPageMediaList[widget.selectedItem.media_ids]!.isNotEmpty;
//     _loadLists(useCache: useCache);
//     _focusNode.requestFocus();
//   }

//   Future<List<BilibiliListItem>> _loadLists({bool useCache = false}) async {
//     List<BilibiliListItem> cachedItems =
//         detailedPageMediaList[widget.selectedItem.media_ids]!;
//     if (useCache) {
//       setState(() {
//         _loading = false;
//       });
//       return cachedItems;
//     }
//     setState(() {
//       if (widget.selectedItem.mediaCount != 0) {
//         _loading = true;
//       }
//     });

//     dynamic jsonData = await getFavouredMediaList(widget.selectedItem.media_ids,
//         pageNumber: _page++);
//     List<dynamic> dataList = jsonData['data']['medias'] ?? [];

//     for (var jsonItem in dataList) {
//       BilibiliListItem item = BilibiliListItem(
//         title: jsonItem['title'],
//         coverUrl: jsonItem['cover'],
//         intro: jsonItem['intro'],
//         id: jsonItem['id'].toString(),
//         type: jsonItem['type'].toString(),
//         bvid: jsonItem['bvid'].toString(),
//       );

//       cachedItems.add(item);
//     }

//     setState(() {
//       _loading = false;
//     });
//     return cachedItems;
//   }

//   void toggleSelectionMode(int index) {
//     setState(() {
//       if (isSelectionMode) {
//         if (selectedIndices.contains(index)) {
//           selectedIndices.remove(index);
//         } else {
//           selectedIndices.add(index);
//         }
//         if (selectedIndices.isEmpty) {
//           isSelectionMode = false;
//         }
//       } else {
//         isSelectionMode = true;
//         selectedIndices.add(index);
//       }
//     });
//   }

//   void deleteSelectedItems() async {
//     List<BilibiliListItem> cachedItems =
//         detailedPageMediaList[widget.selectedItem.media_ids]!;

//     dynamic resources = 'resources=';
//     for (int element in selectedIndices) {
//       resources += '${cachedItems[element].id}:${cachedItems[element].type},';
//     }

//     await removeBatchFromFav(widget.selectedItem.media_ids, resources);
//     for (int index in selectedIndices.toList()
//       ..sort((a, b) => b.compareTo(a))) {
//       cachedItems.removeAt(index);
//     }
//     widget.selectedItem.mediaCount -= selectedIndices.length;
//     selectedIndices.clear();
//     isSelectionMode = false;
//     setState(() {
//       isSelectionMode = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<BilibiliListItem> cachedItems =
//         detailedPageMediaList[widget.selectedItem.media_ids]!;
//     return GestureDetector(
//         onTap: () {
//           isSelectionMode = false;
//           selectedIndices.clear();
//           setState(() {});
//         },
//         child: KeyboardListener(
//             focusNode: _focusNode,
//             onKeyEvent: (KeyEvent event) {
//               if (event is KeyDownEvent &&
//                   event.logicalKey == LogicalKeyboardKey.escape) {
//                 isSelectionMode = false;
//                 selectedIndices.clear();
//                 setState(() {});
//               }
//             },
//             child: Scaffold(
//               appBar: AppBar(
//                 title: Text(widget.selectedItem.title),
//               ),
//               body: Stack(
//                 children: [
//                   cachedItems.isEmpty && widget.selectedItem.mediaCount != 0
//                       ? const Center(
//                           child: CircularProgressIndicator(),
//                         )
//                       : NotificationListener<ScrollNotification>(
//                           onNotification: (ScrollNotification notification) {
//                             if (notification is ScrollEndNotification &&
//                                 notification.metrics.extentAfter == 0 &&
//                                 cachedItems.length <
//                                     widget.selectedItem.mediaCount) {
//                               _loadLists();
//                             }
//                             return true;
//                           },
//                           child: ListView.builder(
//                             key: PageStorageKey(widget.selectedItem.media_ids),
//                             itemCount: cachedItems.length,
//                             itemBuilder: (context, index) {
//                               return ListTileWithImage(
//                                 title: cachedItems[index].title,
//                                 intro: cachedItems[index].intro,
//                                 coverUrl: cachedItems[index].coverUrl,
//                                 onTap: () => {
//                                   if (isSelectionMode)
//                                     {toggleSelectionMode(index)}
//                                   else
//                                     {
//                                       ref
//                                           .read(miniControllerProvider.notifier)
//                                           .startPlay(cachedItems[index]),
//                                       setState(() {
//                                         showPlayerController = true;
//                                       }),
//                                     }
//                                 },
//                                 onLongPress: () => toggleSelectionMode(index),
//                                 isSelected: selectedIndices.contains(index),
//                               );
//                             },
//                           ),
//                         ),
//                   if (isSelectionMode)
//                     Positioned(
//                       bottom: 16,
//                       left: 16,
//                       child: FloatingActionButton(
//                         heroTag: "btn2",
//                         onPressed: deleteSelectedItems,
//                         backgroundColor: Colors.red,
//                         child: const Icon(Icons.delete),
//                       ),
//                     ),
//                   if (isSelectionMode)
//                     Positioned(
//                       bottom: 16,
//                       right: 16,
//                       child: FloatingActionButton(
//                         heroTag: "btn1",
//                         onPressed: deleteSelectedItems,
//                         backgroundColor: Colors.blueGrey,
//                         child: const Icon(Icons.add),
//                       ),
//                     ),
//                   if (showPlayerController)
//                     const Positioned(
//                       left: 0,
//                       right: 0,
//                       bottom: 0,
//                       child: miniControllerWidget,
//                     )
//                 ],
//               ),
//               bottomNavigationBar:
//                   _loading ? const LinearProgressIndicator() : null,
//             )));
//   }
// }
