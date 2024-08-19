import 'package:bilibili_music/models/bilibili_list_item_model.dart';
import 'package:bilibili_music/views/mini_player_widget.dart';
import 'package:bilibili_music/views/search_media_list_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

HomePageWidget homePage = const HomePageWidget();

class HomePageWidget extends ConsumerStatefulWidget {
  const HomePageWidget({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePageWidget> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearchSubmitted(String query) {
    // Print the search query to the console
    // Navigate to SearchResultsPage with the search query
    if (!searchMediaList.containsKey(query)) {
      BilibiliListItem item =
          BilibiliListItem(title: '搜索结果 :$query', media_ids: query);
      searchMediaList[query] = SearchMediaListPageWidget(
        selectedItem: item,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => searchMediaList[query]!
          // builder: (context) =>  FavMediaListPage(selectedItem: item,)
          ),
    ).then((result) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Stack(
        children: [
          // The search bar at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onSubmitted: _onSearchSubmitted,
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: miniControllerWidget,
          )
          // Other widgets can be positioned below
          // Positioned or other widgets can go here
        ],
      ),
    );
  }
}
