import 'package:flutter/material.dart';
import 'package:get/get.dart';
class Authform extends StatefulWidget{
  const Authform({Key? key}) : super(key: key);

  @override
  State<Authform> createState() => _AuthformState();
}

class _AuthformState extends State<Authform> {
  final _formkey=GlobalKey<FormState>();
  bool _islogin=true;
  String _email="";
  String _password="";
  String _username="";
  void submit(){
    final isvalid=_formkey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if(isvalid){
      _formkey.currentState!.save();
      print(_email);
      print(_username);
      print(_password);
    }
  }
  void cahngestate(){
    FocusScope.of(context).unfocus();
    setState(() {
    _islogin^=true;  
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding:const EdgeInsets.all(16),
          child: Form(key: _formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key:const ValueKey('email'),
                  onSaved: (val)=>_email=val??'',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if(value!.isEmpty||!value.contains('@')||!value.contains('.'))
                    return  'enter valid email';
                    return null;
                  },
                decoration:const InputDecoration(
                  hintText: 'Email Address'
                ),
                ),
                if(_islogin)
                TextFormField(
                  key:const ValueKey('username'),
                  onSaved: (newValue) => _username=newValue??'',
                decoration:const InputDecoration(
                  hintText: 'username'
                ),
                ),
                TextFormField(
                  key:const ValueKey('password'),
                 onSaved: (newValue) => _password=newValue??'', 
                  validator: (value) {

                    if(value!.isEmpty||!(value.length<6))
                    return 'enter valid pasword';
                    return null;
                  }, 
                decoration:const InputDecoration(
                  hintText: 'password'
                ),
                ),
                const SizedBox(height: 12,),
              ElevatedButton(onPressed: ()=>submit(),child:
               Text(_islogin?'Log In':'Sign up') ,),
               TextButton(onPressed: ()=>cahngestate(), child: Text(_islogin?'change to Sign up':'change to Log in',
               style:const TextStyle(color: Colors.pink),)
               )
              ],

          )),
        ),
      ),
    );
  }
}