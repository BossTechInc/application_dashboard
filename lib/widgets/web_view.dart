import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class Web extends StatefulWidget {
  // String newsUrl;
  // Web(this.newsUrl);
  static final routeName = '/web';
  @override
  State<Web> createState() => _WebState();
}

class _WebState extends State<Web> {
/*bool showSpiner = true;*/

  double progress = 0;
  @override
  Widget build(BuildContext context) {
    final listNewsLink= ModalRoute.of(context)!.settings.arguments as String;
    return  Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
        SystemUiOverlayStyle(
          statusBarColor: Color(0xff1d425d), // transparent status bar
        ),
        elevation: 1,
        title: Text('Your News in Detail',
          style: TextStyle(fontSize: MediaQuery.of(context).size.height/40, fontWeight: FontWeight.w500, color: Colors.white,
              fontFamily: 'Tinos-Regular'
          ),),
        centerTitle: true,
        backgroundColor:Color(0xff1d425d),
      ),
      body: Column(
        children:[
          LinearProgressIndicator(
            value: progress,
            color: Color(0xff1d425d),
            backgroundColor: Colors.white,
          ),
          Expanded(
            child: WebView(
              initialUrl: listNewsLink,
              javascriptMode: JavascriptMode.unrestricted,
              onWebResourceError: (_){
                Center(
                  child: Text('Could not Load the site'),
                );
              },
              onProgress: (progress){
                setState(() {
                  this.progress = progress/100;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
