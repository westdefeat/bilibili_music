import 'package:bilibili_music/minicontroller.dart';
import 'package:bilibili_music/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../controllers/home_page_notifier.dart';

HomePage homePage = HomePage();

class HomePage extends ConsumerWidget {
  HomePage({
    super.key,
  });
  
  final List<String> items = [];
  final  bool isLoading = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homePageState = ref.watch(homePageProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 16.0),

                // Row of Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: () {}, child: Text('Button 1')),
                    ElevatedButton(onPressed: () {}, child: Text('Button 2')),
                    ElevatedButton(onPressed: () {}, child: Text('Button 3')),
                    ElevatedButton(onPressed: () {}, child: Text('Button 4')),
                  ],
                ),
                SizedBox(height: 16.0),

                // First Horizontal ListView
                Container(
                  height: 100.0, // Set a fixed height for the ListView
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100.0,
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              color: Colors.blue,
                              child: Center(child: Text(items[index])),
                            );
                          },
                        ),
                ),
                SizedBox(height: 16.0),

                // Second Horizontal ListView
                Container(
                  height: 100.0, // Set a fixed height for the ListView
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100.0,
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              color: Colors.green,
                              child: Center(child: Text(items[index])),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (homePageState.showMiniController)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: miniControllerWidget,
            )
        ]));
  }




}
