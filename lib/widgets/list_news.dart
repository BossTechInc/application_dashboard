import 'package:concise_dashboard/model/news_list_model.dart';
import 'package:concise_dashboard/provider/science_and_tech_api.dart';
import 'package:concise_dashboard/widgets/web_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class NewsList extends StatelessWidget {

  NewsListModel newsListModel;
  List<NewsListModel> newsToUpload;
  NewsList(this.newsListModel,this.newsToUpload);


  void onShareText(BuildContext context, String? headline, String? link) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(
        "Get the summary of the day at a glance. Download concise. ${newsListModel.listItemNewsLink}",
        subject: "subject",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    ScienceAndTechProvider scienceProvider = Provider.of<ScienceAndTechProvider>(context);
    return InkWell(
    onTap: () {
      Navigator.of(context).pushNamed(Web.routeName,arguments:
      newsListModel.listItemNewsLink
      );
      },
      child: Card(

        color:Colors.white,
         elevation: 0,
        // shadowColor: Color(0xffcdd1cc),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(6),
        child: Row(
          children: [

            Expanded(
              child: Container(
                color: newsToUpload.contains(newsListModel) ? Colors.blue : Colors.transparent,
                padding: EdgeInsets.all(5),
                height: MediaQuery.of(context).size.width * 0.30,
                // margin: EdgeInsets.all(10),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      [
                        Text(newsListModel.source,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff1d425d),fontFamily: 'Tinos-Regular'),
                        ),

                        Container(
                          height: MediaQuery.of(context).size.width * 0.20,
                          width: MediaQuery.of(context).size.width * 0.55,
                          margin: EdgeInsets.only(top: 3),
                          child: Stack(
                            children: [
                              Text(newsListModel.listItemHeadLine,
                                    style:TextStyle(fontSize:15.5, fontWeight: FontWeight.w500, color: Colors.black,fontFamily: 'Tinos-Regular'),
                                    maxLines: 3,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child:GestureDetector(
                                    onTap: () =>
                                        onShareText(context, newsListModel.listItemHeadLine, newsListModel.listItemImageUrl),
                                    child: Icon(
                                      Icons.share,
                                      color:Color(0xff1d425d),
                                      size: 19,
                                    ),
                                  ),)
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.25,
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Image.network(
                    newsListModel.listItemImageUrl,
                    height: MediaQuery.of(context).size.width * 0.25,
                    width: MediaQuery.of(context).size.width * 0.25,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        BuildContext context,
                        Object exception, StackTrace? stackTrace) {
                      return Container(
                          color: Colors.blueGrey[200],
                          height: MediaQuery.of(context).size.width * 0.25,
                          width: MediaQuery.of(context).size.width * 0.25,
                          );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
