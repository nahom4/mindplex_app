import 'package:flutter/material.dart';

import '../blogs_controller.dart';

class BlogCard extends StatelessWidget {
  const BlogCard({
    super.key,
    required this.blogsController,
    required this.index,
  });

  final BlogsController blogsController;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      blogsController.filteredBlogs[index].authorAvatar ?? ""),
                  radius: 20,
                  backgroundColor: Colors.black,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            blogsController
                                    .filteredBlogs[index].authorDisplayName ??
                                "",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            blogsController
                                    .filteredBlogs[index].authorUsername ??
                                "",
                            style: TextStyle(
                              color: Color.fromARGB(255, 123, 122, 122),
                            ),
                          ),
                          Text(
                            blogsController.filteredBlogs[index].publishedAt ??
                                "",
                            style: TextStyle(
                              color: Color.fromARGB(255, 123, 122, 122),
                            ),
                          ),
                          Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          )
                        ],
                      ),
                      Text(
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          blogsController.filteredBlogs[index].postTitle ?? ""),
                      Text(
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          blogsController.filteredBlogs[index].overview ?? ""),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        blogsController.filteredBlogs[index].minToRead ?? "",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(blogsController
                                            .filteredBlogs[index]
                                            .thumbnailImage ??
                                        ""))),
                            height: 170,
                            width: 400,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 1, right: 8.0),
                              child: Container(
                                  height: 60,
                                  width: 35,
                                  margin: EdgeInsets.only(left: 10, top: 0),
                                  decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      )),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: blogsController
                                                    .filteredBlogs[index]
                                                    .postTypeFormat ==
                                                "text"
                                            ? const Icon(
                                                Icons.description_outlined,
                                                color: Color(0xFF8aa7da),
                                                size: 20,
                                              )
                                            : blogsController
                                                        .filteredBlogs[index]
                                                        .postTypeFormat ==
                                                    "video"
                                                ? const Icon(
                                                    Icons.videocam,
                                                    color: Color.fromARGB(
                                                        255, 185, 127, 127),
                                                    size: 20,
                                                  )
                                                : const Icon(
                                                    Icons.headphones,
                                                    color: Colors.green,
                                                    size: 20,
                                                  ),
                                      )
                                    ],
                                  )),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                color: Colors.white,
                                Icons.comment,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                blogsController.filteredBlogs[index].comments
                                    .toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                color: Colors.white,
                                Icons.screen_rotation_alt_sharp,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                blogsController.filteredBlogs[index].views
                                    .toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                color: Colors.white,
                                Icons.favorite_border_outlined,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                blogsController.filteredBlogs[index].likes
                                    .toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                color: Colors.white,
                                Icons.bar_chart_sharp,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                "195.9",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Icon(
                            color: Colors.white,
                            Icons.file_upload_outlined,
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            Divider(
              color: Colors.white,
              thickness: 1,
            )
          ],
        ),
      ),
    );
  }
}
