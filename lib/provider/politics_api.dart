import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import '../model/news_list_model.dart';

class PoliticsProvider with ChangeNotifier {
  List<NewsListModel> ndtv = [];
  List<NewsListModel> hindustanTimes = [];
  List<NewsListModel> theEconomicTimes = [];
  List<NewsListModel> latestNews = [];
  List<NewsListModel> newsToUpload = [];

  int latestNewsNum = 0;

  String politicsLoc = 'news/politics/political_news';

  Future<void> extractFromNDTV() async {
    final url = Uri.parse('https://www.ndtv.com/elections/elections-news');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        final element = document
            .getElementsByClassName(
                'elec14_storylist election14_insidenewslist')[0]
            .getElementsByClassName('storylist_img');

        List<String?> loadLink = element
            .map((element) =>
                element.getElementsByTagName('a')[0].attributes['href'])
            .toList();
        List<String?> loadTitle = element
            .map((element) => element
                .getElementsByTagName('a')[0]
                .getElementsByClassName('img_brd marr10')[0]
                .attributes['alt'])
            .toList();
        List<String?> loadImageUrl = element
            .map((element) => element
                .getElementsByTagName('a')[0]
                .getElementsByClassName('img_brd marr10')[0]
                .attributes['src'])
            .toList();

        for (int i = 0; i < loadTitle.length; i++) {
          ndtv.add(NewsListModel(
              listItemImageUrl: loadImageUrl[i]!,
              listItemHeadLine: loadTitle[i]!,
              listItemNewsLink: loadLink[i]!,
              isBanner: false,
              date: DateTime.now().toString(),
              source: 'NDTV'));
        }
      } catch (error) {
        print('Error Getting Data from NDTV');
      }
    } else {
      print('Error connecting to server');
    }
  }
  Future<void> extractFromHindustanTimes() async {
    var finalNewsImage;
    var sourceUrl = 'https://www.hindustantimes.com/elections';
    final response = await http.Client().get(Uri.parse(sourceUrl));
    if (response.statusCode == 200) {
      var doc =
      parser.parse(response.body).getElementsByClassName('listingPage')[0];
      try {
        for (int i = 0; i < 30; i++) {
          if (i == 0 || i == 3 || i % 4 == 0) {
            continue;
          }
          //Get News Link------------------
          var newsLink = doc.children[i]
              .getElementsByTagName('h3')[0]
              .getElementsByTagName('a')
              .where((element) => element.attributes.containsKey('href'))
              .map((e) => e.attributes['href']);

          String subLink =
          newsLink.toString().substring(1, newsLink.toString().length - 1);
          var link = '';
          for (int i = 0; i < subLink.length; i++) {
            if (subLink[i] == ',') {
              break;
            }
            link += subLink[i];
          }
          sourceUrl = 'https://www.hindustantimes.com' + link;

          //Get News Image-------------------
          var newsImage = doc.children[i]
              .getElementsByTagName('figure')[0]
              .children[0]
              .getElementsByTagName('a')[0]
              .getElementsByTagName('img')
              .where((element) => element.attributes.containsKey('src'))
              .map((e) => e.attributes['src']).toList();

          //Get Headline
          var newsHeadLine = doc.children[i].getElementsByTagName('h3')[0];


          if (link.isNotEmpty) {
            hindustanTimes.add(NewsListModel(
                listItemImageUrl: newsImage[0].toString(),
                listItemHeadLine: newsHeadLine.text.toString(),
                listItemNewsLink: sourceUrl,
                isBanner: false,
                date: DateTime.now().toString(),
                source: 'Hindustan Times'));
          }
        }
        //Return The NewsModelList
      } catch (e) {
        print('ERROR IN FETCHING DATA');
      }
    } else {
      print('Could Not connect to the URL');
    }
  }
  Future<void> extractFromTheEconomicTimes() async {
    final url = Uri.parse('https://economictimes.indiatimes.com/news/politics');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        final element = document.getElementById('bottomPL');

        for (int i = 0; i < 20; i++) {

          if(i == 4 || i == 5 || i == 6 || i == 13){
            continue;
          }

          var newsLink = element!.children[i]
              .getElementsByTagName('a')
              .where((element) => element.attributes.containsKey('href'))
              .map((e) => e.attributes['href'])
              .toList();

          var imageUrl = element.children[i]
              .getElementsByClassName('imgContainer')[0].getElementsByTagName('img')
              .where(
                  (element) => element.attributes.containsKey('data-original'))
              .map((e) => e.attributes['data-original'])
              .toList();

          var newsHeadLine = element.children[i].getElementsByTagName('h3')[0];

          theEconomicTimes.add(NewsListModel(
              listItemImageUrl: imageUrl[0].toString(),
              listItemHeadLine: newsHeadLine.text.toString(),
              listItemNewsLink: 'https://economictimes.indiatimes.com' + newsLink[0]!,
              isBanner: false,
              date: DateTime.now().toString(),
              source: 'The Economic Times'));

        }
      } catch (e) {
        print("Error Getting Data from Economic Times");
      }
    } else {
      print("Couldn't connect to server");
    }
  }

  getNews() async {
    clear();
    await extractFromNDTV();
    await extractFromHindustanTimes();
    await extractFromTheEconomicTimes();

    latestNews = ndtv+hindustanTimes+theEconomicTimes;
  }

  clear() {
    ndtv.clear();
    hindustanTimes.clear();
    theEconomicTimes.clear();
  }

  addToList(NewsListModel newsListModel) {
    newsToUpload.add(newsListModel);
    notifyListeners();
  }

  removeFromList(NewsListModel newsListModel) {
    newsToUpload.remove(newsListModel);
    notifyListeners();
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


  Future<void> uploadNews(List<NewsListModel> newsModel,
      String documentLoc) async {
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


}
