// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'dart:io';

import 'package:chatapp/controller/Auth_provider.dart';
import 'package:chatapp/widgets/image_picking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({Key? key}) : super(key: key);
  final Authprovider _authprovider = Get.find<Authprovider>();
  final _formkey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";
  String _username = "";
  void submit(BuildContext context) async {
    _authprovider.clear_errors();
    final isvalid = _formkey.currentState!.validate();
    Get.focusScope!.unfocus();
    if (!_authprovider.islogin.value && _authprovider.imagepath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('please pick image'),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return;
    }
    if (isvalid) {
      _formkey.currentState!.save();
      if (!await _authprovider.submitAuthForm(
          _email.trim(), _password.trim(), _username.trim(), context)) {
        _formkey.currentState!.validate();
      }
    }
  }

  void cahngestate() {
    Get.focusScope!.unfocus();
    _authprovider.change_state();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.backgroundColor,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
                key: _formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => _authprovider.islogin.value == true
                        ? Container()
                        : Obx(() => _authprovider.imagepath.isEmpty
                            ? Imagepicking(
                                function: (val) =>
                                    _authprovider.updatefileimage(val))
                            : Imagepicking(
                                function: (val) =>
                                    _authprovider.updatefileimage(val),
                                imagefile: File(
                                  _authprovider.imagepath.value,
                                )))),
                    TextFormField(
                      key: const ValueKey('email'),
                      onSaved: (val) => _email = val!,
                      style: TextStyle(fontSize: 12.sp),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        String error = _authprovider.emailerror.value;
                        if (value!.isEmpty ||
                            !value.contains('@') ||
                            !value.contains('.'))
                          return 'enter valid email';
                        else if (error.isNotEmpty) return error;
                        return null;
                      },
                      decoration:
                          const InputDecoration(labelText: 'Email Address'),
                    ),
                    Obx(() => _authprovider.islogin.value == false
                        ? TextFormField(
                            key: const ValueKey('username'),
                            style: TextStyle(fontSize: 12.sp),
                            onSaved: (newValue) => _username = newValue ?? '',
                            decoration:
                                const InputDecoration(labelText: 'username'),
                          )
                        : Container()),
                    Obx(() {
                      return TextFormField(
                        key: const ValueKey('password'),
                        style: TextStyle(fontSize: 12.sp),
                        obscureText: _authprovider.isnonvis.value,
                        onSaved: (newValue) => _password = newValue ?? '',
                        validator: (value) {
                          String error = _authprovider.passerror.value;
                          if (value!.isEmpty || value.length < 6)
                            return 'enter valid paswoard';
                          else if (error.isNotEmpty) return error;
                          return null;
                        },
                        decoration: InputDecoration(
                            prefixIcon: IconButton(
                                onPressed: () =>
                                    _authprovider.change_password_opic(),
                                icon: Icon(_authprovider.isnonvis.value
                                    ? Icons.visibility
                                    : Icons.visibility_off)),
                            labelText: 'password'),
                      );
                    }),
                    const SizedBox(
                      height: 12,
                    ),
                    Obx(() => _authprovider.isloading.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => submit(context),
                            child: Obx(() => Text(
                                  _authprovider.islogin.value
                                      ? 'Log In'
                                      : 'Sign up',
                                  style: TextStyle(fontSize: 12.sp),
                                )),
                          )),
                    TextButton(
                        onPressed: () => cahngestate(),
                        child: Obx(() => Text(
                              _authprovider.islogin.value
                                  ? 'change to Sign up'
                                  : 'change to Log in',
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 10.sp),
                            )))
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
