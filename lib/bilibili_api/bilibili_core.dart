import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String baseUrl = 'api.bilibili.com';
  static final Map<String, String> headers = {
    'accept': 'application/json, text/plain, */*',
    'accept-language': 'en,zh-CN;q=0.9,zh;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'cookie': 'SESSDATA=d5d8f95f%2C1736941924%2Ca6a3f%2A71CjAhfDrdKTIBF5MXr930fxCoN-vN3l1EPsv8JNRs12bOv87Fgs-4L6TTo68AsRm-_B0SVlpid0dkbnZLTGZYYnpJOWxyR001SVZtMzBGdThQRkZXODc1aEFjMGk5Skk1aEFaXzBER3IxdVgxY0lWUlZxS3BFRjlqYW9oY2otTWUwbExXMEgxZGVnIIEC',
    'origin': 'https://space.bilibili.com',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0',
    'referer': 'https://www.bilibili.com',
    "Access-Control-Allow-Origin": "*", // Required for CORS support to work
  "Access-Control-Allow-Credentials": "true", // Required for cookies, authorization headers with HTTPS
  "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
  };
  static const String csrfToken = 'c25c35d6c14f3eb0f1477e9f9410c2d8';
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
