import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://upos-sz-mirrorcos.bilivideo.com/upgcxcode/39/76/8177639/8177639_da3-1-30280.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M=&uipk=5&nbs=1&deadline=1721661914&gen=playurlv2&os=cosbv&oi=1971403001&trid=cd598820915e4d31883775e68799dafeu&mid=57164044&platform=pc&og=cos&upsig=7256d0356e48d224c80ff7bd5090757e&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,mid,platform,og&bvc=vod&nettype=0&orderid=0,3&buvid=&build=0&f=u_0_0&agrr=0&bw=16036&logo=80000000');

  final headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0',
    'Accept-Encoding': 'identity',
    'sec-ch-ua': '"Not/A)Brand";v="8", "Chromium";v="126", "Microsoft Edge";v="126"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'origin': 'https://www.bilibili.com',
    'sec-fetch-site': 'cross-site',
    'sec-fetch-mode': 'cors',
    'sec-fetch-dest': 'empty',
    'referer': 'https://www.bilibili.com/video/BV1US411A7CK/?spm_id_from=333.1007.tianma.1-1-1.click&vd_source=081a60dcd4469f1c2182a5084d047712',
    'accept-language': 'en,zh-CN;q=0.9,zh;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'range': 'bytes=0-2574829',
    'if-range': '"fd09710199a0650c52a6f90d8bdaabdb"',
    'priority': 'u=1, i'
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 206 || response.statusCode == 200) {
    final file = File('downloaded_video.m4s');
    await file.writeAsBytes(response.bodyBytes);
    print('File downloaded successfully.');
  } else {
    print('Failed to download file: ${response.statusCode}');
  }
}
