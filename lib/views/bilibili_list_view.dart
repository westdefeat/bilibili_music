

import 'package:bilibili_music/controllers/bilibili_list_controller.dart';
import 'package:bilibili_music/ListTileWithImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/BilibiliListItem.dart';
import '../models/bilibili_list_model.dart';

class BilibiliListView extends ConsumerWidget {
  late final BilibiliListItem selectedItem;
  String listName = '';
    final FocusNode _focusNode = FocusNode();
  
  BilibiliListView({required this.listName}) {
    StateNotifierProvider<BilibiliListNotifier, BilibiliListModel> provider = mediaListProviders[listName]!;
    print("create view");

  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("called build");
    StateNotifierProvider<BilibiliListNotifier, BilibiliListModel> provider = mediaListProviders[listName]!;
    final listController = ref.watch(provider);
    ref.read(provider.notifier).updateSelectionMode(false);
    print("called build2");

    return GestureDetector(
        onTap: () {
          ref.read(provider.notifier).updateSelectionMode(false);
          print("dddddddddd");

        },
        child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                  ref.read(provider.notifier).updateSelectionMode(false);
                  print("xxxxx");
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(listController.currentItem.title),
              ),
              body: Stack(
                children: [
                  listController.mediaLists.isEmpty && listController.currentItem.mediaCount != 0
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            if (notification is ScrollEndNotification &&
                                notification.metrics.extentAfter == 0 &&
                                listController.mediaLists.length <
                                    listController.currentItem.mediaCount) {
                              ref.read(provider.notifier).addMoreItems();
                            }
                            return true;
                          },
                          child: ListView.builder(
                            key: PageStorageKey(listController.currentItem.media_ids),
                            itemCount: listController.mediaLists.length,
                            itemBuilder: (context, index) {
                              return ListTileWithImage(
                                title: listController.mediaLists[index].title,
                                intro: listController.mediaLists[index].intro,
                                coverUrl: listController.mediaLists[index].coverUrl,
                                onTap: () => {
                                  print("item on tap not implemented!")
                                  // if (isSelectionMode)
                                  //   {toggleSelectionMode(index)}
                                  // else
                                  //   {
                                  //     ref
                                  //         .read(miniControllerProvider.notifier)
                                  //         .startPlay(cachedItems[index]),
                                  //     ref.read(homePageProvider.notifier).updateMedia(true),
                                  //     setState(() {
                                  //       showPlayerController = true;
                                  //     }),
                                  //   }
                                },
                                onLongPress: () => ref.read(provider.notifier).toggleSelectionMode(index),
                                isSelected: listController.selectedIndices.contains(index),
                              );
                            },
                          ),
                        ),
                  // if (isSelectionMode)
                  //   Positioned(
                  //     bottom: 16,
                  //     left: 16,
                  //     child: FloatingActionButton(
                  //       heroTag: "btn2",
                  //       onPressed: deleteSelectedItems,
                  //       backgroundColor: Colors.red,
                  //       child: const Icon(Icons.delete),
                  //     ),
                  //   ),
                  // if (isSelectionMode)
                  //   Positioned(
                  //     bottom: 16,
                  //     right: 16,
                  //     child: FloatingActionButton(
                  //       heroTag: "btn1",
                  //       onPressed: deleteSelectedItems,
                  //       backgroundColor: Colors.blueGrey,
                  //       child: const Icon(Icons.add),
                  //     ),
                  //   ),
                  // if (showPlayerController)
                  //   const Positioned(
                  //     left: 0,
                  //     right: 0,
                  //     bottom: 0,
                  //     child: miniControllerWidget,
                  //   )
                ],
              ),
              bottomNavigationBar:const LinearProgressIndicator()
                  // _loading ? const LinearProgressIndicator() : null,
            )));
  }
}

BilibiliListView favListView = BilibiliListView(listName: 'fav');