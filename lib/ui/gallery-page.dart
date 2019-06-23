import 'package:flutter/material.dart';
import 'package:omsk_events/bloc/gallery-bloc.dart';
import 'package:omsk_events/di.dart';
import 'package:omsk_events/model/album-short.dart';
import 'package:omsk_events/model/photo.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share/share.dart';

import 'dart:math';

import 'utils.dart';

const placeholder = AssetImage("assets/grey_box.jpg");

class GalleryPage extends StatefulWidget {
  final int eventId;
  final GalleryBloc _galleryBloc;

  GalleryPage({Key key, this.eventId})
      : _galleryBloc = GalleryBloc(
            eventRepository: DI.eventRepository,
            albumRepository: DI.albumRepository,
            eventId: eventId),
        super(key: key);

  @override
  State<StatefulWidget> createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  List<Widget> _buildChildren(List<AlbumShort> albums) {
    return albums.map((a) => GalleryAlbumItem(album: a)).toList();
  }

  @override
  void initState() {
    super.initState();
    widget._galleryBloc.loadAlbums();
  }

  @override
  void didUpdateWidget(GalleryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget._galleryBloc.loadAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(),
        child: Scaffold(
            appBar: AppBar(title: const Text("Альбомы")),
            body: StreamBuilder(
              stream: widget._galleryBloc.albums,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<AlbumShort> albums = snapshot.data;

                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    padding: const EdgeInsets.all(4.0),
                    children: _buildChildren(albums),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )));
  }
}

class GalleryAlbumItem extends StatelessWidget {
  final AlbumShort album;

  const GalleryAlbumItem({Key key, @required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GalleryPhotosPage(album: album),
              ));
        },
        child: GridTile(
          child: Hero(
              tag: album.id,
              child: FadeInImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(album.cover),
                placeholder: placeholder,
              )),
          footer: GridTileBar(
              backgroundColor: Colors.black45, subtitle: Text(album.name)),
        ));
  }
}

class GalleryPhotosPage extends StatefulWidget {
  final AlbumShort album;
  final GalleryBloc _galleryBloc;

  GalleryPhotosPage({Key key, @required this.album})
      : _galleryBloc = GalleryBloc(
            eventRepository: DI.eventRepository,
            albumRepository: DI.albumRepository);

  @override
  State<StatefulWidget> createState() => GalleryPhotosPageState();
}

class GalleryPhotosPageState extends State<GalleryPhotosPage> {
  @override
  void initState() {
    super.initState();
    widget._galleryBloc.loadAlbumById(widget.album.id);
  }

  @override
  void didUpdateWidget(GalleryPhotosPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget._galleryBloc.loadAlbumById(widget.album.id);
  }

  List<Widget> _buildChildren(List<Photo> photos) {
    return photos
        .asMap()
        .map((index, image) => MapEntry(
            index,
            GalleryPhotosItem(
              image: image,
              onTap: _onTap(index, photos),
            )))
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(),
        child: Stack(children: <Widget>[
          Scaffold(
            appBar: AppBar(title: Text(widget.album.name)),
            body: StreamBuilder(
              stream: widget._galleryBloc.fullAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<Photo> photos = snapshot.data.photos;

                  return Stack(children: <Widget>[
                    GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      padding: const EdgeInsets.all(4.0),
                      children: _buildChildren(photos),
                    )
                  ]);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
        ]));
  }

  VoidCallback _onTap(int index, List<Photo> photos) => () {
        Navigator.push(
            context,
            TransparentRoute(
                builder: (context) =>
                    GalleryDetailsPage(images: photos, initialIndex: index)));
      };
}

class GalleryPhotosItem extends StatelessWidget {
  const GalleryPhotosItem({Key key, @required this.image, this.onTap})
      : super(key: key);

  final Photo image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: GridTile(
            child: Hero(
                tag: image.id,
                child: FadeInImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(image.src),
                  placeholder: placeholder,
                ))));
  }
}

class GalleryDetailsPage extends StatefulWidget {
  final List<Photo> images;
  final int initialIndex;

  const GalleryDetailsPage({Key key, @required this.images, this.initialIndex})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => GalleryDetailsPageState();
}

class GalleryDetailsPageState extends State<GalleryDetailsPage> {
  PageController _pageController;
  int _currentIndex;

  double _opacity = 1;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  bool onScrollChanged(ScrollNotification notification) {
    const dpToDisappear = 300.0;
    const deltaToClose = 30;

    if (notification.depth != 0) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails != null &&
          notification.dragDetails.primaryDelta < -deltaToClose)
        Navigator.pop(context);

      setState(() {
        _opacity = 1 -
            Curves.easeIn.transform(_normalizeFromTo(
                0, dpToDisappear, notification.metrics.pixels));
      });
    }

    return true;
  }

  Widget _buildPhotoViewGallery() {
    return PhotoViewGallery.builder(
      backgroundDecoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      scrollPhysics: const ClampingScrollPhysics(),
      onPageChanged: onPageChanged,
      pageController: _pageController,
      builder: (BuildContext context, int index) => PhotoViewGalleryPageOptions(
          imageProvider: CachedNetworkImageProvider(widget.images[index].src),
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 1.3,
          heroTag: _currentIndex == index ? widget.images[index].id : "invalid tag"),
      itemCount: widget.images.length,
    );
  }

  Widget _buildCaption() {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          widget.images[_currentIndex].description,
          style: const TextStyle(
              color: Colors.white, fontSize: 17.0, decoration: null),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(),
        child: Scaffold(
            appBar: AppBar(
              title: Text("${_currentIndex + 1} из ${widget.images.length}"),
              backgroundColor: Colors.black,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: "Поделиться",
                  onPressed: _share,
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            body: Stack(alignment: Alignment.bottomRight, children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black.withOpacity(_opacity)),
              NotificationListener<ScrollNotification>(
                  onNotification: onScrollChanged,
                  child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: <Widget>[
                        SliverPadding(
                            padding: const EdgeInsets.only(bottom: 1),
                            sliver: SliverFillRemaining(
                                child: _buildPhotoViewGallery())),
                      ])),
              _buildCaption()
            ])));
  }

  double _normalizeFromTo(double from, double to, double value) {
    return min(max(0, value - from), to - from) / (to - from);
  }

  void _share() {
    Share.plainText(
            text: "${widget.images[_currentIndex].src}\n"
                "${widget.images[_currentIndex].description}")
        .share();
  }
}
