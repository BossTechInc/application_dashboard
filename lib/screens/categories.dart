import 'package:flutter/material.dart';

class Categories extends StatelessWidget {
  List<String> categories = [
    "Health",
    "Politics",
    "Finance",
    "International Affairs",
    "Science & Technology",
    "Sports",
    "Entertainment"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Categories")),
      body: Center(
        child: ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: (){},
                title: Text(categories[index]),
              );
            }),
      ),
    );
  }
}
