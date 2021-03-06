import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutterapp/member_data.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlogViewModel extends ChangeNotifier {
  final MemeberData _member = MemeberData();
  WebViewController webViewController;

  final int index;
  var streamController = StreamController<List<String>>();

  Stream<List<String>> get bloglPath => streamController.stream;

  List<String> blogThumbnailPath = List<String>();
  List<String> blogTitle = List<String>();
  List<String> blogDate = List<String>();
  List<String> blogTxt = List<String>();

  int getBlogNum() => blogThumbnailPath.length;

  String getBlogThumbnailPath(int index) => blogThumbnailPath[index];

  String getBlogTitle(int index) => blogTitle[index];

  String getBlogDate(int index) => blogDate[index];

  String getBlogTxt(int index) => blogTxt[index];

  String getMemberName() => _member.memberName[index];

  BlogViewModel({int this.index}) : assert(index != null) {
    ScreperTest();
  }

  void ScreperTest() async {
    blogThumbnailPath.clear();
    blogTitle.clear();
    blogDate.clear();
    blogTxt.clear();

    final String baseURL = "http://blog.nanabunnonijyuuni.com";
    final webScraper = WebScraper(baseURL);

    //サムネ取得
    if (await webScraper.loadWebPage(_member.memberBlog[index]
        .replaceFirst("http://blog.nanabunnonijyuuni.com/", '/'))) {
      final List<Map<String, dynamic>> elements =
          webScraper.getElement('div.blog-list__thumb > img', ['style']);
      elements.forEach((element) {
        blogThumbnailPath.add(baseURL +
            PerseBlogbThumbnailPath(element['attributes']['style'].toString()));
      });

      //タイトル取得
      elements.clear();
      elements.addAll(
          webScraper.getElement('div.blog-list__title > p.title', ['title']));
      elements.forEach((element) {
        blogTitle.add(element['title'].toString());
      });

      //ライター取得
      elements.clear();
      elements.addAll(
          webScraper.getElement('div.blog-list__title > p.date', ['date']));
      elements.forEach((element) {
        blogDate.add(element['title'].toString());
      });

      //テキスト取得
      elements.clear();
      elements
          .addAll(webScraper.getElement('div.blog-list__txt > p.txt', ['txt']));
      elements.forEach((element) {
        blogTxt.add(element['title'].toString());
      });

      streamController.sink.add(blogThumbnailPath);
    }
  }
}

String PerseBlogbThumbnailPath(String data) {
  //　最初のいらない文字列を置換する 空文字 ( To == '' )で置換できないため、一文字ずらしている
  data = data.replaceFirst("background-image:url(/", '/');
  //末尾の2文字もいらないので切り出し
  return data.substring(0, data.length - 2);
}

//http://blog.nanabunnonijyuuni.com/images/30/84d/8f51827fd9070f52aee6d024ef3ee.jpg
//"style" -> "background-image:url(/images/30/ca2/e0742c78bb90416d3e4277e0447cb.jpg);"
//"style" -> "background-image:url(/files/4/nanabunnonijyuuni/pc/img/blog/noimage.jpg);"
// files/4/nanabunnonijyuuni/pc/img/blog/list_thumb.png
