import 'package:basics_firebase/piechart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:basics_firebase/core/controller/login_sign_up_controller.dart';
import 'package:basics_firebase/core/service/user_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:basics_firebase/bar%20graph/bar_graph.dart';
import '../../core/constant/app_route.dart';
import 'package:lottie/lottie.dart';



class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LoginSignUpController loginSignUpController =
  Get.find<LoginSignUpController>();
  final UserService _userService = UserService();
  static const primaryColor = Color(0xFF142477);
  final FirebaseAuth _auth = FirebaseAuth.instance;



  @override
  void dispose() {
    loginSignUpController.dispose();
    super.dispose();
  }
  static const IconData route = IconData(0xf0561, fontFamily: 'MaterialIcons');

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    String image ='';

    if(user!= null){print("User: $user");
    print("Display Name: ${user?.displayName}");
    print("Email: ${user?.email}");
    print("photo: ${user?.photoURL}");
    print("uid: ${user?.uid}");}

    Future<void> getSingleDocument() async {
      try {
        print("hellopew");
        // Get a reference to the Firestore collection
        CollectionReference collection = FirebaseFirestore.instance.collection('users');

        // Get a reference to the specific document using its document ID
        DocumentSnapshot document = await collection.doc(user!.uid).get();
        print("hellopew");
        // Check if the document exists
        if (document.exists) {
          print("hellopew1");
          // Access the data in the document
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          print(data);

          // You can access fields in the document like this:
          image = data['photoURL'];
          // ... and so on
          print("donr");

          print('Data from the document: $image');
        } else {
          print('Document does not exist');
        }
      } catch (e) {
        print('Error getting document: $e');
      }
    }
    getSingleDocument();
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      drawer: Drawer(
        surfaceTintColor: Colors.grey,
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader
              (
                decoration: BoxDecoration(
                  color: Color(0xFF142477),
                ),
                accountName: Text( user!.displayName ?? "default" ,style:
                TextStyle(
                  fontSize: 20,
                ),),
                accountEmail: Text(user!.email ?? "default",style:
                TextStyle(
                  fontSize: 15,
                ),)),
            ListTile(
              selectedColor: Color(0xFF7A82B0),
              onTap: (){
                Navigator.pushNamed(context, "/current");
              },
              leading: Icon(Icons.directions_bus),
              title: Text("Current Trip"),
            ),
            ListTile(
              onTap: (){
                Navigator.pushNamed(context, "/sos");
              },
              leading: Icon(Icons.sos),
              title: Text("SOS"),
            ),
            ListTile(
              onTap: (){
                Navigator.pushNamed(context, "/explore");
              },
              leading: Icon(Icons.explore),
              title: Text("Explore"),
            ),
            ListTile(
              onTap: (){
                Navigator.pushNamed(context, "/settings",arguments: loginSignUpController);
              },
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            ),
            ListTile(
              onTap: (){
                Navigator.pushNamed(context, "/changelang");
              },
              leading: Icon(Icons.language),
              title: Text("Change Language"),
            ),
            ListTile(
              onTap: () async {
                await loginSignUpController.logOut();
                Get.offAllNamed(AppRoutes.loginScreen);

              },
              leading: Icon(Icons.logout),
              title: Text("Logout"),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(0),
        children: [
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Text('Hello ${user.displayName}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white
                  )),
                  subtitle: Text('Pedal on!', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white
                  )),
                  trailing: FutureBuilder(
                    future: getSingleDocument(),
                    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // Image has been fetched, build the UI
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(image),
                        );
                      } else {
                        // Image is still loading, display a loading indicator or placeholder
                        return CircularProgressIndicator(); // You can replace this with your own loading widget
                      }
                    },
                  )

                ),
                const SizedBox(height: 30)
              ],
            ),
          ),
          Container(
            color: primaryColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(200)
                  )
              ),
              child:
              Column(
                children: [
                  SizedBox(height: 50,),
                  Text("Your Travel Summary",style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),),
                  SizedBox(
                      height:65,
                      width:double.infinity),
                  Lottie.asset(
                      "assets/cycle.json"
                  ,    height:200),
                  SizedBox(),
                  graph(),
                  SizedBox(
                    height: 65,
                    width: double.infinity,
                  ),
                  Piechart(),
                  GridView.count(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(0,30,0,0),
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 30,
                    children: [
                      //itemDashboard('Videos', CupertinoIcons.play_rectangle, Colors.deepOrange),
                      //itemDashboard('Analytics', CupertinoIcons.graph_circle, Colors.green),
                      //itemDashboard('Audience', CupertinoIcons.person_2, Colors.purple),
                      //itemDashboard('Comments', CupertinoIcons.chat_bubble_2, Colors.brown),
                      itemDashboard((){},'Cash conserved', CupertinoIcons.money_dollar_circle, Colors.indigo),
    itemDashboard(() {
    Navigator.pushNamed(context, '/current', arguments: {'image': image});
    }, 'Current Trip', route, Colors.teal),

    itemDashboard((){},'About', CupertinoIcons.question_circle, Colors.blue),
                      itemDashboard((){},'Contact', CupertinoIcons.phone, Colors.pinkAccent),
                    ],
                  ),
                ],
              ),

            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  itemDashboard(Function? function(),String title, IconData iconData, Color background) =>
      GestureDetector(
        onTap:
          function,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 5),
                    color: Theme.of(context).primaryColor.withOpacity(.2),
                    spreadRadius: 2,
                    blurRadius: 5
                )
              ]
          ),
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: Colors.white)
                ),
                const SizedBox(height: 8),
                Text(title.toUpperCase(), style: Theme.of(context).textTheme.titleSmall?.copyWith(color:Color(0xFF142477))),
              ],
            ),
          ),
        ),
      );
}
class graph extends StatefulWidget {
  @override
  State<graph> createState() => _graphState();
}

