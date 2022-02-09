import 'package:concise_dashboard/model/news_list_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class SportsProvider with ChangeNotifier {
  List<NewsListModel> firstPost = [];
  List<NewsListModel> hindustanTimes = [];
  List<NewsListModel> abpLive = [];

  List<NewsListModel> latestNews = [];
  int latestNewsNum = 0;
  List<NewsListModel> newsToUpload = [];
  String sportsLoc = 'news/sports/sports_news';

  Future<void> extractFromFirstpost() async {
    final url = Uri.parse('https://www.firstpost.com/category/sports');
    final response = await http.get(url);
    if(response.statusCode == 200) {
      try {
        dom.Document document = parser.parse(response.body);

        final element=document.getElementsByClassName('main-container')[0].getElementsByClassName('main-content')[0].getElementsByClassName('big-thumb');
        List<String?> imageUrl=element.map((element) => element.getElementsByTagName('img')[0].attributes['data-src']).toList();
        List<String?> newsHeadLine=element.map((element) => element.getElementsByTagName('img')[0].attributes['title']).toList();
        List<String?> newsLink=element.map((element) => element.getElementsByTagName('a')[0].attributes['href']).toList();


        for (int i = 0; i < newsHeadLine.length; i++) {
          firstPost.add(NewsListModel(
              listItemImageUrl: 'https:' + imageUrl[i]!,
              listItemHeadLine: newsHeadLine[i]!,
              listItemNewsLink: newsLink[i]!,
              isBanner: false,
              date: DateTime.now().toString(),
              source: "Firstpost"));
        }

      } catch (error) {
        print("Error Getting Data");
      }
    }else{
      print("Error Connecting to the URL");
    }
  }
  Future<void> extractFromHindustanTimes() async {
    var sourceUrl = 'https://www.hindustantimes.com/sports';
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
              .map((e) => e.attributes['href']).toList();

          sourceUrl = 'https://www.hindustantimes.com' + newsLink[0].toString() ;

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

            hindustanTimes.add(NewsListModel(
                listItemImageUrl: newsImage[0].toString(),
                listItemHeadLine: newsHeadLine.text.toString(),
                listItemNewsLink: sourceUrl,
                isBanner: false,
                date: DateTime.now().toString(),
                source: 'Hindustan Times'));
        }
        //Return The NewsModelList
      } catch (e) {
        print('ERROR IN FETCHING DATA');
      }
    } else {
      print('Could Not connect to the URL');
    }
  }

  Future<void> extractFromABPLive() async {
    final url = Uri.parse('https://news.abplive.com/sports');
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

  getNews() async {
    clear();
    await extractFromFirstpost();
     await extractFromHindustanTimes();
     await extractFromABPLive();

  }

  clear() {
    firstPost.clear();
    hindustanTimes.clear();
    abpLive.clear();
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
