import 'package:concise_dashboard/model/news_list_model.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class HealthProvider with ChangeNotifier{

  List<NewsListModel> ndtv = [];
  List<NewsListModel> indiaToday = [];
  List<NewsListModel> abpLive = [];

  List<NewsListModel> latestNews = [];
  List<NewsListModel> newsToUpload = [];
  int latestNewsNum = 0;

  String healthLoc = 'news/health/health_news';


  Future<void> extractFromNDTV() async {
    final url = Uri.parse('https://doctor.ndtv.com/top-stories');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        final element = document.getElementById('article');

        for (int i = 0; i < 3; i++) {

          var newsLink = element!.children[i]
              .getElementsByTagName('a')
              .where((element) => element.attributes.containsKey('href'))
              .map((e) => e.attributes['href'])
              .toList();

          var imageUrl = element.children[i].getElementsByTagName('a')[0].getElementsByTagName('img')
              .where(
                  (element) => element.attributes.containsKey('src'))
              .map((e) => e.attributes['src']).toString();
         // print(imageUrl);
          var finalLink = '';
          for(int i = 1; i<imageUrl.length-3;i++){
            finalLink += imageUrl.toString()[i];
          }
           var newsHeadLine = element.children[i].getElementsByTagName('a')[0].getElementsByTagName('img')
               .where(
                   (element) => element.attributes.containsKey('alt'))
               .map((e) => e.attributes['alt']).toList();

          ndtv.add(NewsListModel(
              listItemImageUrl: finalLink,
              listItemHeadLine: newsHeadLine[0].toString(),
              listItemNewsLink: 'https://doctor.ndtv.com' + newsLink[0]!,
              isBanner: false,
              date: DateTime.now().toString(),
              source: 'NDTV'));

         }
      } catch (e) {
        print("Error Getting Data from NDTV");
      }
    } else {
      print("Couldn't connect to server");
    }
  }

  Future<void> extractFromABPLive() async {
    final url = Uri.parse('https://news.abplive.com/health');
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

  Future<void> extractFromIndiaToday() async {
    final url = Uri.parse('https://www.indiatoday.in/coronavirus-covid-19-outbreak');
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

  getNews() async {
    clear();
    await extractFromIndiaToday();
    await extractFromNDTV();
    await extractFromABPLive();

    latestNews = ndtv + abpLive + indiaToday;
    print(latestNews.length);
  }

  clear() {
    abpLive.clear();
    ndtv.clear();
    indiaToday.clear();
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