class NewsListModel {
  String listItemImageUrl;
  String listItemHeadLine;
  String listItemNewsLink;
  bool isBanner;
  String date;
  String source;

  NewsListModel({
      required this.listItemImageUrl,required this.listItemHeadLine,required this.listItemNewsLink,required this.isBanner, required this.date,required this.source});

  static NewsListModel fromJson(Map<String,dynamic> json){
    return NewsListModel(
      listItemNewsLink: json['listItemNewsLink'],
      listItemHeadLine: json['listItemHeadLine'],
      listItemImageUrl: json['listItemImageUrl'],
      isBanner: json['isBanner'],
      date: json['date'],
      source: json['source'],
    );
  }



}



