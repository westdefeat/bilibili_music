import 'package:bilibili_music/minicontroller.dart';
import 'package:bilibili_music/models/BilibiliListItem.dart';
import 'package:bilibili_music/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'dart:convert';

import '../controllers/home_page_notifier.dart';
import '../favor_page.dart';

HomePage homePage = HomePage();

class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearchSubmitted(String query) {
    // Print the search query to the console
    // Navigate to SearchResultsPage with the search query
    if (!searchMediaList.containsKey(query)) {
      BilibiliListItem item = BilibiliListItem(title: '搜索结果 :${query}', media_ids: query);
      searchMediaList[query] = SearchMediaListPage(
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
        title: Text('Home Page'),
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
                  prefixIcon: Icon(Icons.search),
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