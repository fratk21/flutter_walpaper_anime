import 'dart:async';

import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_anime/api.dart';

class chanel2 extends StatefulWidget {
  const chanel2({super.key});

  @override
  State<chanel2> createState() => _chanel2State();
}

class _chanel2State extends State<chanel2> {
  List<String> imageUrls = [];
  Random _random = Random();
  int pic = 0;
  Timer? _timer;
  ScrollController _scrollController = ScrollController();

  Future<void> fetchWaifuImage() async {
    try {
      final data = await api2.fetchWaifus();
      final images = data['images'];
      if (images.isNotEmpty) {
        print(images[0]['url']);
        final imageUrl = images[0]['url'];
        imageUrls.add(imageUrl);
        setState(() {
          imageUrls;

          print(imageUrls.length);
        });
      } else {
        // Eğer URL yoksa, tekrar deneme yapabilirsiniz
        fetchWaifuImage();
      }
    } catch (e) {
      // Hata yönetimi burada yapılabilir
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await saveImageToGallery(imageUrl);
                      Navigator.pop(context);
                    },
                    child: Text('Save to Gallery'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            topLeft: Radius.circular(20)),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await setWallpaper(imageUrl);
                      Navigator.pop(context);
                    },
                    child: Text('Set Walpaper'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveImageToGallery(String imageUrl) async {
    try {
      final imageBytes = await api1.fetchImageBytes(imageUrl);

      final result =
          await ImageGallerySaver.saveImage(Uint8List.fromList(imageBytes));
      print(result);
    } catch (e) {
      // Hata yönetimi burada yapılabilir
    }
  }

  String _platformVersion = 'Unknown';
  String __heightWidth = "Unknown";

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAppState() async {
    String platformVersion;
    String _heightWidth;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await WallpaperManager.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      int height = await WallpaperManager.getDesiredMinimumHeight();
      int width = await WallpaperManager.getDesiredMinimumWidth();
      _heightWidth =
          "Width = " + width.toString() + " Height = " + height.toString();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      _heightWidth = "Failed to get Height and Width";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      __heightWidth = _heightWidth;
      _platformVersion = platformVersion;
    });
  }

  Future<void> setWallpaper(url) async {
    try {
      int location = WallpaperManager
          .BOTH_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(url);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);
      print(result);
    } on PlatformException {}
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchWaifuImage();
    _timer = Timer.periodic(Duration(milliseconds: 202), (timer) {
      if (imageUrls.length < 30) {
        fetchWaifuImage();
      } else {}
    });
    initAppState();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      fetchWaifuImage();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    try {
      pic = _random.nextInt(imageUrls.length);
      super.setState(fn);
    } catch (e) {
      print(e);
    }

    imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waifu Walpaper'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            _scrollListener();
          }
          return true;
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: imageUrls.isNotEmpty
                    ? GridView.builder(
                        controller: _scrollController,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showImageDialog(context, imageUrls[index]);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: imageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: LoadingAnimationWidget.dotsTriangle(
                                    color: Color.fromARGB(154, 255, 105, 180),
                                    size: 50,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          );
                        },
                      )
                    : LoadingAnimationWidget.dotsTriangle(
                        color: Color.fromARGB(154, 255, 105, 180),
                        size: 200,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
