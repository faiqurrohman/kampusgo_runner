import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../utils/formatters.dart';
import '../widgets/section_title.dart';

class PlannerScreen extends StatelessWidget { const PlannerScreen({super.key});
  @override Widget build(BuildContext context) { final data=AppData.instance; return AnimatedBuilder(animation:data,builder:(_,__)=>SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
    const SectionTitle(title:'Smart Study Planner', subtitle:'Tambah jadwal tugas, ujian, dan deadline kuliah.'),
    ElevatedButton.icon(onPressed:()=>_showAdd(context), icon:const Icon(Icons.add), label:const Text('Tambah Deadline')),
    const SizedBox(height:16),
    ...data.schedules.map((item){ final days=item.deadline.difference(DateTime.now()).inDays+1; return Dismissible(key:ValueKey(item.id), onDismissed:(_)=>data.deleteSchedule(item.id), background:Container(alignment:Alignment.centerRight,padding:const EdgeInsets.only(right:20),color:Colors.redAccent,child:const Icon(Icons.delete,color:Colors.white)), child:Card(child:CheckboxListTile(value:item.done,onChanged:(_)=>data.toggleSchedule(item.id), title:Text(item.title,style:TextStyle(fontWeight:FontWeight.bold,decoration:item.done?TextDecoration.lineThrough:null)), subtitle:Text('${item.course} • ${Formatters.date.format(item.deadline)} • ${days<0?'Lewat': '$days hari lagi'}'), secondary:const Icon(Icons.timer_rounded), controlAffinity:ListTileControlAffinity.trailing)));}),
  ])));}
  void _showAdd(BuildContext context){ final title=TextEditingController(); final course=TextEditingController(); String priority='Sedang'; DateTime deadline=DateTime.now().add(const Duration(days:1)); showModalBottomSheet(context:context,isScrollControlled:true,builder:(ctx)=>Padding(padding:EdgeInsets.only(left:20,right:20,top:20,bottom:MediaQuery.of(ctx).viewInsets.bottom+20),child:Column(mainAxisSize:MainAxisSize.min,children:[
    const Text('Tambah Deadline',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)), const SizedBox(height:16),
    TextField(controller:title,decoration:const InputDecoration(labelText:'Judul tugas/ujian')), const SizedBox(height:12),
    TextField(controller:course,decoration:const InputDecoration(labelText:'Mata kuliah')), const SizedBox(height:12),
    DropdownButtonFormField(value:priority, decoration:const InputDecoration(labelText:'Prioritas'), items:['Rendah','Sedang','Tinggi'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(), onChanged:(v)=>priority=v!),
    const SizedBox(height:12),
    OutlinedButton.icon(onPressed:()async{ final picked=await showDatePicker(context:ctx,firstDate:DateTime.now().subtract(const Duration(days:1)),lastDate:DateTime.now().add(const Duration(days:365)),initialDate:deadline); if(picked!=null) deadline=picked;}, icon:const Icon(Icons.calendar_month), label:const Text('Pilih Deadline')),
    const SizedBox(height:14),
    ElevatedButton(onPressed:(){ if(title.text.isNotEmpty && course.text.isNotEmpty){ AppData.instance.addSchedule(title.text,course.text,deadline,priority); Navigator.pop(ctx);} }, child:const Text('Simpan')),
  ])));}
}
