// ignore_for_file: unnecessary_new

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:archf/apiS/LoginService.dart';
import 'package:archf/model/LoginM.dart';
import 'package:flutter/material.dart';

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
  final storage = FlutterSecureStorage();
  final options = IOSOptions(accessibility: IOSAccessibility.first_unlock);

  @override
  void initState() {
    super.initState();
    var se = (storage.read(key: 'jwt')).toString();

    if ((storage.read(key: 'jwt')).toString() ==
        "Instance of 'Future<String?>'") {
      // Navigator.of(context).pushReplacementNamed('/login');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
    requestModel = new LoginM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Scaffoldkey,
      backgroundColor: Theme.of(context).colorScheme.secondary,
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
                      color: Theme.of(context).primaryColor,
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
                        Text(
                          "تسجيل دخول",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        // ignore: prefer_const_constructors
                        SizedBox(
                          height: 20,
                        ),
                        new TextFormField(
                          //Change this to Name if needed
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (input) => requestModel.username = input,

                          decoration: new InputDecoration(
                            hintText: "اسم المستخدم او البريد الالكتروني",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Theme.of(context).colorScheme.secondary,
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

                          onSaved: (input) => requestModel.password = input,

                          decoration: new InputDecoration(
                            hintText: "كلمة المرور",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                            prefixIcon: Icon(
                              Icons.password,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  HidePass = !HidePass;
                                });
                              },
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
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
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
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
                                        await storage.write(
                                            key: 'jwt',
                                            value: value.token,
                                            iOptions: options),
                                        globalFormKey.currentState?.reset(),
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
