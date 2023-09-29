import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import 'package:mindplex_app/blogs/like_dislike_interaction/like_dislike_controller.dart';
import 'package:mindplex_app/blogs/widgets/blog_content_display.dart';
import 'package:mindplex_app/models/blog_model.dart';

import '../blogs_controller.dart';
import '../comments/comment.dart';

class DetailsPage extends StatelessWidget {
  final Blog details;
  final int index;
  const DetailsPage({super.key, required this.details, required this.index});

  @override
  Widget build(BuildContext context) {
    LikeDislikeConroller likeDislikeConroller = Get.put(LikeDislikeConroller());
    BlogsController blogsController = Get.find();

    return Scaffold(
      backgroundColor: Color(0xFF0c2b46),
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            details.postTypeFormat == "text"
                ? const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF8aa7da),
                    size: 20,
                  )
                : details.postTypeFormat == "video"
                    ? const Icon(
                        Icons.videocam,
                        color: Color.fromARGB(255, 185, 127, 127),
                        size: 20,
                      )
                    : const Icon(
                        Icons.headphones,
                        color: Colors.green,
                        size: 20,
                      ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
            ),
            Text(
                details.postTypeFormat == "text"
                    ? "Read"
                    : details.postTypeFormat == "video"
                        ? "Watch "
                        : "Listen",
                style: TextStyle(fontWeight: FontWeight.w300)),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.13,
            )
          ],
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        backgroundColor: Color.fromARGB(255, 17, 126, 113),
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.82,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text(
                                    details.postTitle ?? "",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 73, 255, 179),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${details.publishedAt}' + " " ?? "",
                                      style: const TextStyle(
                                        color: Color.fromARGB(235, 247, 202, 0),
                                      ),
                                    ),
                                    Text(
                                      '${details.minToRead}' + "   " ?? "",
                                      style: const TextStyle(
                                        color: Color.fromARGB(235, 247, 202, 0),
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        details.likes.value.toString() +
                                            " likes  ",
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(235, 247, 202, 0),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '0 ',
                                      style: const TextStyle(
                                        color: Color.fromARGB(235, 247, 202, 0),
                                      ),
                                    ),
                                    Icon(
                                      Icons.tag_faces_outlined,
                                      color: Color.fromARGB(235, 247, 202, 0),
                                    ),
                                  ],
                                ),
                                Container(
                                  child: Text(
                                    details.overview ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Divider(
                                  thickness: 2,
                                  color: Colors.white,
                                ),
                                Container(
                                    height: 150,
                                    width: 600,
                                    child: Image.network(
                                        fit: BoxFit.cover,
                                        details.banner ?? ""))
                              ],
                            ),
                          ),

                          // Place to Displaye Content
                          Material(
                            color: Color(0xFF0c2b46),
                            child: BlogContentDisplay(
                              data: details.content ?? [],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                margin: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.green,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        details.authorAvatar ?? ""),
                                  ),
                                ),
                              ),
                              Container(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * .40,
                                  margin: EdgeInsets.only(right: 3, top: 30),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        details.authorDisplayName!,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w200,
                                            fontStyle: FontStyle.normal,
                                            color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        details.authorBio ?? "",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w200),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 30, right: 30, bottom: 10),
                                margin: EdgeInsets.only(top: 15),
                                decoration: const BoxDecoration(
                                    color: Color(0xFF0f3e57),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: const Text(
                                  'Follow',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ),
              Obx(
                () => likeDislikeConroller.showEmoji.value
                    ? Positioned(
                        bottom: MediaQuery.of(context).size.height * 0.005,
                        left: MediaQuery.of(context).size.width * 0.4,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 120,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(80, 218, 210, 209),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: GridView.count(
                            crossAxisCount: 3,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  likeDislikeConroller.changeEmoji(Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ));
                                },
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  likeDislikeConroller.changeEmoji(
                                    Icon(
                                      Icons.sentiment_very_satisfied_rounded,
                                      color: Colors.yellow,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.sentiment_very_satisfied_rounded,
                                  color: Colors.yellow,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  likeDislikeConroller.changeEmoji(Icon(
                                    Icons.sentiment_dissatisfied,
                                    color: Colors.red,
                                  ));
                                },
                                child: Icon(
                                  Icons.sentiment_dissatisfied,
                                  color: Colors.red,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  likeDislikeConroller.changeEmoji(
                                    Icon(
                                      Icons.percent,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.percent,
                                  color: Colors.red,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  likeDislikeConroller.changeEmoji(
                                    Icon(
                                      Icons.heart_broken,
                                      fill: 0.24,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.heart_broken,
                                  fill: 0.24,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.07,
            color: Color.fromARGB(255, 17, 126, 113),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    onPressed: () {
                      if (details.isUserLiked.value == true) {
                        likeDislikeConroller.removePreviousInteraction(
                            blog: details,
                            index: index,
                            articleSlug: details.slug ?? "",
                            interction: "L");
                      } else if (details.isUserLiked.value == false) {
                        likeDislikeConroller.likeDislikeArticle(
                            blog: details,
                            index: index,
                            articleSlug: details.slug ?? "",
                            interction: "L");
                      }
                    },
                    icon: (details.isUserLiked.value)
                        ? Icon(
                            Icons.thumb_up_off_alt_rounded,
                            color: Color.fromARGB(255, 73, 255, 179),
                          )
                        : Icon(
                            Icons.thumb_up_off_alt_outlined,
                            color: Colors.white,
                          ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    onPressed: () {
                      if (details.isUserDisliked.value == true) {
                        likeDislikeConroller.removePreviousInteraction(
                            blog: details,
                            index: index,
                            articleSlug: details.slug ?? "",
                            interction: "L");
                      } else if (details.isUserDisliked.value == false) {
                        likeDislikeConroller.likeDislikeArticle(
                            blog: details,
                            index: index,
                            articleSlug: details.slug ?? "",
                            interction: "D");
                      }

                      ;
                    },
                    icon: details.isUserDisliked.value
                        ? Icon(
                            Icons.thumb_down,
                            color: const Color.fromARGB(255, 230, 96, 86),
                          )
                        : Icon(
                            Icons.thumb_down_off_alt_outlined,
                            color: Colors.white,
                          ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      Share.share(details.url ?? "",
                          subject: 'Sharing blog to your media appearance');
                    },
                    child: Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    onPressed: () => Get.bottomSheet(
                      MyWidgetComment(post_slug: details.slug!),
                      isScrollControlled: true,
                      ignoreSafeArea: false,
                    ),
                    icon: Icon(
                      Icons.mode_comment_outlined,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      likeDislikeConroller.showEmoji.value =
                          !likeDislikeConroller.showEmoji.value;
                    },
                    child: Obx(
                      () => likeDislikeConroller.currentEmoji.isNotEmpty
                          ? likeDislikeConroller.currentEmoji.value[0]
                          : Icon(
                              Icons.add_reaction_outlined,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Icon(
                    Icons.check_box_outline_blank,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Icon(
                    Icons.bookmark_add,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
