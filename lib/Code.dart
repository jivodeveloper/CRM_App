import 'package:flutter/material.dart';


class MyHomePagee extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePagee> {

  // selected's value = 0. For default first item is open.
  int selected = 0; //attention

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,title: Text('ExpansionTile Collapse', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Container(color: Colors.white,
            child: SingleChildScrollView(
              child : Column(
                  children : [
                    ListView.builder(
                      key: Key('builder ${selected.toString()}'), //attention
                      padding: EdgeInsets.only(left: 13.0, right: 13.0, bottom: 25.0),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Column(
                            children: <Widget>[
                              Divider(
                                height: 17.0,
                                color: Colors.white,
                              ),
                              ExpansionTile(
                                  key: Key(index.toString()), //attention                                                                  
                                  initiallyExpanded : index==selected, //attention
                                  leading: Icon(Icons.person, size: 50.0, color: Colors.black,),
                                  title: Text('Faruk AYDIN ${index}',style: TextStyle(color: Color(0xFF09216B), fontSize: 17.0, fontWeight: FontWeight.bold)),
                                  subtitle: Text('Software Engineer', style: TextStyle(color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.bold),),
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.all(25.0),
                                        child : Text('DETAİL ${index} \n' + 'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using "Content here, content here", making it look like readable English.',)
                                    )
                                  ],
                                  onExpansionChanged: ((newState){
                                    if(newState)
                                      setState(() {
                                        Duration(seconds:  20000);
                                        selected = index;
                                      });
                                    else setState(() {
                                      selected = -1;
                                    });
                                  })
                              ),

                            ]
                        );
                      },
                    )
                  ]
              ),
            )
        )
    );
  }
}
