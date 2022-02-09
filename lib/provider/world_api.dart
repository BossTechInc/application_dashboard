import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import '../model/news_list_model.dart';

class InternationalProvider with ChangeNotifier {
  List<NewsListModel> indiaToday = [];
  List<NewsListModel> ndtv = [];
  List<NewsListModel> theIndianExpress = [];
  List<NewsListModel> hindustanTimes = [];
  List<NewsListModel> latestNews = [];
  List<NewsListModel> newsToUpload = [];

  String worldNewsLoc = 'news/international_affairs/international_news';

  int latestNewsNum = 0;

  Future<void> extractFromTheIndianExpress() async {
    final url = Uri.parse('https://indianexpress.com/section/world/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        var element = document
            .getElementsByClassName('north-east-grid explained-section-grid')[0]
            .getElementsByTagName('ul')[0];

        for (int i = 0; i < 15; i++) {
          if (i == 2 || i == 11 || i == 20) {
            continue;
          }

          var newsLink = element.children[i]
              .getElementsByTagName('a')
              .where((element) => element.attributes.containsKey('href'))
              .map((e) => e.attributes['href'])
              .toList();
          // print(newsLink[0]);
          var imageUrl = element.children[i]
              .getElementsByTagName('img')
              .where((element) => element.attributes.containsKey('src'))
              .map((e) => e.attributes['src'])
              .toList();
          //print(imageUrl[0]);

          var newsHeadLine = element.children[i]
              .getElementsByTagName('h3')[0]
              .getElementsByTagName('a')[0];
         // print(newsHeadLine.text.toString());

          theIndianExpress.add(NewsListModel(
              listItemImageUrl: imageUrl[0].toString(),
              listItemHeadLine: newsHeadLine.text.toString(),
              listItemNewsLink: newsLink[0].toString(),
              isBanner: false,
              date: DateTime.now().toString(),
              source: 'The Indian Express'));
        }
      } catch (e) {
        print("Error Getting Data");
      }
    } else {
      print("Couldn't connect to server");
    }
  }

  Future<void> extractFromIndiaToday() async {
    final url = Uri.parse('https://www.indiatoday.in/world');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        var element = document
            .getElementsByClassName('view-content')[0]
            .getElementsByClassName('catagory-listing');
        List<String?> newsLink = element
            .map((e) => e.getElementsByTagName('a')[0].attributes['href'])
            .toList();
        List<String?> imageUrl = element
            .map((e) => e.getElementsByTagName('img')[0].attributes['src'])
            .toList();
        List<dom.Element> newsHeadLine =
        element.map((e) => e.getElementsByTagName('h2')[0]).toList();

        for (int i = 0; i < newsHeadLine.length; i++) {
          indiaToday.add(NewsListModel(
              listItemImageUrl: imageUrl[i]!,
              listItemHeadLine: newsHeadLine[i].text.toString().trim(),
              listItemNewsLink: 'https://www.indiatoday.in' + newsLink[i]!,
              isBanner: false,
              date: DateTime.now().toString(),
              source: "India Today"));
        }
      } catch (e) {
        print('Error in Getting Data');
      }
    } else {
      print("Couldn't connect to server");
    }
  }

  Future<void> extractFromNDTV() async {
    var finalNewsImage;
    var sourceUrl = 'https://www.ndtv.com/world-news#pfrom=home-ndtv_mainnavgation';
    final response = await http.Client().get(Uri.parse(sourceUrl));
    if (response.statusCode == 200) {
      var doc =
      parser.parse(response.body).getElementsByClassName('lisingNews')[0];
      try {
        for (int i = 0; i < 16; i++) {
          if (i == 3 || i == 7) {
            continue;
          }
          //Get News Link------------------
          var newsLink = doc.children[i]
              .getElementsByClassName('news_Itm-img')[0]
              .getElementsByTagName('a')
              .where((element) => element.attributes.containsKey('href'))
              .map((e) => e.attributes['href'])
              .toString();

          newsLink = newsLink.replaceAll('(', '');
          newsLink = newsLink.replaceAll(')', '');

          //Get News Image-------------------
          var newsImage = doc.children[i]
              .getElementsByClassName('news_Itm-img')[0]
              .getElementsByTagName('img')
              .where((element) => element.attributes.containsKey('src'))
              .map((e) => e.attributes['src']);

          finalNewsImage = newsImage.toString();
          finalNewsImage = finalNewsImage.replaceAll('(', '');
          finalNewsImage = finalNewsImage.replaceAll(')', '');

          //Get Headline
          var newsHeadLine =
          doc.children[i].getElementsByClassName('newsHdng')[0];

          //
          if (newsLink.isNotEmpty) {
            ndtv.add(NewsListModel(
                listItemImageUrl: finalNewsImage,
                listItemHeadLine: newsHeadLine.text.toString(),
                listItemNewsLink: newsLink,
                isBanner: false,
                date: DateTime.now().toString(),
                source: 'NDTV'));
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

  Future<void> extractFromHindustanTimes() async {
    var finalNewsImage;
    var sourceUrl = 'https://www.hindustantimes.com/world-news';
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
              .map((e) => e.attributes['src']);

          finalNewsImage = newsImage.toString();
          finalNewsImage = finalNewsImage.replaceAll('(', '');
          finalNewsImage = finalNewsImage.replaceAll(')', '');

          //Get Headline
          var newsHeadLine = doc.children[i].getElementsByTagName('h3')[0];


          if (link.isNotEmpty) {
            hindustanTimes.add(NewsListModel(
                listItemImageUrl: finalNewsImage,
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

  getNews() async {
    clear();
    await extractFromTheIndianExpress();
    await extractFromIndiaToday();
    await extractFromNDTV();
    await extractFromHindustanTimes();
    latestNews = theIndianExpress + indiaToday + ndtv + hindustanTimes;
    print(latestNews.length);
  }

  clear() {
    theIndianExpress.clear();
    indiaToday.clear();
    ndtv.clear();
    hindustanTimes.clear();
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
