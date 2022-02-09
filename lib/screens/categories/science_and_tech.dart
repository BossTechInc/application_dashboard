import 'package:concise_dashboard/provider/science_and_tech_api.dart';
import 'package:concise_dashboard/widgets/list_news.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScienceAndTech extends StatefulWidget {
  static String routeName = '/TechScience';

  @override
  _ScienceAndTechState createState() => _ScienceAndTechState();
}

class _ScienceAndTechState extends State<ScienceAndTech> {
  bool isLoading = false;
  int selectedNews = 0;

  @override
  Widget build(BuildContext context) {
    ScienceAndTechProvider provider = Provider.of<ScienceAndTechProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Science and Technology"),
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
                    provider.uploadNews(provider.newsToUpload, provider.techNewsLoc);
                  }
                },
                child: Text("Upload"),
              ),
              FloatingActionButton(
                heroTag: 'btn2',
                backgroundColor: Colors.black,
                onPressed: () {},
                child: Text('$selectedNews/10'),
              ),
              FloatingActionButton(
                heroTag: 'btn3',
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
