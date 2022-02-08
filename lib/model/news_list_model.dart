class NewsListModel {
  String listItemImageUrl;
  String listItemHeadLine;
  String listItemNewsLink;
  bool isBanner;
  String date;
  String source;
  bool isSelected;
  int? newsNumber;

  NewsListModel(
      {required this.listItemImageUrl,
      required this.listItemHeadLine,
      required this.listItemNewsLink,
      required this.isBanner,
      required this.date,
      required this.source,
      this.isSelected = false,
      this.newsNumber});

  static NewsListModel fromJson(Map<String, dynamic> json) {
    return NewsListModel(
      listItemNewsLink: json['listItemNewsLink'],
      listItemHeadLine: json['listItemHeadLine'],
      listItemImageUrl: json['listItemImageUrl'],
      isBanner: json['isBanner'],
      date: json['date'],
      source: json['source'],
      newsNumber: json['newsNumber']
    );
  }
  Map<String, dynamic> toJson() => {
    'listItemNewsLink': listItemNewsLink,
    'listItemHeadLine': listItemHeadLine,
    'listItemImageUrl': listItemImageUrl,
    'source': source,
    'date' : date,
    'isBanner': isBanner,
    'newsNumber' : newsNumber,
  };
}
