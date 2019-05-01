import 'package:flutter/material.dart';

class MirrorsScreen extends StatefulWidget {
    @override
  _MirrorsScreenState createState() => _MirrorsScreenState();
}

class _MirrorsScreenState extends State<MirrorsScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          _buildAppBar(),
          _buildBody(),
        ],
      )
    );
  }

  
  Widget _buildAppBar() => SliverAppBar(
    floating: true,
    title: Text('MIRA MIRA'),
    centerTitle: true,
    snap: true,
    backgroundColor: Theme.of(context).backgroundColor,
  );

  Widget _buildBody() =>  SliverList(
    delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        if(index > 10) {
          return null;
        }
        return MirrorPreview(
          imagePath: 'assets/picture${(index%2)+1}.jpg',
        ); 
      },
    ),
  );
}

class MirrorPreview extends StatelessWidget {
  final String imagePath;

  MirrorPreview({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 32.0),
      child: Theme(
        data: ThemeData.dark(),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10.0),
                  bottom: Radius.circular(0.0)
                ),
                child: Stack(
                  children: <Widget>[
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      bottom: 0.0,
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ]
                          )
                        ),
                        child: Row(
                          children: <Widget>[ 
                            Expanded(
                              child: Text(
                                'Some dude',
                                style: Theme.of(context).textTheme.headline.apply(color: Colors.white)
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('69% '),
                                    Icon(Icons.thumbs_up_down)
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('4 '),
                                    Icon(Icons.comment)
                                  ],
                                ),
                              ],
                            )
                          ]
                        )
                      ),
                    )
                  ]
                ),
              ),
              _feedBackBar()
            ],
          ),
          elevation: 10.0,
        ),
      ),
    );
  }

  Widget _feedBackBar() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red,
              blurRadius: 3.0,
              spreadRadius: 0.0
            ),
          ],
          color: Colors.white
        ),
        child: IconButton(
          icon: Icon(
            Icons.thumb_down,
            color: Colors.red,
          ),
          onPressed: () {},
        ),
      ),
      Container(
        child: Text(
          'Rate this look?',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.black
          ),
        )
      ),
      Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3.0,
              spreadRadius: 0.0
            ),
          ],
          color: Colors.white
        ),
        child: IconButton(
          icon: Icon(
            Icons.thumb_up,
            color: Colors.grey,
          ),
          onPressed: () {},
        ),
      ),
    ],
  );

}