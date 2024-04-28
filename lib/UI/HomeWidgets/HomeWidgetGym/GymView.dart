import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Styles/AppColors.dart';
import '../../../components/Buttons.dart';
import 'BookNow.dart';
import 'BookNowServices.dart';
import 'PurchaseGymSubscription.dart';

class GymView extends StatelessWidget {
  GymView({Key? key, this.gymObj, this.viewOnly = false}) : super(key: key);

  final gymObj;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    RxBool showMoreFacilities = false.obs;

    void open(BuildContext context, final int index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryPhotoViewWrapper(
            galleryItems: jsonDecode(gymObj['gym_gallery']),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            maxScale: 1,
            initialIndex: index,
            scrollDirection: Axis.horizontal,
          ),
        ),
      );
    }

    void testValues() {
      print(jsonDecode(gymObj['gym_gallery']));
    }
    print('===gymObj');
    print(gymObj);

    testValues();

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(
                  HttpClient.s3BaseUrl + gymObj['user']['avatar_url'],
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gymObj['gym_name'], style: TypographyStyles.title(20)),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "${gymObj['gym_city']}, ${gymObj['gym_country']}",
                    style: TypographyStyles.textWithWeight(13, FontWeight.w300),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              gymObj['gym_type'] == 'services'
                  ? Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text('${gymObj["gym_services"]["name"].toString().capitalizeFirst}',
                                style: TypographyStyles.title(20)),
                          ],
                        ),
                        Row(
                          children: [
                            Text('${gymObj["gym_services"]["description"].toString().capitalizeFirst}',
                                style: TypographyStyles.text(16)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: Get.width,
                          height: 200, // Optionally set the height if needed
                          child: CachedNetworkImage(
                            imageUrl: HttpClient.s3ResourcesBaseUrl +
                                gymObj["gym_services"]["image_path"],
                            fit: BoxFit
                                .cover, // This ensures the image covers the entire container
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('CONTACT', style: TypographyStyles.title(14)),
                ],
              ),
              SizedBox(height: 12),
              ElevatedButton(
                style: Get.isDarkMode
                    ? ButtonStyles.matButton(AppColors.primary2Color, 0)
                    : ButtonStyles.matButton(Colors.white, 1),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Icon(
                      //   Icons.location_on_outlined,
                      //   size: 30,
                      //   color: Get.isDarkMode
                      //       ? Themes.mainThemeColorAccent.shade100
                      //       : colors.Colors().lightBlack(1),
                      // ),
                      SvgPicture.asset("assets/svgs/location.svg",
                        width: 30,
                        height: 30,),
                      SizedBox(width: 13),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(gymObj['gym_address'],
                                style: TypographyStyles.title(16).copyWith(
                                  color: Get.isDarkMode
                                      ? Themes.mainThemeColorAccent.shade100
                                      : colors.Colors().lightBlack(1),
                                )),
                            SizedBox(
                              height: 5,
                            ),
                            // Text('SHOW IN MAP',
                            //   style: TypographyStyles.normalText(12, AppColors.accentColor),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () {},
              ),

              SizedBox(
                height: 10,
              ),

              ElevatedButton(
                style: Get.isDarkMode
                    ? ButtonStyles.matButton(AppColors.primary2Color, 0)
                    : ButtonStyles.matButton(Colors.white, 1),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 4,
                      ),
                      Icon(
                        Icons.phone,
                        size: 25,
                        color: Get.isDarkMode
                            ? Themes.mainThemeColorAccent.shade100
                            : colors.Colors().lightBlack(1),
                      ),
                      SizedBox(width: 13),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(gymObj['gym_phone'],
                              style: TypographyStyles.title(16).copyWith(
                                color: Get.isDarkMode
                                    ? Themes.mainThemeColorAccent.shade100
                                    : colors.Colors().lightBlack(1),
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'TAP TO CALL',
                            style: TypographyStyles.normalText(
                                12, AppColors.accentColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  final Uri launchUri = Uri(
                    scheme: 'tel',
                    path: "+${gymObj['gym_phone']}",
                  );
                  await launchUrl(launchUri);
                },
              ),

              SizedBox(height: 32),

              Row(
                children: [
                  Text('FACILITIES', style: TypographyStyles.title(14)),
                ],
              ),
              SizedBox(height: 20),

              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: showMoreFacilities.value
                        ? gymObj['gym_facilities'].length
                        : 0,
                    itemBuilder: (_, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: Text(gymObj['gym_facilities'][index]),
                          ),
                          Divider(
                            thickness: 1,
                          ),
                        ],
                      );
                    },
                  )),

              // Obx(()=>TextButton.icon(
              //   onPressed: (){
              //     showMoreFacilities.value = !showMoreFacilities.value;
              //   },
              //   icon: Icon(
              //     showMoreFacilities.value ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              //     color: Themes.mainThemeColorAccent.shade300,
              //   ),
              //   label: Text(
              //     showMoreFacilities.value ? "Show Less" : "Show More",
              //     style: TextStyle(
              //         color: Themes.mainThemeColorAccent.shade300
              //     ),
              //   ),
              // )),
              Obx(() => InkWell(
                    onTap: () {
                      showMoreFacilities.value = !showMoreFacilities.value;
                    },
                    child: Container(
                      width: 398,
                      height: 44,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: Get.isDarkMode
                            ? AppColors.primary2Color
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            showMoreFacilities.value
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Themes.mainThemeColorAccent.shade300,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            showMoreFacilities.value
                                ? "Show Less"
                                : "Show More",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

              Visibility(
                visible: gymObj['gym_facilities'].length == 0,
                child: SizedBox(height: 32),
              ),
              Visibility(
                visible: gymObj['gym_facilities'].length == 0,
                child: Text('No Facilities Added',
                    style:
                        TypographyStyles.normalText(16, Colors.grey.shade500)),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Text('GALLERY', style: TypographyStyles.title(14)),
                ],
              ),

              SizedBox(
                height: 16,
              ),

              Container(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: jsonDecode(gymObj['gym_gallery']).length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        open(context, index);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Get.isDarkMode
                              ? AppColors.primary2Color
                              : Colors.white,
                          child: Image.network(
                            HttpClient.s3GymGalleriesBaseUrl +
                                jsonDecode(gymObj['gym_gallery'])[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                      Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                ),
                width: Get.width,
                height: viewOnly ? 110 : 178,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          gymObj['gym_type'] == "exclusive"
                              ? Expanded(
                                  child: Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'MVR',
                                          style: TypographyStyles.title(20),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ' ${gymObj['hourly_rate']}',
                                              style: TypographyStyles.boldText(
                                                  22,
                                                  Get.isDarkMode
                                                      ? Themes
                                                          .mainThemeColorAccent
                                                          .shade100
                                                      : colors.Colors()
                                                          .lightBlack(1)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "HOURLY RATE",
                                        style: TypographyStyles.textWithWeight(
                                            16, FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          gymObj['gym_type'] == "exclusive"
                              ? Container(
                                  width: 2,
                                  height: 100,
                                  color: Themes.mainThemeColorAccent.shade300
                                      .withOpacity(0.2),
                                )
                              : SizedBox(),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "${gymObj['capacity']}",
                                  style: TypographyStyles.title(20),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "CAPACITY",
                                  style: TypographyStyles.textWithWeight(
                                      16, FontWeight.w400),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    viewOnly
                        ? SizedBox()
                        : SizedBox(
                            height: 20,
                          ),
                    Visibility(
                      visible: !viewOnly,
                      child: Buttons.yellowFlatButton(
                          onPressed: () {

                            if (gymObj['gym_type'] == 'exclusive') {
                              Get.to(() => BookNow(gymObj: gymObj));
                            } else if (gymObj['gym_type'] == 'services') {
                              Get.to(() => BookNowServices(gymObj: gymObj));
                            } else {
                              Get.to(() =>
                                  PurchaseGymSubscription(gymObj: gymObj));
                            }
                          },
                          label: "BOOK NOW",
                          width: Get.width),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
      /*bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Color(0xFF434343) : Color(0xFFDBDBDB),
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(25.0),
              topRight: const Radius.circular(25.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    gymObj['gym_type'] == "exclusive" ? Expanded(
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'MVR',
                              style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' ${gymObj['hourly_rate']}',
                                  style: TypographyStyles.boldText(22, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5,),
                          Text("HOURLY RATE",
                            style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().darkGrey(1),),
                          ),
                        ],
                      ),
                    ) : SizedBox(),
                    gymObj['gym_type'] == "exclusive" ? Container(
                      width: 2,
                      height: 50,
                      color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
                    ) : SizedBox(),
                    Expanded(
                      child: Column(
                        children: [
                          Text("${gymObj['capacity']}",
                            style: TypographyStyles.boldText(22, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                          ),
                          SizedBox(height: 5,),
                          Text("CAPACITY",
                            style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().darkGrey(1),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                Visibility(
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    color: Colors.transparent,
                    child: ElevatedButton(
                      style: ButtonStyles.primaryButton(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [SizedBox(width: 8), Text('BOOK NOW',
                          style: TextStyle(
                            color: Themes.mainThemeColorAccent.shade100,
                          ),
                        )],
                      ),
                      onPressed: () {
                        if (gymObj['gym_type'] == 'exclusive'){
                          Get.to(() => BookNow(gymObj: gymObj));
                        } else {
                          Get.to(()=> PurchaseGymSubscription(gymObj: gymObj));
                        }

                      },
                    ),
                  ),
                  visible: !viewOnly,
                ),
              ],
            ),
          ),
        ),
      ),*/
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: widget.backgroundDecoration,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Image ${currentIndex + 1} of ${widget.galleryItems.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  decoration: null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    return PhotoViewGalleryPageOptions.customChild(
      child: Container(
        width: 300,
        height: 300,
        child: Image.network(
          HttpClient.s3GymGalleriesBaseUrl + widget.galleryItems[index],
          height: 200.0,
        ),
      ),
      childSize: const Size(300, 300),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: index),
    );
  }
}
