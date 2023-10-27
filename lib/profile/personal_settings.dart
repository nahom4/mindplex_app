import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindplex_app/models/social_link.dart';
import 'package:mindplex_app/profile/user_profile_controller.dart';
import 'package:mindplex_app/services/local_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/auth_controller/auth_controller.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../services/api_services.dart';
import '../utils/box_icons.dart';
import '../utils/colors.dart';

class PersonalSettingsPage extends StatefulWidget {
  const PersonalSettingsPage({Key? key}) : super(key: key);

  @override
  State<PersonalSettingsPage> createState() => _PersonalSettingsPageState();
}
final _formKey = GlobalKey<FormState>();
String? first_name, last_name, biography,education;
List<String>? interests = [];
List<String> genderChoices = ['Male','Female','Non-binary','Prefer not to say', 'Other'];
List<String> educationChoices = ['Doctorate Degree', 'Master\'s Degree', 'Bachelor\'s Degree' , 'Certificate or Diploma' , 'High School'];
String? nameError, lastNameError, ageError,socialLinkError;

bool _isUpdating = false;

class _PersonalSettingsPageState extends State<PersonalSettingsPage> {
  Rx<LocalStorage> localStorage =
      LocalStorage(flutterSecureStorage: FlutterSecureStorage()).obs;
  String? title;
  bool isSaved = false;
  bool isLinkAdded = false;
  bool isValueSet = false;
  AuthController authController = Get.put(AuthController());

  ProfileController profileController = Get.put(ProfileController());

