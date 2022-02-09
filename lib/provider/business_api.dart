import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import '../model/news_list_model.dart';

class BusinessProvider with ChangeNotifier {
  List<NewsListModel> ndtv = [];
  List<NewsListModel> hindustanTimes = [];
  List<NewsListModel> moneyControl = [];
  List<NewsListModel> theEconomicTimes = [];
  List<NewsListModel> latestNews = [];
  List<NewsListModel> newsToUpload = [];

  String financeLoc = "news/finance/finance_news";

  int latestNewsNum = 0;

  Future<void> extractFromMoneyControl() async {
    final url = Uri.parse('https://www.moneycontrol.com/news/business/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        var element = document
            .getElementsByClassName('fleft')[0]
            .getElementsByTagName('ul');

        for (int i = 0; i < 30; i++) {
          if ((i + 1) % 5 == 0 || i == 17) {
            continue;
          }

          //Get news Link------------------------
          var newsLink = element[0]
              .children[i]
              .getElementsByTagName('a')
              .where((element) => element.attributes.containsKey('href'))
              .map((e) => e.attributes['href'])
              .toList();

          var imageUrl = element[0]
              .children[i]
              .getElementsByTagName('img')
              .where((element) => element.attributes.containsKey('data-src'))
              .map((e) => e.attributes['data-src'])
              .toList();

          //Get News Headline-----------------------
          var newsHeadLine =
              element[0].children[i].getElementsByTagName('h2')[0];

          moneyControl.add(NewsListModel(
              listItemImageUrl: imageUrl[0].toString(),
              listItemHeadLine: newsHeadLine.text.toString(),
              listItemNewsLink: newsLink[0].toString(),
              isBanner: false,
              date: DateTime.now().toString(),
              source: 'Moneycontrol'));
        }
      } catch (e) {
        print('Error Getting Data From Money Control');
      }
    } else {
      print("Couldn't connect to server");
    }
  }

  Future<void> extractFromTheEconomicTimes() async {
    final url = Uri.parse('https://economictimes.indiatimes.com/news/india');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        final element = document.getElementsByClassName('tabdata')[0];

        for (int i = 0; i < 15; i++) {

          if(i > 2 && i < 12){
            continue;
          }

          var newsLink = element.children[i]
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

  Future<void> extractFromNDTV() async {
    var finalNewsImage;
    var sourceUrl = 'https://www.ndtv.com/business/latest#pfrom=home-business_profitnav';
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
    var sourceUrl = 'https://www.hindustantimes.com/business';
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


  getNews() async {
    clear();
    await extractFromNDTV();
     await extractFromHindustanTimes();
    await extractFromMoneyControl();
    await extractFromTheEconomicTimes();
    latestNews = ndtv +
        hindustanTimes +
        moneyControl +
        theEconomicTimes;
  }

  clear() {
    theEconomicTimes.clear();
    moneyControl.clear();
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
}
