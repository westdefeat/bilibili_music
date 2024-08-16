import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String baseUrl = 'api.bilibili.com';
  static final Map<String, String> headers = {
    'accept': 'application/json, text/plain, */*',
    'accept-language': 'en,zh-CN;q=0.9,zh;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'cookie': 'SESSDATA=48f2db3d%2C1738201895%2Ce1817%2A81CjA7oG1PyORwopFpibq05nQ2UD80GpAugHt4g-DeV_4WMvb3l0t5pNJo7q2_rIm9RfgSVnpHNkZiT3FrS1ltYVN2djhCaVdWRnkzekNVZU9QZFlsdUNGVkE1WEdteDlxRTBKVzBIdl82YjV1NWExbXF3MW8wVUhDcE40Ml9ZWTJpR1dPMnpoblJnIIEC',
    'origin': 'https://space.bilibili.com',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0',
    'referer': 'https://www.bilibili.com',
    "Access-Control-Allow-Origin": "*", // Required for CORS support to work
  "Access-Control-Allow-Credentials": "true", // Required for cookies, authorization headers with HTTPS
  "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
  };
  static const String csrfToken = '27c226dbdb107119d9e65830ac4e7d48';
}


class ApiEndpoints {
  static const String userInfo = '/x/web-interface/card';
  static const String favList = '/x/v3/fav/folder/created/list-all';
  static const String favInfo = '/x/v3/fav/folder/info';

  static const String mediaFavoured = '/x/v2/fav/video/favoured';
  static const String favouredMediaList = '/x/v3/fav/resource/list';
  static const String favouredMediaIds = '/x/v3/fav/resource/ids';
  static const String pagelist = '/x/player/pagelist';
  static const String mediaBrief = '/x/web-interface/view';
  static const String playUrl = '/x/player/playurl';

  static const String createFav = '/x/v3/fav/folder/add';
  static const String renameFav = '/x/v3/fav/folder/edit';
  static const String removeFav = '/x/v3/fav/folder/del';
  static const String modifyFav = '/medialist/gateway/coll/resource/deal';
  static const String delbatchFromFav = '/x/v3/fav/resource/batch-del';
  static const String comprehensiveSearch = '/x/web-interface/wbi/search/all/v2';
  static const String classifiedSearch = '/x/web-interface/wbi/search/type';
  // static const String fetchPlaylists = '/path/to/playlist/endpoint';
}

enum HttpMethod {
  get,
  post,
}



Future<Map<String, dynamic>?> requestBilibili(HttpMethod methodType, String endpoint, Map<String, String> queryParams) async {
  var url = Uri.https(ApiConfig.baseUrl, endpoint, queryParams);
  Map<String, String> headers = {
    ...ApiConfig.headers,
  };
  http.Response response;
  if (methodType == HttpMethod.get) {
    
   response = await http.get(url, headers: headers);

  }
  else if (methodType == HttpMethod.post) {
   response = await http.post(url, headers: headers);
  }
  else {
    throw Exception('request method type error!');
  }
  if (response.statusCode == 200) {
    var decodedResponse = jsonDecode(response.body);
    return decodedResponse;
  } else {
    print('Request failed with status: ${response.statusCode}.');
    return null;
  }
}