  late int age;
  late String gender;
  String social = " ";
  SocialLink socialLink = SocialLink();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    profileController.getAuthenticatedUser();
    first_name = profileController.authenticatedUser.value.firstName??" ";
    last_name = profileController.authenticatedUser.value.lastName??" ";
    fetchUserProfile();
  }
  int mapEducation(String apiResponse){
    if(apiResponse == "Degree"){
      return 2;
    }
    return -1;
  }
  Future<void> fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    ProfileController profileController = Get.put(ProfileController());

    try {
      UserProfile userProfile = await _apiService.fetchUserProfile(userName:profileController.authenticatedUser.value.username!);

      setState(() {
        age = userProfile.age!;
        gender = userProfile.gender == ""?genderChoices[3]:userProfile.gender!;
        biography = userProfile.biography!;
        interests = userProfile.interests!;
        education = educationChoices[mapEducation(userProfile.education!.educationalBackground!)];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Handle any errors that occurred during the API request
      print('Error fetching user profile: $e');
    }
  }
  Future<String> updateUserProfile(firstName,lastName) async {
    setState(() {
      _isUpdating = true;
    });
    try {
      UserProfile updatedProfile = UserProfile(
        // Set the updated values for the profile properties
        firstName: firstName,
        lastName: lastName,
        age: age,
        gender: gender,
        biography: biography
      );
      String updatedValues = await _apiService.updateUserProfile(
        updatedProfile: updatedProfile,
      );
      setState(() {
        _isUpdating = false;
      });
      localStorage.value.updateUserInfo(firstName: firstName,lastName: lastName);
      return updatedValues;
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      print('Error updating user profile: $e');
      return '';
    }
  }


  void _saveSelectedChoice(String choice) {
    setState(() {
      education = choice;
    });
  }
  void _saveSelectedChoiceGender(String choice) {
    setState(() {
      gender = choice;
    });
  }


  @override
  Widget build(BuildContext context) {
    final firstName = profileController.authenticatedUser.value.firstName ?? " ";
    final lastName = profileController.authenticatedUser.value.lastName??" ";
    final name = firstName + " " + lastName;
    if(_isLoading){
      return Scaffold(backgroundColor: mainBackgroundColor,body: Center(child: CircularProgressIndicator()),);
    }
    return Scaffold(
      backgroundColor: mainBackgroundColor,
      body: SingleChildScrollView(
        child: Column(children: [
          Column(
            children: [
              SizedBox(height: 10,),
              buildImage(),
              SizedBox(height: 15,),
              buildAddPhoto()
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(children: [
                  const SizedBox(height: 10),
                  _container(context, false, null, name, TextInputType.name, name, "name","", (() {})),
                  nameError != null && isSaved ? errorMessage(nameError.toString()) : Container(),
                  _container(context, false, null, biography, TextInputType.name, biography, "bio", "",(() {}),maxLines: 8),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Education",
                            style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w800,
                                fontSize: 20
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity, // Cover the whole width
                        decoration: BoxDecoration(
                          color: mainBackgroundColor,
                          borderRadius: BorderRadius.circular(15), // Apply border radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),// Set the background color to white
                        child: Align(
                          alignment: Alignment.center, // Align the dropdown to the center
                          child: Container(
                            width: double.infinity, // Set the width of the dropdown
                            decoration: BoxDecoration(
                              color: mainBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.amber,width: 2.0),// Apply border radius
                            ),
                            child: DropdownButton<String>(
                              value: education,// Set the initial value to the first choice (placeholder)
                              items: educationChoices.map((String choice) {
                                return DropdownMenuItem<String>(
                                  value: choice,
                                  child:  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(choice,style: TextStyle(fontSize: 16),),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                _saveSelectedChoice(newValue!);
                              },
                              style: TextStyle(color: Colors.white), // Customize the text color
                              dropdownColor: Colors.purpleAccent, // Customize the dropdown menu's background color
                              icon: Icon(Icons.arrow_drop_down,color: Colors.amber,), // Custom dropdown arrow icon
                              iconSize: 40, // Set the icon size as needed
                              isExpanded: true, // Expand the dropdown to cover the width
                              underline: SizedBox(), // Remove the default underline
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  _container(
                    context,
                    false,
                    null,
                    age==0?"":age.toString(),
                    TextInputType.number,
                    age.toString(),
                    "age",
                    "",
                    (() {}),
                  ),
                  ageError != null && isSaved ? errorMessage(ageError.toString()) : Container(),
                  SizedBox(height: 20,),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Gender",
                            style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w800,
                                fontSize: 20
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity, // Cover the whole width
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15), // Apply border radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),// Set the background color to white
                        child: Align(
                          alignment: Alignment.center, // Align the dropdown to the center
                          child: Container(
                            width: double.infinity, // Set the width of the dropdown
                            decoration: BoxDecoration(
                              color: mainBackgroundColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.amber,width: 2.0),// Apply border radius
                            ),
                            child: DropdownButton<String>(
                              value: gender, // Set the initial value to the first choice (placeholder)
                              items: genderChoices.map((String choice) {
                                return DropdownMenuItem<String>(
                                  value: choice,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(choice,style: TextStyle(fontSize: 16),),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                _saveSelectedChoiceGender(newValue!);
                              },
                              style: TextStyle(color: Colors.white), // Customize the text color
                              dropdownColor: Colors.purpleAccent, // Customize the dropdown menu's background color
                              icon: Icon(Icons.arrow_drop_down,color: Colors.amber,), // Custom dropdown arrow icon
                              iconSize: 40, // Set the icon size as needed
                              isExpanded: true, // Expand the dropdown to cover the width
                              underline: SizedBox(), // Remove the default underline
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  InterestDropdown(selectedItems: interests!,),
                  _container(context, false, null, "", TextInputType.name, null, "social", "Enter your social links here",() { }),
                  socialLinkError != null && isLinkAdded ? errorMessage(socialLinkError.toString()) : Container(),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          GestureDetector(
                              child: Icon(socialLink.linkedinLink != null?FontAwesome.linkedin:null,size: 35,color: Colors.amber),
                              onTap:  () async {
                                await launchUrl(Uri.parse(socialLink.linkedinLink!));
                              },
                          ),
                          SizedBox(width: socialLink.linkedinLink == null?0:10,),
                          GestureDetector(
                              child: Icon(socialLink.facebookLink != null?FontAwesome.facebook:null,size: 35,color: Colors.amber),
                            onTap:  () async {
                              await launchUrl(Uri.parse(socialLink.facebookLink!));
                            },
                          ),
                            SizedBox(width: socialLink.facebookLink == null?0:10,),
                          GestureDetector(
                            child: SvgPicture.asset(
                              'assets/icons/x-twitter.svg',
                              width: socialLink.twitterLink == null?0:35,
                              height: socialLink.twitterLink == null?0:35,
                              color: Colors.amber,
                            ),
                            onTap:  () async {
                              await launchUrl(Uri.parse(socialLink.twitterLink!));
                            },
                          )
                        ],),
                        buildButton("Add link", () {
                          isLinkAdded = false;
                          final isValidLink = socialLinkError == null;
                          setState(() {
                            isLinkAdded = true;
                          });
                          if(isValidLink){
                            print(social);
                            RegExp facebookRegex = RegExp(
                              r'^(?:https?:\/\/)?(?:www\.|m\.)?facebook\.com\/',
                              caseSensitive: false,
                            );
                            RegExp twitterRegex = RegExp(
                              r'^(?:https?:\/\/)?(?:www\.|m\.)?twitter\.com\/',
                              caseSensitive: false,
                            );
                            RegExp linkedinRegex = RegExp(
                              r'^(?:https?:\/\/)?(?:www\.|m\.)?linkedin\.com\/',
                              caseSensitive: false,
                            );
                           if (facebookRegex.hasMatch(social)){
                             setState(() {
                               socialLink.facebookLink = social;
                             });
                           }
                           else if (twitterRegex.hasMatch(social)){
                              setState(() {
                                socialLink.twitterLink = social;
                              });
                            }
                           else if (linkedinRegex.hasMatch(social)){
                              setState(() {
                                socialLink.linkedinLink = social;
                              });
                            }
                           else{

                           }
                          }
                        }, Colors.amber, true)

                      ],
                    ),
                  )
                ])),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Row(
              children: [
                buildButton("Cancel", () async {
                  print("account deleted");
                }, Colors.blueAccent, false),
                Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: buildButton("Save", (() async {
                      isSaved = false;
                      final isValidForm = _formKey.currentState!.validate();
                      setState(() {
                        isSaved = true;
                      });
                      if (isValidForm) {
                        print("first name " + first_name!);
                        print("last name " + last_name! );
                        updateUserProfile(first_name,last_name).then((String updatedValues) {
                          print('Updated values: $updatedValues');
                          var snackBar = SnackBar(
                            content: Text(
                              'personal settings successfully set',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height - 100,
                              left: 10,
                              right: 10,
                            ),
                            action: SnackBarAction(
                              label: 'ok',
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              },
                            ),);
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }).catchError((error) {
                          print('Error updating user profile: $error');
                        });

                      }
                    }), Colors.blueAccent.shade200,true)
                )
              ],
            ),
          ),

        ]),
      ),
    );
  }
  buildAddPhoto() {
    return Container(
        child: InkWell(
            onTap: () async {
              String? filePath = await pickImage();
              // let's show a loading dialog with a loading message
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) => const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              );
              // let's upload the image to the api
              if (filePath != null) {
                // let's try to upload the image

                // try {
                //   String imageUrl = await ApiProvider().changeProfilePicture(filePath);
                //   setState(() {
                //     image = imageUrl;
                //   });
                //   UserPreferences.setProfilePicture(imageUrl);
                //   var landingPageController = Get.find<LandingPageController>();
                //   landingPageController.profileImage = imageUrl;
                // } catch (error) {
                //   // let's show an error message
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //       content: Text("Failed to upload image. Try again later."),
                //     ),
                //   );
                // }
              } else {
                // display a snackbar with error message (to the user)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid file selected."),
                  ),
                );
              }
              // pop the dialog
              Navigator.pop(context);
            },
            child: Text("Change Picture",style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w400),)),
    );
  }
  Future<String?> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    String filepath = '';
    if (pickedImage != null) {
      filepath = pickedImage.path;
      return filepath;
    }
    return null;
  }
  Widget buildImage() {
    ImageProvider<Object> image = NetworkImage(
      profileController.authenticatedUser.value.image ??
          "assets/images/profile.PNG",
    );
    return CircleAvatar(
      radius: 45,
      foregroundImage: image,
      child: const Material(
        color: Color.fromARGB(0, 231, 6, 6), //
      ),
    );
  }
  String? hintText(String? inputType) {
    if (inputType == "name") {
      return "Name";
    }
    else if (inputType == "bio") {
      return "Biography";
    }else if (inputType == "age") {
      return "Age";
    }
    else if(inputType == "social")
    return "Social links";
    return null;
  }

  Widget _container(BuildContext context, bool readOnly,TextEditingController? controller, String? initialValue, TextInputType? inputType,
      String? value, String? type, String hint, VoidCallback onTap,
      {maxLines = 1}) {
    TextTheme textTheme = Theme.of(context).textTheme;
    Color secondbackgroundColor = Theme.of(context).cardColor;
    IconThemeData icontheme = Theme.of(context).iconTheme;

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              hintText(type)??" ",
              style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.w800,
                  fontSize: 20
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
            decoration: BoxDecoration(
              color: secondbackgroundColor,
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(1, 1),
                  color: const Color.fromARGB(54, 188, 187, 187),
                )
              ],
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    readOnly: readOnly,
                    controller: controller,
                    initialValue: initialValue,
                    keyboardType: inputType,
                    maxLines: maxLines,
                    style: textTheme.headline2?.copyWith(fontSize: 15, fontWeight: FontWeight.w400,color: Colors.white),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: mainBackgroundColor,
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        errorStyle: const TextStyle(fontSize: 0.01,color: Colors.red),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.amber,width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ) ,
                        contentPadding: const EdgeInsets.only(left: 25, top: 10, bottom: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: TextStyle(color: Colors.grey),
                        suffix: type == 'age'?Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text("Years",style: TextStyle(fontSize:15,fontWeight: FontWeight.w600,color: Colors.amber),),
                        ):null
                        ),
                    onTap: onTap,
                    onChanged: (value) {
                      if (type == "name") {
                        List<String> parts = value.split(' '); // Split the text into two parts at the first whitespace
                        if (parts.length > 1) {
                          first_name = parts[0].trim(); // Remove leading and trailing whitespace from the first part
                          last_name = parts[1].trim(); // Remove leading and trailing whitespace from the second part
                        }
                        else if(parts.length == 1){
                          first_name = parts[0];
                        }
                      } else if (type == "age") {
                        age = int.parse(value);
                      }
                      else if(type == "bio"){
                        biography = value;
                      }
                      else if(type == "social"){
                        social = value;
                      }
                    },
                    validator: ((value) {
                      if (type == "name") {
                        if (value != null && value.length < 1) {
                          nameError = "Please enter your First name";
                          return nameError;
                        }
                        else if(value!.trim().split(" ").length > 2 ){
                          nameError = "Please specify first and last name only";
                          return nameError;
                        }
                        else {
                          nameError = null;
                          return null;
                        }
                      }
                      else if (type == "age") {
                        if (value != null && value.length < 1) {
                          ageError = "Please enter your age";
                          return ageError;
                        }
                        else if (!isNumeric(value!)) {
                          ageError = 'Please enter a valid age';
                          return ageError;
                        }else {
                          ageError = null;
                          return null;
                        }
                      }
                      else if(type == "social"){
                        if(value == ""){
                          return null;
                        }
                        if(value != null && !value.startsWith("https://www",0)){
                          socialLinkError = "invalid link make sure your link start with https://www";
                          return socialLinkError;
                        }
                        else{
                          socialLinkError = null;
                          return null;
                        }
                      }
                      return null;
                    })))),
      ],
    );
  }
}
bool isNumeric(String value) {
  return double.tryParse(value) != null;
}
Widget buildButton(String label, VoidCallback onTap, Color color1,bool fill) {
  return SizedBox(
    key: UniqueKey(),
    width:150,
    height:label == "Add link"?35: 50,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: fill?BoxDecoration(
          color: color1,
          borderRadius: BorderRadius.circular(10),
        ):BoxDecoration(
            border: Border.all(color: color1),
            borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
          child: Text(
            label,
            style:fill?TextStyle(color:Colors.white, fontSize: 20):TextStyle(color: color1,fontSize: 20),
          ),
        ),
      ),
    ),
  );
}
Widget errorMessage(String? error) {
  return Container(
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(top: 5, left: 10),
      child: Text(
        error.toString(),
        style: const TextStyle(color: Colors.red),
      ));
}

