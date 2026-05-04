import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../utils/formatters.dart';
import '../widgets/section_title.dart';
import '../widgets/simple_donut_chart.dart';

class BudgetScreen extends StatelessWidget{ const BudgetScreen({super.key});
 @override Widget build(BuildContext context){final data=AppData.instance;return AnimatedBuilder(animation:data,builder:(_,__)=>SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
 const SectionTitle(title:'Budget Buddy',subtitle:'Catat pengeluaran harian agar uang saku lebih terkontrol.'),
 SimpleDonutChart(data:data.expenseByCategory()), const SizedBox(height:12),
 ElevatedButton.icon(onPressed:()=>_showAdd(context),icon:const Icon(Icons.add),label:const Text('Tambah Pengeluaran')), const SizedBox(height:16),
 Text('Total: ${Formatters.currency.format(data.totalExpense())}',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)), const SizedBox(height:12),
 ...data.expenses.map((e)=>Dismissible(key:ValueKey(e.id),onDismissed:(_)=>data.deleteExpense(e.id),background:Container(alignment:Alignment.centerRight,padding:const EdgeInsets.only(right:20),color:Colors.redAccent,child:const Icon(Icons.delete,color:Colors.white)),child:Card(child:ListTile(leading:const Icon(Icons.receipt_long_rounded),title:Text(e.title,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${e.category} • ${Formatters.date.format(e.date)}'),trailing:Text(Formatters.currency.format(e.amount))))))
 ])));}
 void _showAdd(BuildContext context){final title=TextEditingController();final amount=TextEditingController();String category='Makanan';showModalBottomSheet(context:context,isScrollControlled:true,builder:(ctx)=>Padding(padding:EdgeInsets.only(left:20,right:20,top:20,bottom:MediaQuery.of(ctx).viewInsets.bottom+20),child:Column(mainAxisSize:MainAxisSize.min,children:[
 const Text('Tambah Pengeluaran',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:16),
 TextField(controller:title,decoration:const InputDecoration(labelText:'Nama pengeluaran')),const SizedBox(height:12),
 TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Nominal')),const SizedBox(height:12),
 DropdownButtonFormField(value:category,decoration:const InputDecoration(labelText:'Kategori'),items:['Makanan','Transportasi','Fotokopi','Organisasi','Lainnya'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>category=v!),const SizedBox(height:14),
 ElevatedButton(onPressed:(){final nominal=int.tryParse(amount.text)??0;if(title.text.isNotEmpty&&nominal>0){AppData.instance.addExpense(title.text,category,nominal);Navigator.pop(ctx);}},child:const Text('Simpan'))
 ])));}
}
