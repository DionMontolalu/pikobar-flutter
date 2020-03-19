import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pikobar_flutter/components/ErrorContent.dart';
import 'package:pikobar_flutter/components/Skeleton.dart';
import 'package:pikobar_flutter/constants/Dictionary.dart';
import 'package:pikobar_flutter/constants/Navigation.dart';
import 'package:pikobar_flutter/environment/Environment.dart';
import 'package:pikobar_flutter/utilities/FormatDate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:html/parser.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final RefreshController _mainRefreshController = RefreshController();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Dictionary.message),
        ),
        body: 
        // SmartRefresher(
        //     controller: _mainRefreshController,
        //     enablePullDown: true,
        //     header: WaterDropMaterialHeader(),
        //     onRefresh: () async {

        //       _mainRefreshController.refreshCompleted();
        //     },
        //     child:
             StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('broadcasts').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return ErrorContent(error: snapshot.error);
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return _buildLoading();
                  default:
                    return _buildContent(snapshot);
                }
              },
            // )
            ));
  }

  String _parseHtmlString(String htmlString) {
    var document = parse(htmlString);

    String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  _buildLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Card(
          margin: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 0.0),
          elevation: 0.2,
          child: Container(
            margin: EdgeInsets.all(15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(right: 10.0, top: 5.0),
                    child: Skeleton(
                      width: 24.0,
                      height: 24.0,
                    )),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Skeleton(
                          width: MediaQuery.of(context).size.width,
                          height: 20.0),
                      Skeleton(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 20.0,
                            margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
                            color: Colors.grey[300]),
                      ),
                      Skeleton(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 20.0,
                            margin: EdgeInsets.only(bottom: 5.0),
                            color: Colors.grey[300]),
                      ),
                      Skeleton(
                        child: Container(
                            width: MediaQuery.of(context).size.width - 170,
                            height: 20.0,
                            margin: EdgeInsets.only(bottom: 15.0),
                            color: Colors.grey[300]),
                      ),
                      Skeleton(
                          width: MediaQuery.of(context).size.width - 250,
                          height: 15.0),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  _buildContent(AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(15.0),
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, index) {
        final DocumentSnapshot document = snapshot.data.documents[index];
        return Padding(
          padding:  EdgeInsets.only(bottom: 15),
          child: GestureDetector(
            child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                margin: EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 0.0),
                elevation: 0.5,
                child: Container(
                  margin: EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(right: 10.0, top: 5.0),
                          child: Image.asset(
                            '${Environment.iconAssets}broadcast.png',
                            width: 24.0,
                            height: 24.0,
                          )),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              document['title'],
                              style: TextStyle(
                                  fontSize: 16.0, color: Color(0xff4F4F4F),fontWeight: FontWeight.bold),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8.0, bottom: 15.0),
                              child: Text(
                                _parseHtmlString(document['content']),
                                maxLines: 3,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    fontSize: 15.0, color: Color(0xff828282)),
                              ),
                            ),
                            Text(
                              unixTimeStampToDateTime(
                                  document['published_at'].seconds),
                              style:
                                  TextStyle(fontSize: 12.0, color: Color(0xffBDBDBD)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            onTap: () {
              _openDetail(snapshot.data.documents[index]);
            },
          ),
        );
      },
    );
  }

  _openDetail(DocumentSnapshot document) async {
    await Navigator.pushNamed(context, NavigationConstrants.BroadcastDetail,
        arguments: document);
  }
}
