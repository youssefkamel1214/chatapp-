import 'package:flutter/material.dart';
class SearchUser extends StatelessWidget {
  final String imageurl,useremail,username;
  final bool isexist;
   Function function1,function2;
   SearchUser({
    Key? key,
    required this.imageurl,
    required this.useremail,
    required this.username,
    required this.isexist,
    required this.function1,
     required this.function2,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
               margin:const EdgeInsets.all( 5.0),
               padding:const EdgeInsets.all(8.0),
               decoration: BoxDecoration(
                 color:Theme.of(context).primaryColor,
                 borderRadius: BorderRadius.circular(20)
               ), 
               child: Column(mainAxisSize: MainAxisSize.min,
                 children:[ 
                   Row(
                     children: [
                        CircleAvatar(radius: 30,backgroundImage: Image.network(
                                                imageurl,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;

                                                return const Center(child:CircularProgressIndicator(color: Colors.white,) ,  );
                                              },
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Text('Some errors occurred!'),
                                            ).image , 
                                            backgroundColor: null,
                                         ),
                       Expanded(
                         child: Column(
                           crossAxisAlignment:CrossAxisAlignment.center ,
                           children: [
                             Text('user email: $useremail'),
                             Text('username :$username'),
                           ],
                         ),
                       ),
                     ],
                   ),
                   
                   SizedBox(height: 25, child: Row( 
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       IconButton(onPressed:()=>function1(), icon:const Icon( Icons.add)),
                     const  IconButton(onPressed: null, icon:  Icon(Icons.block)),
                       IconButton(onPressed:isexist?()=>function2():null ,icon:const Icon(Icons.chat))
                     ],
                   ))
                 ]),
       );
  }

}
