import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wallpaper_anime/api.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class chanell1 extends StatefulWidget {
  const chanell1({super.key});

  @override
  State<chanell1> createState() => _chanell1State();
}

class _chanell1State extends State<chanell1> {
  String selectedCategory = 'waifu';
  List<String> availableCategories = [
    'waifu',
    'neko',
    'shinobu',
    'megumin',
    'bully',
    'cuddle',
    'cry',
    'hug',
    'awoo',
    'kiss',
    'lick',
    'pat',
    'smug',
    'bonk',
    'yeet',
    'blush',
    'smile',
    'wave',
    'highfive',
    'handhold',
    'nom',
    'bite',
    'glomp',
    'slap',
    'kill',
    'kick',
    'happy',
    'wink',
    'poke',
    'dance',
    'cringe',
  ];
  List<String> imageUrls = [];
  ScrollController _scrollController = ScrollController();

  Future<void> fetchWaifuImages() async {
    try {
      final files = await api1.fetchImages(selectedCategory);
      setState(() {
        imageUrls.addAll(files);
      });
    } catch (e) {
      // Hata yönetimi burada yapılabilir
    }
  }

  Future<void> saveImageToGallery(String imageUrl) async {
    try {
      final imageBytes = await api1.fetchImageBytes(imageUrl);

      final result =
          await ImageGallerySaver.saveImage(Uint8List.fromList(imageBytes));
      print(result);
      _showSweetSnackBar(context, "Saved To Gallery");
    } catch (e) {
      // Hata yönetimi burada yapılabilir
    }
  }

  // Diğer işlevler burada devam eder

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchWaifuImages();
  }

  @override
  void dispose() {
    // CacheManager'ı temizleyin
    _cacheManager.dispose();
    super.dispose();
  }

  final CacheManager _cacheManager = DefaultCacheManager();
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
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            topLeft: Radius.circular(20)),
                      ),
                    ),
                    child: Text('Save to Gallery'),
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
              SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      fetchWaifuImages();
    }
  }

  void _showSweetSnackBar(BuildContext context, text) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.favorite, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.deepPurple)),
        ],
      ),
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      elevation: 4,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      appBar: AppBar(
        title: Text(
          '${selectedCategory.toUpperCase()} GALLERY (˃ᆺ˂)',
          style:
              TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableCategories.map((category) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = category;
                        imageUrls.clear();
                      });
                      fetchWaifuImages();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == category
                          ? Colors.deepPurple
                          : Color(0xFFFF69B4),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: selectedCategory == category
                            ? Colors.white
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
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
                        shrinkWrap: true,
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
