import 'package:concise_dashboard/provider/world_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/list_news.dart';

class InternationalAffairs extends StatefulWidget {
  static String routeName='/InternationalAffairs';
  const InternationalAffairs({Key? key}) : super(key: key);

  @override
  _InternationalAffairsState createState() => _InternationalAffairsState();
}

class _InternationalAffairsState extends State<InternationalAffairs> {

  bool isLoading = false;
  int selectedNews = 0;

  @override
  Widget build(BuildContext context) {
    InternationalProvider provider = Provider.of<InternationalProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("International Affairs"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'btn1',
              backgroundColor: Colors.red,
              onPressed: () {
                if(provider.newsToUpload.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Select At least One News")));
                }else{
                  provider.uploadNews(provider.newsToUpload, provider.worldNewsLoc);
                }
              },
              child: Text("Upload"),
            ),
            FloatingActionButton(
              heroTag: 'btn2',
              backgroundColor: Colors.amber,
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                await provider.getNews();
                setState(() {
                  isLoading = false;
                });
              },
              child: Text("Get"),
            )
          ],
        ),
      ),

      body: isLoading?Center(child:CircularProgressIndicator() ):ListView.builder(
          itemCount: provider.latestNews.length,
          itemBuilder: (context, index) {
            return GestureDetector(child: NewsList(provider.latestNews[index],provider.newsToUpload),onLongPress: (){

              if(selectedNews > 9){
                if(provider.latestNews[index].isSelected){
                  provider.latestNews[index].isSelected = false;
                  provider.removeFromList(provider.latestNews[index]);
                  setState(() {
                    selectedNews--;
                  });
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can't Select News more than 10")));
                }
              }else{
                provider.latestNews[index].isSelected = !(provider.latestNews[index].isSelected);
                if(provider.latestNews[index].isSelected){
                  provider.addToList(provider.latestNews[index]);
                  setState(() {
                    selectedNews++;
                  });
                }else{
                  provider.removeFromList(provider.latestNews[index]);
                  setState(() {
                    selectedNews--;
                  });
                }
              }
            },);
          }),
    );
  }
}