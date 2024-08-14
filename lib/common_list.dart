import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'favor_page.dart';
import 'minicontroller.dart';
import 'models/BilibiliListItem.dart';
import 'utils.dart';

class CommonListPage extends ConsumerStatefulWidget {
  final BilibiliListItem selectedItem;
  List<BilibiliListItem> cachedLists;
  Function loadLists;
  void Function(List<BilibiliListItem>, Set<int>)? deleteSelectedItems;
  Function onItemSelected;
  bool firstLoad = true;

  CommonListPage( {required this.selectedItem, required this.cachedLists, required this.loadLists, required this.deleteSelectedItems, required this.onItemSelected}) {
    // if (!cachedLists.containsKey(selectedItem.media_ids)) {
    //   cachedLists[selectedItem.media_ids] = [];
    // }
  }

  @override
  CommonListPageState createState() => CommonListPageState();
}

class CommonListPageState extends ConsumerState<CommonListPage> {
  bool _loading = false;
  int _page = 1;
  bool isSelectionMode = false;
  Set<int> selectedIndices = {};
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.firstLoad)
      widget.loadLists(cachedLists: widget.cachedLists, initialize: true);
    setState(() {
      _loading = false;
    });
    _focusNode.requestFocus();
  }

  void toggleSelectionMode(int index) {
    print("ttoggleSelectionModeo");
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
    final miniControllerNotifier = ref.watch(miniControllerProvider);



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
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // Add your onPressed code here!
                      print('Add button pressed');
                    },
                  ),
                  if (isSelectionMode)
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      widget.deleteSelectedItems!(widget.cachedLists, selectedIndices);
                      // Add your onPressed code here!
                      print('delete button pressed');
                    },
                  ),
                  if (isSelectionMode)
                  IconButton(
                    icon: Icon(Icons.undo),
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
                  widget.cachedLists.isEmpty && widget.selectedItem.mediaCount != 0
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
                              return ListTileWithImage(
                                title: widget.cachedLists[index].title,
                                intro: widget.cachedLists[index].intro,
                                coverUrl: widget.cachedLists[index].coverUrl,
                                onTap: () => {
                                  if (isSelectionMode)
                                    {toggleSelectionMode(index)}
                                  else
                                    {
                                      widget.onItemSelected(context, widget.cachedLists[index])
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
                  
                  if (miniControllerNotifier.isPlaying)
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


