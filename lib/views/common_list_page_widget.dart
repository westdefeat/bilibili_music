import 'package:bilibili_music/models/bilibili_list_item_model.dart';
import 'package:bilibili_music/views/list_tile_with_image_widget.dart';
import 'package:bilibili_music/views/mini_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'list_tile_with_image.dart';

int decodeDurationToSeconds(String input) {
  // Check if the input is a pure number (no colon)
  if (RegExp(r'^\d+$').hasMatch(input)) {
    // Convert to integer and return as total seconds
    return int.parse(input);
  }
  // Check if the input contains a colon
  else if (RegExp(r'^\d+:\d+$').hasMatch(input)) {
    // Split the input by colon
    var parts = input.split(':');
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);
    // Calculate total seconds
    return (minutes * 60) + seconds;
  }
  // If the input format is not recognized
  else {
    throw const FormatException('Invalid format');
  }
}

class CommonListPageWidget extends ConsumerStatefulWidget {
  final BilibiliListItem selectedItem;
  List<BilibiliListItem> cachedLists;
  Function loadLists;
  void Function(List<BilibiliListItem>, Set<int>)? deleteSelectedItems;
  Function onItemSelected;
  bool firstLoad = true;

  CommonListPageWidget(
      {super.key,
      required this.selectedItem,
      required this.cachedLists,
      required this.loadLists,
      required this.deleteSelectedItems,
      required this.onItemSelected}) {
    // if (!cachedLists.containsKey(selectedItem.media_ids)) {
    //   cachedLists[selectedItem.media_ids] = [];
    // }
  }

  @override
  CommonListPageState createState() => CommonListPageState();
}

class CommonListPageState extends ConsumerState<CommonListPageWidget> {
  bool _loading = false;
  final int _page = 1;
  bool isSelectionMode = false;
  Set<int> selectedIndices = {};
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.firstLoad) {
      widget.loadLists(cachedLists: widget.cachedLists, initialize: true);
    }
    setState(() {
      _loading = false;
    });
    _focusNode.requestFocus();
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

  @override
  Widget build(BuildContext context) {
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
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.selectedItem.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Add your onPressed code here!
                    },
                  ),
                  if (isSelectionMode)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        widget.deleteSelectedItems!(
                            widget.cachedLists, selectedIndices);
                        // Add your onPressed code here!
                      },
                    ),
                  if (isSelectionMode)
                    IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: () {
                        setState(() {
                          isSelectionMode = false;
                          selectedIndices.clear();
                        });
                      },
                    ),
                ],
              ),
              body: Stack(
                children: [
                  widget.cachedLists.isEmpty &&
                          widget.selectedItem.mediaCount != 0
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            if (notification is ScrollEndNotification &&
                                notification.metrics.extentAfter == 0 &&
                                widget.cachedLists.length <
                                    widget.selectedItem.mediaCount) {
                              widget.loadLists(cachedLists: widget.cachedLists);
                            }
                            return true;
                          },
                          child:
                              // cachedItems.isNotEmpty ?
                              ListView.builder(
                            itemCount: widget.cachedLists.length,
                            itemBuilder: (context, index) {
                              return ListTileWithImageWidget(
                                title: widget.cachedLists[index].title,
                                intro: widget.cachedLists[index].intro,
                                coverUrl: widget.cachedLists[index].coverUrl,
                                onTap: () => {
                                  if (isSelectionMode)
                                    {toggleSelectionMode(index)}
                                  else
                                    {
                                      widget.onItemSelected(
                                          context, widget.cachedLists[index])
                                    }
                                },
                                onLongPress: () => toggleSelectionMode(index),
                                isSelected: selectedIndices.contains(index),
                              );
                            },
                          )
                          // :
                          // Center(child: Text('No items available'))
                          ),

                  // if (miniControllerNotifier.isPlaying)
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: miniControllerWidget,
                  )
                ],
              ),
              bottomNavigationBar:
                  _loading ? const LinearProgressIndicator() : null,
            )));
  }
}
