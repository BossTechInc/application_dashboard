import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concise_dashboard/model/news_list_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class ScienceAndTechProvider with ChangeNotifier {
  List<NewsListModel> indiaToday = [];
  List<NewsListModel> theEconomicTimes = [];
  List<NewsListModel> ndtv = [];
  List<NewsListModel> beebom = [];
  List<NewsListModel> theIndianExpress = [];

  List<NewsListModel> latestNews = [];

  List<NewsListModel> newsToUpload = [];

  int latestNewsNum = 0;

  String techNewsLoc = 'news/tech_and_science/tech_and_science_news';

  Future<void> extractFromTheIndianExpress() async {
    final url = Uri.parse('https://indianexpress.com/section/technology/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        var element = document
            .getElementsByClassName('article-list')[0]
            .getElementsByTagName('li');

        List<String?> newsLink = element
            .map((element) =>
        element.getElementsByTagName('a')[0].attributes['href'])
            .toList();
        List<String?> imageUrl = element
            .map((element) =>
        element.getElementsByTagName('img')[0].attributes['src'])
            .toList();
        List<dom.Element> newsHeadline = element
            .map((element) => element.getElementsByTagName('h3')[0])
            .toList();

        for (int i = 0; i < newsHeadline.length; i++) {
          theIndianExpress.add(NewsListModel(
              listItemImageUrl: imageUrl[i]!,
              listItemHeadLine: newsHeadline[i].text.toString(),
              listItemNewsLink: newsLink[i]!,
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
    final url = Uri.parse('https://www.indiatoday.in/technology/news');
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

  Future<void> extractFromTheEconomicTimes() async {
    final url = Uri.parse('https://economictimes.indiatimes.com/news/science');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        final element = document
            .getElementsByClassName('tabdata')[0]
            .getElementsByClassName('eachStory');
        List<String?> newsLink = element
            .map((e) => e.getElementsByTagName('a')[0].attributes['href'])
            .toList();
        List<String?> imageUrl = element
            .map((e) =>
        e.getElementsByTagName('img')[0].attributes['data-original'])
            .toList();
        List<dom.Element> newsHeadLine =
        element.map((e) => e.getElementsByTagName('h3')[0]).toList();

        for (int i = 0; i < newsHeadLine.length; i++) {
          theEconomicTimes.add(NewsListModel(
              listItemImageUrl: imageUrl[i]!,
              listItemHeadLine: newsHeadLine[i].text.toString().trim(),
              listItemNewsLink:
              'https://economictimes.indiatimes.com' + newsLink[i]!,
              isBanner: false,
              date: DateTime.now().toString(),
              source: 'The Economic Times'));
        }
      } catch (e) {
        print('Error Getting Data');
      }
    } else {
      print("Couldn't connect to the URL");
    }
  }

  Future<void> extractFromNDTV() async {
    final url = Uri.parse('https://gadgets.ndtv.com/news');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        final element = document
            .getElementsByClassName('story_list row margin_b30')[0]
            .getElementsByTagName('ul');

        for (int i = 0; i < 15; i++) {
          if ((i + 1) % 5 == 0) {
            continue;
          }

          var newsLink = element[0]
              .children[i]
              .getElementsByTagName('a')
              .where((element) => element.attributes.containsKey('href'))
              .map((e) => e.attributes['href']).toList();

          var imageUrl = element[0]
              .children[i]
              .getElementsByClassName('thumb')[0]
              .getElementsByTagName('img')
              .where(
                  (element) => element.attributes.containsKey('data-original'))
              .map((e) => e.attributes['data-original']);
          if (imageUrl.isEmpty) {
            imageUrl = element[0]
                .children[i]
                .getElementsByClassName('thumb')[0]
                .getElementsByTagName('img')
                .where((element) => element.attributes.containsKey('src'))
                .map((e) => e.attributes['src']);
          }
          var finalNewsImage = imageUrl.toString();
          finalNewsImage = finalNewsImage.replaceAll('(', '');
          finalNewsImage = finalNewsImage.replaceAll(')', '');

          var newsHeadline =
          element[0].children[i].getElementsByClassName('news_listing')[0];

          ndtv.add(NewsListModel(
              listItemImageUrl: finalNewsImage,
              listItemHeadLine: newsHeadline.text.toString(),
              listItemNewsLink: newsLink[0].toString(),
              isBanner: false,
              date: DateTime.now().toString(),
              source: 'NDTV'));
        }
      } catch (e) {
        print('Error Getting Data');
      }
    } else {
      print("Couldn't connect to the URL");
    }
  }

  Future<void> extractFromBeebom() async {
    final url = Uri.parse('https://beebom.com/category/news');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      try {
        var element = document
            .getElementsByClassName(
            'wpnbha show-image image-alignleft ts-3 is-2 is-landscape')[0]
            .getElementsByTagName('article');
        List<String?> newsLink = element
            .map((e) => e.getElementsByTagName('a')[0].attributes['href'])
            .toList();

        List<String?> imageUrl = element
            .map((e) => e.getElementsByTagName('img')[0].attributes['src'])
            .toList();
        List<dom.Element> newsHeadLine =
        element.map((e) => e.getElementsByTagName('h3')[0].children[0])
            .toList();

        print(newsHeadLine[1].text.toString());
        for (int i = 0; i < newsHeadLine.length; i++) {
          beebom.add(NewsListModel(
              listItemImageUrl: imageUrl[i]!,
              listItemHeadLine: newsHeadLine[i].text.toString().trim(),
              listItemNewsLink: newsLink[i]!,
              isBanner: false,
              date: DateTime.now().toString(),
              source: "Beebom"));
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
    await extractFromTheIndianExpress();
    await extractFromIndiaToday();
    await extractFromTheEconomicTimes();
    await extractFromNDTV();
    await extractFromBeebom();

    latestNews =
        theIndianExpress + indiaToday + theEconomicTimes + ndtv + beebom;
  }

  clear() {
    theIndianExpress.clear();
    indiaToday.clear();
    theEconomicTimes.clear();
    ndtv.clear();
    beebom.clear();
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