snackbar(Text title, Text message) {
  return Get.snackbar("", "",
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
      borderWidth: 2,
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.blue,
      titleText: title,
      messageText: message,
      margin: const EdgeInsets.only(top: 12, left: 15, right: 15, bottom: 15));
}

class InterestDropdown extends StatefulWidget {
  late final List<String> selectedItems;
  InterestDropdown({required this.selectedItems});

  @override
  _InterestDropdownState createState() => _InterestDropdownState();
}

class _InterestDropdownState extends State<InterestDropdown> {
  List<String> dropdownItems = [
    'Classroom Study',
    'Software Development',
    'Hardware Development',
    'Blockchain Development',
    'Robotics',
    'Design',
    'Research',
    'Trading',
    'Marketing',
    'Partnership',
    'Finance And Investing',
    'Fashion In Wearable Tech',
    'Love In Virtual Word',
    'Dating Robots And Other Tech Entities',
    'Fitness Technologies',
    'Travel',
    'AI Art',
    '3D Food Printing',
    'Space',
    'Law',
    'Journalism',
    'Philosophy And Related',
    'Healthcare And Related',
    'Agriculture And Related',
    'Accounting',
    'Environmental And Wildlife',
    'Governance',
    'Military',
    'Commerce',
    'Art',
  ];
  List<String> searchOutputs =[];

