import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class LookbookCard extends StatelessWidget {

  final Lookbook lookbook;

  LookbookCard(this.lookbook);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[300],
      child: InkWell(
        onTap: () => CustomNavigator.goToLookbookScreen(context, 
          lookbook: lookbook,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(4)
                  )
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraint) {
                    double maxSize = constraint.maxHeight > constraint.maxWidth ? constraint.maxWidth : constraint.maxHeight;
                    return Icon(
                      FontAwesomeIcons.addressBook,
                      size: maxSize,
                      color: Colors.black,
                    );
                  }
                )
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 4, right: 4, bottom: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Text(
                          lookbook.name,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        '${lookbook.numberOfOutfits} Outfit${lookbook.numberOfOutfits==1?'':'s'}',
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                          color: Colors.black
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ]
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  _displayLookbookCover() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(8)
      ),
      child: Container(
        color: Colors.grey,
        height: 100,
        child: Row(
          children: <Widget>[
            _tempImage('http://www.sandgent.co.uk/main/wp-content/uploads/2013/06/Kanye-West-wearing-Patta-x-Kangaroos-Woodhollow-Heritage-Hiking-Sneaker-Boots-Upscalehype-6.jpg', hasLeft: false),
            _tempImage('https://cdn-production.looklive.com/D1Pw1q37I3lmiP2S6nYh1QEjzTE=/0x0:2200x3300/400x610/f4f66c64-a1ce-4d8e-8fab-44b8c876f2f7'),                 
            _tempImage('https://media.gq.com/photos/56841349630c329d44e9160b/master/w_2237,h_3355,c_limit/Kanye-West-Style-2015-12-19-15.jpg'),                 
            _tempImage('https://s3.r29static.com//bin/entry/53d/74,176,1852,2222/720x864,85/1628109/image.webp'),
            _tempImage('https://content.asos-media.com/-/media/images/articles/men/2016/04/10-sun/90s-oversized-then-vs-now/asos-mw-dd-article-90s-oversized-bieber.jpg?h=468&w=321&la=en-GB&hash=4F7B2B1616CB5C50356EBAFC9F2DA486', hasRight: false),
          ],
        ),
      ),
    );
  }

  _tempImage(String url, {bool hasLeft = true, bool hasRight = true}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: Colors.black, width: hasLeft ? 1 : 0),
            end: BorderSide(color: Colors.black, width: hasRight ? 1 : 0),
          ),
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover
          )
        ),
      ),
    );
  }

}