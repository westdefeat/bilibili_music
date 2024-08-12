
class BiliListItem {
  final String title;
  final String coverUrl;
  final String intro;
  int mediaCount;
  // ignore: non_constant_identifier_names
  final String media_ids; // fav id
  final String id; // video id
  final String type; // video id
  final String bvid; // bv id

  BiliListItem(
      {required this.title,
      this.coverUrl = '',
      this.intro = '',
      this.mediaCount = 0,
      // ignore: non_constant_identifier_names
      this.media_ids = '',
      this.id = '',
      this.type = '2',
      this.bvid = ''});
}

