import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import '../model/news_list_model.dart';

class EntertainmentProvider with ChangeNotifier {
  List<NewsListModel> abpLive = [];
  List<NewsListModel> bollywoodHungama = [];
  List<NewsListModel> pinkvilla = [];
  List<NewsListModel> latestNews = [];
  List<NewsListModel> newsToUpload = [];

  String entertainmentLoc = 'news/entertainment/entertainment_news';

  int latestNewsNum = 0;

  Future<void> extractFromPinkVilla() async {
    final url = Uri.parse('https://www.pinkvilla.com/latest');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        var element = document.getElementsByClassName('view-content')[0];

        for (int i = 0; i < 20; i++) {
          if (i < 7 || i == 11 || i == 12) {
            continue;
          }
          var newsLink = element.children[i]
              .getElementsByTagName('a')
              .where((element) => element.attributes.containsKey('href'))
              .map((e) => e.attributes['href'])
              .toList();

          var imageUrl = element.children[i]
              .getElementsByTagName('img')
              .where((element) => element.attributes.containsKey('data-src'))
              .map((e) => e.attributes['data-src'])
              .toList();

          var newsHeadLine =
              element.children[i].getElementsByClassName('heading')[0];
          print(newsHeadLine.text.toString());

          pinkvilla.add(NewsListModel(
              listItemImageUrl: imageUrl[0].toString(),
              listItemHeadLine: newsHeadLine.text.toString(),
              listItemNewsLink: newsLink[0].toString(),
              isBanner: false,
              date: DateTime.now().toString(),
              source: 'Pinkvilla'));
        }
      } catch (e) {
        print('Error Getting Data from Pinkvilla');
      }
    } else {
      print('Error Getting Data from Pinkvilla');
    }
  }

  Future<void> extractFromBollywoodHungama() async {

    var sourceUrl = 'https://www.bollywoodhungama.com/features/';
    final response = await http.Client().get(Uri.parse(sourceUrl));
    if (response.statusCode == 200) {
      var doc = parser
          .parse(response.body)
          .getElementsByClassName('bh-cm-boxes bh-box-articles clearfix')[0];
      try {
        for (int i = 0; i < 12; i++) {
          //Get News Link------------------
          var newsLink = doc.children[i].children[1]
              .getElementsByTagName('a')
              .where((element) => element.attributes.containsKey('href'))
              .map((e) => e.attributes['href']).toList();

          //Get News Image-------------------
          var newsImage = doc.children[i].children[0].children[0]
              .getElementsByTagName('img')
              .where((element) => element.attributes.containsKey('src'))
              .map((e) => e.attributes['src']).toList();

          //Get Headline
          var newsHeadLine = doc.children[i].children[1];
            bollywoodHungama.add(NewsListModel(
                listItemImageUrl: newsImage[0].toString(),
                listItemHeadLine: newsHeadLine.text.toString().trim(),
                listItemNewsLink: newsLink[0].toString(),
                isBanner: false,
                date: DateTime.now().toString(),
                source: 'Bollywood Hungama'));
          }
      } catch (e) {
        print('ERROR IN FETCHING DATA');
      }
    } else {
      print('Could Not connect to the URL');
    }
  }

  Future<void> extractFromABPLive() async {
    final url = Uri.parse('https://news.abplive.com/entertainment');
    final response = await http.get(url);
    if(response.statusCode == 200) {
      try {
        dom.Document document = parser.parse(response.body);
        final element = document.getElementsByClassName('other_news');

        List<String?> newsLink = element
            .map((element) =>
        element.getElementsByTagName('a')[0].attributes['href'])
            .toList();
        List<String?> newsHeadLine = element
            .map((element) =>
        element.getElementsByTagName('a')[0].attributes['title'])
            .toList();
        List<String?> imageUrl = element
            .map((element) =>
        element
            .getElementsByClassName('img4x3')[0]
            .getElementsByTagName('img')[0]
            .attributes['data-src'])
            .toList();

        for (int i = 0; i < newsHeadLine.length; i++) {
          abpLive.add(NewsListModel(
              listItemImageUrl: imageUrl[i]!,
              listItemHeadLine: newsHeadLine[i]!.trim(),
              listItemNewsLink: newsLink[i]!,
              isBanner: false,
              date: DateTime.now().toString(),
              source: "ABP Live"));
        }

      } catch (error) {
        print("Error Getting Data");
        //throw error;
      }
    }else{
      print("Error Connecting to the URL");
    }
  }

  Future<int> getlatestnewsNum(String documentLoc) async {
    var num;
    await FirebaseFirestore.instance
        .collection(documentLoc).orderBy('newsNumber', descending: true).limit(
        1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        num = doc['newsNumber'];
      });
    });
    return num;
  }


  Future<void> uploadNews(List<NewsListModel> newsModel, String documentLoc) async {
    latestNewsNum = await getlatestnewsNum(documentLoc);
    for (int i = 0; i < newsModel.length; i++) {
      latestNewsNum++;
      final docToCreate = FirebaseFirestore.instance.collection(documentLoc)
          .doc();
      newsModel[i].isBanner = false;
      newsModel[i].newsNumber = latestNewsNum;
      await docToCreate.set(newsModel[i].toJson());
    }
    newsToUpload.clear();
  }



  getNews() async {
    clear();
    await extractFromPinkVilla();
    await extractFromBollywoodHungama();
    await extractFromABPLive();
    //TODO execute scrape script
    latestNews = abpLive + bollywoodHungama + pinkvilla;
  }

  clear() {
    abpLive.clear();
    bollywoodHungama.clear();
    pinkvilla.clear();
  }

  addToList(NewsListModel newsListModel) {
    newsToUpload.add(newsListModel);
    notifyListeners();
  }

  removeFromList(NewsListModel newsListModel) {
    newsToUpload.remove(newsListModel);
    notifyListeners();
  }
}
