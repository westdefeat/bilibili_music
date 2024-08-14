
import 'package:bilibili_music/models/BilibiliListItem.dart';

class BilibiliListModel {
  bool isSelectionMode;
  Set<int> selectedIndices = {};
  List<BilibiliListItem> mediaLists = [];
  Function? loadItems;
  Function? deleteItem;
  int pageNumber;
  BilibiliListItem currentItem;

  BilibiliListModel({ required this.loadItems, required this.deleteItem, required this.selectedIndices, required this.isSelectionMode, required this.mediaLists, required this.pageNumber, required this.currentItem});

  BilibiliListModel copyWith({bool? isSelectionMode, Set<int>? selectedIndices, List<BilibiliListItem>? mediaLists, int? pageNumber, BilibiliListItem? currentItem}) {
    return BilibiliListModel(
      loadItems: loadItems, 
      deleteItem: deleteItem, 
      selectedIndices: selectedIndices?? this.selectedIndices, 
      mediaLists: mediaLists?? this.mediaLists, 
      isSelectionMode: isSelectionMode?? this.isSelectionMode,
      pageNumber: pageNumber?? this.pageNumber,
      currentItem: currentItem?? this.currentItem
    );
  }
}