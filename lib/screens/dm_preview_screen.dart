import 'package:flutter/material.dart';

class DMPreviewScreen extends StatefulWidget {
  @override
  _DMPreviewScreenState createState() => _DMPreviewScreenState();
}

class _DMPreviewScreenState extends State<DMPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text('Recent Messages (3)'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_comment),
            onPressed: () {},
          )
        ],
        elevation: 0.0,
      ),
      body: Container(
        child: ListView(
          children: _buildDMPreviews()..add(
            _buildDMexpand()
          ) 
        ),
      ),
    );
  }

  List<Widget> _buildDMPreviews(){
    List<Widget> previews = [];
    for(int i = 0; i < 6; i++){
      previews.add(_buildDMfield(i+1));
    }
    return previews;
  }

  Widget _buildDMfield(int i) {
    return Material(
      child: InkWell(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          padding: EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.5)
              )
            )
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8.0),
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/profile$i.jpg'),
                    fit: BoxFit.cover
                  ),
                  color: Colors.grey
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Person Name $i',
                              style: Theme.of(context).textTheme.subtitle,
                            )
                          ),
                          Text(
                            '12:43 PM',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Hey there just checking if you got my latest message',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }
  
  Widget _buildDMexpand() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('VIEW ALL MESSAGES'),
          onPressed: () {},
        ),
    );
  }
}