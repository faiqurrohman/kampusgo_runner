import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_data.dart';
import '../widgets/section_title.dart';

class ResourceScreen extends StatelessWidget{const ResourceScreen({super.key});
 @override Widget build(BuildContext context){final data=AppData.instance;return AnimatedBuilder(animation:data,builder:(_,__)=>SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
 const SectionTitle(title:'Community Resource Hub',subtitle:'Simpan link materi, Zoom/Meet, dan kontak penting kuliah.'),
 ElevatedButton.icon(onPressed:()=>_showAdd(context),icon:const Icon(Icons.add_link),label:const Text('Tambah Resource')),const SizedBox(height:16),
 ...data.resources.map((e)=>Dismissible(key:ValueKey(e.id),onDismissed:(_)=>data.deleteResource(e.id),background:Container(alignment:Alignment.centerRight,padding:const EdgeInsets.only(right:20),color:Colors.redAccent,child:const Icon(Icons.delete,color:Colors.white)),child:Card(child:ListTile(leading:const Icon(Icons.link_rounded),title:Text(e.title,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${e.course}\n${e.link}'),isThreeLine:true,trailing:IconButton(icon:const Icon(Icons.open_in_new),onPressed:()async{final uri=Uri.tryParse(e.link);if(uri!=null) await launchUrl(uri,mode:LaunchMode.externalApplication);})))))
 ])));}
 void _showAdd(BuildContext context){final course=TextEditingController();final title=TextEditingController();final link=TextEditingController(text:'https://');showModalBottomSheet(context:context,isScrollControlled:true,builder:(ctx)=>Padding(padding:EdgeInsets.only(left:20,right:20,top:20,bottom:MediaQuery.of(ctx).viewInsets.bottom+20),child:Column(mainAxisSize:MainAxisSize.min,children:[
 const Text('Tambah Resource',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:16),
 TextField(controller:course,decoration:const InputDecoration(labelText:'Mata kuliah')),const SizedBox(height:12),
 TextField(controller:title,decoration:const InputDecoration(labelText:'Judul resource')),const SizedBox(height:12),
 TextField(controller:link,decoration:const InputDecoration(labelText:'Link')),const SizedBox(height:14),
 ElevatedButton(onPressed:(){if(course.text.isNotEmpty&&title.text.isNotEmpty&&link.text.startsWith('http')){AppData.instance.addResource(course.text,title.text,link.text);Navigator.pop(ctx);}},child:const Text('Simpan'))
 ])));}
}
