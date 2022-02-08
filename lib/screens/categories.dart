import 'package:flutter/material.dart';

class Categories extends StatelessWidget {

  List<Map<String, String>> routes = [
    {'Health': '/Health'},
    {"Politics": '/Politics'},
    {"Finance": '/Finance'},
    {"International Affairs": '/InternationalAffairs'},
    {'Science & Technology' : '/TechScience'},
    {"Sports": '/Sports'},
    {"Entertainment": '/Entertainment'}
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Categories")),
      body: Center(
        child: ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              String categoryName = routes[index].keys.toString();
              categoryName = categoryName.replaceAll('(', '');
              categoryName = categoryName.replaceAll(')', '');

              String route = routes[index].values.toString();
              route = route.replaceAll('(', '');
              route = route.replaceAll(')', '');

              return ListTile(
                onTap: () async {
                  Navigator.of(context).pushNamed(route);
                },
                title: Text(categoryName),
              );
            }),
      ),
    );
  }
}
