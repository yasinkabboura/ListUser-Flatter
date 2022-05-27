import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Users'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
  }

class _MyHomePageState extends State<MyHomePage> {

  Future<List<User>> _getUsers() async {


    var data = await http.get(Uri.parse("https://randomuser.me/api/?results=10"));
    final extractedData = ApiResponse.fromJson(json.decode(data.body) as Map<String, dynamic>);
    print("extra"+extractedData.myUsers[0].country);


    return extractedData.myUsers;

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Container(
        child: FutureBuilder(
          future: _getUsers(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            print(snapshot.data);
            if(snapshot.data == null){
              return Container(
                  child: Center(
                      child: Text("Loading...")
                  )
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card (child:ListTile(
                    leading: CircleAvatar(backgroundImage:
                    NetworkImage(snapshot.data[index].picture)),
                    title: Text(snapshot.data[index].name),
                    subtitle: Text(snapshot.data[index].email),
                    onTap: (){
                      Navigator.push(context,
                          new MaterialPageRoute(builder: (context) => DetailPage(snapshot.data[index]))
                      );
                    },
                  ));
                },
              );
            }
          },
        ),
      ),
    );
  }
}

  class DetailPage extends StatelessWidget {

   final User user;

  DetailPage(this.user);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(user.name),
        ),
      body: Container(
          width: double.infinity,
          // Symetric Padding
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(140),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 10,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 120,
        backgroundImage: NetworkImage(user.picture),
      ),
    ),
    SizedBox(
    height: 20,
    ),
    Text(
    user.name,
    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
    ),

    SizedBox(
    height: 18,
    ),
    Text("Email: "+user.email,style: TextStyle(fontSize: 20)),
    Text("Lives in: "+user.city+" "+user.country,style: TextStyle(fontSize: 20)),
    Text("Phone number: "+user.phone,style: TextStyle(fontSize: 20)),
    Text("Age: "+user.age.toString(),style: TextStyle(fontSize: 20)),
    ])));
}  }



class User {
  final String name;
  final String picture;
  final String email;
  final String phone;
  final String city;
  final String country;
  final int age;



  User( this.name,this.picture, this.email,this.phone,this.city,this.country, this.age);
  factory User.fromJson(Map<String, dynamic> u) => User(
    u["name"]["first"]+" "+u["name"]["last"],
    u["picture"]["large"],
    u["email"],
    u["cell"],
    u["location"]["city"],
    u["location"]["country"],
    u["dob"]["age"],
  );

}

class ApiResponse {
  ApiResponse({
    required this.myUsers,
  });

  List<User> myUsers;

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
    myUsers: List<User>.from(
      json["results"].map((x) => User.fromJson(x)),
    ),
  );
}



