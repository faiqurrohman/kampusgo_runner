import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../widgets/section_title.dart';

class GpaScreen extends StatelessWidget{const GpaScreen({super.key});
 @override Widget build(BuildContext context){final data=AppData.instance;return AnimatedBuilder(animation:data,builder:(_,__)=>SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
 const SectionTitle(title:'GPA Predictor',subtitle:'Simulasikan IPK semester berdasarkan SKS dan target nilai.'),
 Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[const Text('Estimasi IPK Semester'),Text(data.calculateGpa().toStringAsFixed(2),style:const TextStyle(fontSize:42,fontWeight:FontWeight.bold))]))),
 const SizedBox(height:12),ElevatedButton.icon(onPressed:()=>_showAdd(context),icon:const Icon(Icons.add),label:const Text('Tambah Mata Kuliah')),const SizedBox(height:16),
 ...data.gpaItems.map((e)=>Dismissible(key:ValueKey(e.id),onDismissed:(_)=>data.deleteGpa(e.id),background:Container(alignment:Alignment.centerRight,padding:const EdgeInsets.only(right:20),color:Colors.redAccent,child:const Icon(Icons.delete,color:Colors.white)),child:Card(child:ListTile(leading:const Icon(Icons.grade_rounded),title:Text(e.course,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${e.sks} SKS'),trailing:Text(e.gradePoint.toStringAsFixed(1))))))
 ])));}
 void _showAdd(BuildContext context){final course=TextEditingController();final sks=TextEditingController();double grade=4.0;showModalBottomSheet(context:context,isScrollControlled:true,builder:(ctx)=>StatefulBuilder(builder:(ctx,setModal)=>Padding(padding:EdgeInsets.only(left:20,right:20,top:20,bottom:MediaQuery.of(ctx).viewInsets.bottom+20),child:Column(mainAxisSize:MainAxisSize.min,children:[
 const Text('Tambah Simulasi Nilai',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:16),
 TextField(controller:course,decoration:const InputDecoration(labelText:'Mata kuliah')),const SizedBox(height:12),
 TextField(controller:sks,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'SKS')),const SizedBox(height:12),
 DropdownButtonFormField(value:grade,decoration:const InputDecoration(labelText:'Target Nilai'),items:const [DropdownMenuItem(value:4.0,child:Text('A / 4.0')),DropdownMenuItem(value:3.7,child:Text('A- / 3.7')),DropdownMenuItem(value:3.3,child:Text('B+ / 3.3')),DropdownMenuItem(value:3.0,child:Text('B / 3.0')),DropdownMenuItem(value:2.0,child:Text('C / 2.0'))],onChanged:(v)=>setModal(()=>grade=v!)),const SizedBox(height:14),
 ElevatedButton(onPressed:(){final s=int.tryParse(sks.text)??0;if(course.text.isNotEmpty&&s>0){AppData.instance.addGpa(course.text,s,grade);Navigator.pop(ctx);}},child:const Text('Hitung'))
 ]))));}
}
