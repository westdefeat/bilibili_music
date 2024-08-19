import 'dart:convert';
import 'dart:io';
import 'bilibili_core.dart';

String getCurrentFunctionName() {
  try {
    throw Exception();
  } catch (e, stackTrace) {
    // Parse the stack trace to extract the function name
    var stackTraceLines = stackTrace.toString().split('\n');
    if (stackTraceLines.length > 1) {
      var functionNameLine = stackTraceLines[1];
      var functionNameMatch =
          RegExp(r'#1\s+(.+?)\s').firstMatch(functionNameLine);
      if (functionNameMatch != null) {
        return functionNameMatch.group(1)?.split('.').last ?? 'unknown';
      }
    }
  }
  return 'unknown';
}

Future<void> printResponse(Map<String, dynamic>? data, String fileName) async {
  var jsonEncoder = const JsonEncoder.withIndent(
      '  '); // adjust the indent level to your liking
  var formattedJson = jsonEncoder.convert(data);

  // print(formattedJson);
  // Get the directory to save the file
  final directory =
      Directory('C:\\Users\\37686\\source\\bilibili_music\\assets');
  final file = File('${directory.path}/$fileName');

  // Write the formatted JSON to the file
  await file.writeAsString(formattedJson);

  // print('JSON saved to ${file.path}');
}

Future<dynamic> fetchUserInfo() async {
  var queryParams = {
    'mid': '57164044',
    'photo': 'true',
  };

  var data =
      await requestBilibili(HttpMethod.get, ApiEndpoints.userInfo, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
    // var name = data['data']['card']['name'];
    // print('User name: $name');
    return data;
  }
  return data;
}

Future<dynamic> fetchFavList() async {
  var queryParams = {
    'up_mid': '57164044',
  };
  var data =
      await requestBilibili(HttpMethod.get, ApiEndpoints.favList, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> fetchFavInfo(String mediaId) async {
  var queryParams = {
    'media_id': mediaId,
  };
  var data =
      await requestBilibili(HttpMethod.get, ApiEndpoints.favInfo, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> createFav(String title, String? intro, int privacy) async {
  var queryParams = {
    'title': title,
    'intro': intro.toString(),
    'privacy': '0',
    'cover':
        'https://i0.hdslb.com/bfs/space/cb1c3ef50e22b6096fde67febe863494caefebad.png',
    'csrf': ApiConfig.csrfToken,
  };
  var data = await requestBilibili(
      HttpMethod.post, ApiEndpoints.createFav, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  // print(data);
  return data;
}

// 3170798444
Future<dynamic> renameFav(
    String mediaId, String renamedTitle, String? intro, int? privacy) async {
  var queryParams = {
    "media_id": mediaId,
    "title": renamedTitle,
    "intro": intro.toString(),
    "privacy": privacy.toString(),
    "cover": "",
    'csrf': ApiConfig.csrfToken,
  };
  var data = await requestBilibili(
      HttpMethod.post, ApiEndpoints.createFav, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

// url = "https://api.bilibili.com/x/v3/fav/folder/del"
// data = {
//     "media_ids": "3221643544",
//     "csrf": "8b4aa10b9294917351a63750120133df"
// }

// 3170798444
Future<dynamic> removeFav(String mediaIds) async {
  var queryParams = {
    "media_ids": mediaIds,
    'csrf': ApiConfig.csrfToken,
  };
  var data = await requestBilibili(
      HttpMethod.post, ApiEndpoints.removeFav, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> isFavoured(String aid) async {
  var queryParams = {
    "aid": aid,
  };
  var data = await requestBilibili(
      HttpMethod.get, ApiEndpoints.mediaFavoured, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> modifyFav(String rid,
    {String addMediaIds = '', String delMediaIds = ''}) async {
  var queryParams = {
    "rid": rid,
    "type": "2",
    "add_media_ids": addMediaIds,
    "del_media_ids": delMediaIds,
    "csrf": ApiConfig.csrfToken,
  };
  var data = await requestBilibili(
      HttpMethod.post, ApiEndpoints.modifyFav, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> removeBatchFromFav(String mediaId, String resources) async {
  var queryParams = {
    "resources": resources,
    "media_id": mediaId,
    "csrf": ApiConfig.csrfToken,
  };
  var data = await requestBilibili(
      HttpMethod.post, ApiEndpoints.delbatchFromFav, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> getFavouredMediaList(String mediaId,
    {int? pageNumber = 1, int? pageSize = 20}) async {
  var queryParams = {
    "media_id": mediaId.toString(),
    "platform": "web",
    "pn": pageNumber.toString(),
    "ps": pageSize.toString(),
  };
  var data = await requestBilibili(
      HttpMethod.get, ApiEndpoints.favouredMediaList, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  // print(data);
  return data;
}

Future<dynamic> getFavouredMediaIDs(String mediaId) async {
  var queryParams = {
    "media_id": mediaId.toString(),
    "platform": "web",
  };
  var data = await requestBilibili(
      HttpMethod.get, ApiEndpoints.favouredMediaIds, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> getPageList(String bvid) async {
  var queryParams = {
    "bvid": bvid.toString(),
  };
  var data =
      await requestBilibili(HttpMethod.get, ApiEndpoints.pagelist, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> getMediaBrief(String bvid) async {
  var queryParams = {
    "bvid": bvid.toString(),
  };
  var data = await requestBilibili(
      HttpMethod.get, ApiEndpoints.mediaBrief, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> getPlayUrl(String bvid, String cid,
    {String qn = "112", String fnval = "336"}) async {
  var queryParams = {
    "bvid": bvid,
    "cid": cid,
    "qn": qn,
    "fnval": fnval,
  };
  var data =
      await requestBilibili(HttpMethod.get, ApiEndpoints.playUrl, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

Future<dynamic> getSearchResults(String keyword,
    {int? page = 1, String? searchType = 'video'}) async {
  var queryParams = {
    "keyword": keyword,
    "search_type": searchType.toString(),
    "page": page.toString()
  };
  var data = await requestBilibili(
      HttpMethod.get, ApiEndpoints.classifiedSearch, queryParams);
  if (data != null) {
    printResponse(data, '${getCurrentFunctionName()}.json');
  }
  return data;
}

void main() async {
  // fetchUserInfo();
  // fetchFavList();
  // createFav('dart', 'yyyy', 0);
  // renameFav('3221643544', 'dart_renamed', 'yyyy', 0);
  // removeFav('3221643544');
  // modifyFav('806855189', delMediaIds: '2057910644');
  // modifyFav('806855189', addMediaIds: '2057910644');
  // getFavouredMediaList('2057910644', pageNumber: 1);

  // isFavoured('806855189');
  // getFavouredMediaIDs('2057910644');
  // getPageList('BV1cs411v7xr');
  // getMediaBrief('BV1cs411v7xr');
  // getPlayUrl('BV1cs411v7xr', '8177639');
  getSearchResults('鸿雁', page: 1);
}