  bool showDropDown = false;
  TextEditingController searchText = TextEditingController();
  void updateInterests(String query) {
    setState(() {
      searchOutputs = dropdownItems
          .where((interest) => interest.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
@override
  void initState() {
    searchOutputs = dropdownItems;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "Interests",
              style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.w800,
                  fontSize: 20
              ),
            ),
          ),
        ),
        SizedBox(height: 10,),
        InkWell(
          onTap: (){
            setState(() {
              showDropDown = !showDropDown;
            });
            },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color:Colors.amber,width: 2.0),
              color: mainBackgroundColor,
              borderRadius: BorderRadius.circular(15), // Apply border radius
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      children: List.generate(widget.selectedItems.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: mainBackgroundColor,
                              border: Border.all(color: Colors.purpleAccent),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.all(8.0), // Adjust the padding as needed
                            child: Text(
                              widget.selectedItems[index],
                              style: TextStyle(color: Colors.purpleAccent),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Icon(showDropDown?Icons.arrow_drop_up:Icons.arrow_drop_down,size: 40,color: Colors.amber,),

                ],
          ),),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Container(
            width: double.infinity,
            height: showDropDown?260:0,
            decoration: BoxDecoration(
              color: Color.fromARGB(100, 130, 16, 185),
              border: Border.all(
                  color: Color.fromARGB(100, 52, 5, 112),
                  width: 1.5,
              ),
              borderRadius: BorderRadius.circular(15)
            ),
            child: showDropDown?Padding(
              padding: const EdgeInsets.all(15.0),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "Search your interest here...",
                              hintStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            controller: searchText,
                            onChanged: (value){
                              updateInterests(value);
                            },
                          ),
                        ),
                         GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 4.0, // Adjust this value to change the aspect ratio of the checkboxes
                            ),
                            itemCount: searchOutputs.length, // Replace 'choices' with your list of choices
                            itemBuilder: (context, index) {
                              return Theme(
                                data: ThemeData(unselectedWidgetColor: Colors.white,checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.all(Colors.white))),
                                child: CheckboxListTile(
                                  checkColor: Colors.white,
                                  activeColor: Colors.purpleAccent,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(searchOutputs[index],style: TextStyle(color: Colors.white),),
                                  value: widget.selectedItems.contains(searchOutputs[index])?true:false,
                                  onChanged: (newValue) {
                                    setState(() {
                                      if(newValue == true){
                                        widget.selectedItems.add(searchOutputs[index]);
                                      }
                                      else{
                                        widget.selectedItems.remove(searchOutputs[index]);
                                      }
                                      print(widget.selectedItems);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ):null,
          ),
        )
      ],
    );
  }
}
