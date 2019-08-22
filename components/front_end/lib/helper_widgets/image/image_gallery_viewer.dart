import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';

class ImageGalleryPreview extends StatelessWidget {
  
  final List<String> imageUrls;
  final int currentIndex;
  final String title;
  final bool isLocal;

  ImageGalleryPreview({this.imageUrls, this.currentIndex, this.title, this.isLocal = false,});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openImageViewer(context),
      child: Hero(
        child: isLocal ? Image.asset(
          imageUrls[currentIndex],
          fit: BoxFit.cover,
        ) : CachedNetworkImage(
          imageUrl: imageUrls[currentIndex],
          fit: BoxFit.cover,
        ),
        tag: imageUrls[currentIndex],
      ),
    );
  }

  _openImageViewer(context){
    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => _ImageGalleryViewer(imageUrls, currentIndex, title, isLocal)));
  }
}

class _ImageGalleryViewer extends StatefulWidget {

  final List<String> imageUrls;
  final int currentIndex;
  final String title;
  final bool isLocal;

  _ImageGalleryViewer(this.imageUrls, this.currentIndex, this.title, this.isLocal);

  @override
  __ImageGalleryViewerState createState() => __ImageGalleryViewerState();
}

class __ImageGalleryViewerState extends State<_ImageGalleryViewer> {
  
  int currentPage = 0;
  @override
  void initState() {
    currentPage = widget.currentIndex + 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
        ),
        title: Text(
          '${widget.title} $currentPage/${widget.imageUrls.length}',
          style: TextStyle(
            inherit: true,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: ExtendedImageGesturePageView.builder(
        controller: PageController(
          initialPage: widget.currentIndex
        ),
        onPageChanged: (newIndex) {
          setState(() {
           currentPage = newIndex + 1; 
          });
        },
        itemCount: widget.imageUrls.length,
        itemBuilder: (ctx, i) => Hero(
          tag: widget.imageUrls[i],
          child: ExtendedImageSlidePage(
            slideAxis: SlideAxis.both,
            slideType: SlideType.onlyImage,
            child: ExtendedImage(
              enableSlideOutPage: true,
              mode: ExtendedImageMode.Gesture,
              initGestureConfigHandler: (state) => GestureConfig(
                minScale: 1.0,
                animationMinScale: 0.8,
                maxScale: 3.0,
                animationMaxScale: 3.5,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: 1.0,
                inPageView: false,
              ),
              fit: BoxFit.contain,
              image: widget.isLocal ? 
                AssetImage(
                  widget.imageUrls[i],
                ) : 
                CachedNetworkImageProvider(
                  widget.imageUrls[i],
                ),
            ),
          ),
        ),
      ),
    ); 
  }
}