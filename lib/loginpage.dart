import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibc24/dbhelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ibc24/common/global.dart' as global;

class LoginPage extends StatefulWidget {
  @override
    LoginPageState createState() {
    return LoginPageState();
  }
}

class _LoginData{
  String identity = '';
  String password = '';
}
bool loader = false;
class LoginPageState extends State<LoginPage> {
  final dbhelper = Databasehelper.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  _LoginData _data = new _LoginData();

  @override
  void initState() {
    loader = false;
    super.initState();
  }

  void submit() async {
    setState(() {
      loader = true;
    });
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      String url = global.baseUrl+'/Authctrl/login';
      Map<String, String> headers = {"Content-type": "application/json"};
      String json = '{"identity": "'+_data.identity +'", "password": "'+_data.password+'"}';
      http.Response response = await http.post(url, headers: headers, body: json);
      int statusCode = response.statusCode;

      if(statusCode == 200){
          List body = jsonDecode(response.body);
          Map<String,dynamic> row = {
            Databasehelper.columnecode : _data.identity,
            Databasehelper.columnkey : body[0]['key'],
            Databasehelper.columndepartment : body[0]['department_id'],
            Databasehelper.columnversion : '1.0'
          };
          await dbhelper.insert(row);
          setState(() {
            loader = true;
          });
          Navigator.pushNamed(context, '/dashboard');
      } else {
        _showMyDialog();
      }
    }else{
      return;
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Authentication Alert!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Employee code or password not matched.'),
                Text('Please try again.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  loader = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loader ? Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 15.0,),
              Text('  Loading...',style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold,),),
            ],
          ),
        ),
        //child: CircularProgressIndicator(),
      ):Container(
        //decoration: BoxDecoration(color: Colors.white),
        child: Center(
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20.0),
                  child : Column(
                    children: <Widget>[
                      Container(
                        child: Image.asset('assets/images/logo.png'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                                key: Key('username'),
                                decoration: InputDecoration(
                                  icon: Icon(Icons.person,color:Colors.grey,),
                                  fillColor: Colors.blue,
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                  labelText: 'IDENTITY',
                                ),
                                initialValue: 'SBMMPL-00',
                                textCapitalization: TextCapitalization.words,
                                cursorColor:Colors.black,
                                //keyboardType: TextInputType.emailAddress,
                                keyboardType: TextInputType.text,
                                maxLength: 12,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your Identity';
                                  }
                                  return null;
                                },
                                onSaved: (String value) {
                                  this._data.identity = value;
                                }
                            ),
                            TextFormField(
                                key: Key('password'),
                                decoration: InputDecoration(
                                  icon: Icon(Icons.vpn_key,color:Colors.grey,),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                  labelText: 'PASSWORD',
                                ),
                                cursorColor:Colors.black,
                                //maxLength: 12,
                                obscureText: true,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                onSaved: (String value) {
                                  this._data.password = value;
                                }
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                MaterialButton(
                                  onPressed: submit,
                                  color: Colors.green[600],
                                  splashColor: Colors.red,
                                  child: Text('Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),),
                                ),
                                MaterialButton(
                                  onPressed: (){},
                                  child: Text('Forgot password',style: TextStyle(color: Colors.grey),),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )],
            ),
          ),
        ),
      )
    );
  }
}