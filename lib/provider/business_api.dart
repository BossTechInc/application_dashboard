import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import '../model/news_list_model.dart';

class BusinessProvider with ChangeNotifier{
  List<NewsListModel> indiaToday = [];
  List<NewsListModel> ndtv = [];
  List<NewsListModel> theIndianExpress = [];
  List<NewsListModel> hindustanTimes = [];
  List<NewsListModel> latestNews = [];

  List<NewsListModel> newsToUpload = [];

  int latestNewsNum = 0;


  getNews() async {
    clear();
    //await extractFromTheIndianExpress();
    // await extractFromIndiaToday();
    // await extractFromNDTV();
    // await extractFromHindustanTimes();
    latestNews = theIndianExpress + indiaToday + ndtv + hindustanTimes;
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

}