class _graphState extends State<graph> {
  List<double> weeklysummary =[
    4.4,
    2.5,
    42.42,
    10.50,
    100.20,
    88.90,
    90.10,
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue, // Border color
          width: 2.0,         // Border width
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: SizedBox(
        height:200,
        child:MyBarGraph(
            weeklysummary:weeklysummary
        ),
      ),
    );
  }
}


//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text('Users'),
//         backgroundColor: AppColors.background,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
//         child: Column(
//           children: <Widget>[
//             Expanded(child: UserListWidget(userService: _userService)),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () async {
//                 await _loginSignUpController.logOut();
//                 Get.offAllNamed(AppRoutes.loginScreen);
//               },
//               style: ElevatedButton.styleFrom(
//                 primary: AppColors.buttonBackground,
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//               ),
//               child: const Text(
//                 'Logout',
//                 style: TextStyle(
//                   color: AppColors.textColor,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 17,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class UserListWidget extends StatelessWidget {
//   final UserService userService;
//
//   UserListWidget({required this.userService});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<UserModel>>(
//       stream: userService.listenToUserUpdates(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           List<UserModel> users = snapshot.data ?? [];
//
//           return ListView.separated(
//             itemCount: users.length,
//             separatorBuilder: (context, index) => Divider(
//               thickness: 1,
//               color: AppColors.iconColor.withOpacity(0.5),
//             ),
//             itemBuilder: (context, index) {
//               UserModel user = users[index];
//               return UserListItem(user: user, userService: userService);
//             },
//           );
//         } else {
//           return const Center(
//             child: SizedBox(
//               width: 100,
//               height: 100,
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//       },
//     );
//   }
// }
//
// class UserListItem extends StatefulWidget {
//   final UserModel user;
//   final UserService userService;
//
//   UserListItem({required this.user, required this.userService});
//
//   @override
//   _UserListItemState createState() => _UserListItemState();
// }
//
// class _UserListItemState extends State<UserListItem> {
//   late TextEditingController nameController;
//
//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.user.name);
//   }
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundColor: AppColors.avatarColor,
//               backgroundImage: NetworkImage(widget.user.photoURL),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: TextField(
//                 decoration: const InputDecoration(
//                   hintText: 'Enter text here',
//                   border: InputBorder.none,
//                 ),
//                 controller: nameController,
//                 onChanged: (newName) async {
//                   await widget.userService
//                       .updateUserName(widget.user.uid, newName);
//                   setState(() {
//                     widget.user.name = newName;
//                   });
//                 },
//                 // onSubmitted: (newName) {
//                 //   widget.userService.updateUserName(widget.user.uid, newName);
//                 // },
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
