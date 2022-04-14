// ignore_for_file: unnecessary_new

import 'package:archf/apiS/LoginService.dart';
import 'package:archf/model/LoginM.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginPage extends StatefulWidget {
  const loginPage({Key? key}) : super(key: key);

  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final Scaffoldkey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool HidePass = true;
  late LoginM requestModel;
  bool isAPICallPros = false;
  String User = "";
  final TextEditingController Con = TextEditingController();
  late TextEditingController ConP = TextEditingController();

  String Pass = "";

  Future<SharedPreferences> Prefs() async {
    return await SharedPreferences.getInstance();
  }

  void S() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('PassWord', requestModel.password.toString());

    await prefs.setString('UserName', requestModel.username.toString());

  }

  @override
  void initState() {
    super.initState();


    void V() async {
      final Pref = await SharedPreferences.getInstance();
      final String? user = await Pref.getString('UserName');
      final String? password = await Pref.getString('PassWord');

      user.toString() == Null ? User = "" : User = user.toString();
      User == "null" ? User ="": User = User;

      Con.text = User;

      password.toString() == Null ? Pass = "" : Pass = password.toString();
      Pass == "null" ? Pass ="": Pass = Pass;
      ConP.text = Pass;
    }

    ;
    setState(() {
      V();
    });
    requestModel = new LoginM();
  }

  @override
  Widget build(BuildContext context) {
    final newTextTheme = Theme.of(context).textTheme.apply(
          bodyColor: Color.fromARGB(255, 188, 139, 70),
          displayColor: Color.fromARGB(255, 188, 139, 70),
        );
    return Scaffold(
      key: Scaffoldkey,
      backgroundColor: Color.fromARGB(255, 255, 241, 234),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  margin: EdgeInsets.symmetric(vertical: 85, horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).hintColor.withOpacity(0.2),
                            offset: Offset(0, 10),
                            blurRadius: 20)
                      ]),
                  child: Form(
                    key: globalFormKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 25,
                        ),

                        Image.asset(
                          "assets/images/EdLogo.png",
                          height: 100,
                        ),

                        // ignore: prefer_const_constructors
                        SizedBox(
                          height: 25,
                        ),
                        new TextFormField(
                          //Change this to Name if needed
                          keyboardType: TextInputType.emailAddress,
                          controller: Con,
                          onSaved: (input) => requestModel.username = input,

                          decoration: new InputDecoration(
                            hintText: "اسم المستخدم او البريد الالكتروني",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 188, 139, 70)
                                    .withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 188, 139, 70)),
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Color.fromARGB(255, 188, 139, 70),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        new TextFormField(
                          //Change this to Name if needed
                          keyboardType: TextInputType.text,
                          validator: (input) => input?.length == null
                              ? "كلمة المرور يجب ان تكون اكتر من ثلاثة حروف"
                              : null,
                          obscureText: HidePass,
                          controller: ConP,

                          onSaved: (input) => requestModel.password = input,

                          decoration: new InputDecoration(
                            hintText: "كلمة المرور",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 188, 139, 70)
                                    .withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 188, 139, 70)),
                            ),
                            prefixIcon: Icon(
                              Icons.password,
                              color: Color.fromARGB(255, 188, 139, 70),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  HidePass = !HidePass;
                                });
                              },
                              color: Color.fromARGB(255, 188, 139, 70)
                                  .withOpacity(0.4),
                              icon: Icon(HidePass
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),

                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 80,
                            ),
                            shape: StadiumBorder(),
                            backgroundColor: Color.fromARGB(255, 188, 139, 70),
                          ),
                          autofocus: true,
                          clipBehavior: Clip.none,
                          onPressed: () {
                            if (val()) {
                              setState(() {
                                isAPICallPros = true;
                              });
                              LoginService apilogin = new LoginService();
                              apilogin.login(requestModel).then((value) async =>
                                  {
                                    setState(() {
                                      isAPICallPros = false;
                                    }),
                                    if (!value.token!.isNotEmpty)
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content:
                                              const Text("خطا في تسجيل الدخول"),
                                          duration: const Duration(seconds: 2),
                                          action: SnackBarAction(
                                            label: 'اعادة',
                                            onPressed: () {},
                                          ),
                                        ))
                                      }
                                    else
                                      {
                                        (await SharedPreferences.getInstance()).setString("jwt", value.token.toString()),

                                        setState(() {
                                          S();
                                        }),



                                        Navigator.of(context)
                                            .pushReplacementNamed('/home'),

                                        //storage.read(key: 'jwt')
                                      }
                                  });

                              print(requestModel.toJson());
                            }
                          },
                          child: const Text("تسجيل دخول",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  bool val() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
