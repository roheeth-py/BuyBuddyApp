import 'dart:convert';

import "package:flutter/material.dart";
import 'package:grocery_app/dataset/category_data.dart';
import 'package:grocery_app/model/grocery_model.dart';
import 'package:grocery_app/screen/new_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> displayList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    _loadItem();
    super.initState();
  }

  void removeData(GroceryItem item) async{
    int index = displayList.indexOf(item);
    displayList.remove(item);

    final url =  Uri.https(
        "grocery-app-cf51e-default-rtdb.firebaseio.com", "smirthi-list/${item.id}.json");
    final response = await http.delete(url);

    if(response.statusCode>=400){
      displayList.insert(index, item);
    }
  }

  void _loadItem() async {
    List<GroceryItem> lis = [];
    try{
      final url = Uri.https(
          "grocery-app-cf51e-default-rtdb.firebaseio.com", "smirthi-list.json");

      final response = await http.get(
        url,
      );

      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch date. Try again Later";
        });
      }

      if(response.body=="null"){
        setState(() {
          _isLoading=false;
        });
        return;
      }

      Map<String, dynamic> jsonRes = json.decode(response.body);

      for (final i in jsonRes.entries) {
        final category = categories.entries.firstWhere((e) {
          return e.value.title == i.value["category"];
        }).value;
        lis.add(
          GroceryItem(
            i.key,
            i.value["name"],
            i.value["quantity"],
            category,
          ),
        );
      }
      setState(() {
        displayList = lis;
        _isLoading = false;
      });
    }catch(error){
      setState(() {
        _error = "Something went wrong. Try again Later";
      });
    }

  }

  void newScreenNavigation() async {
    var response = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewScreen(),
      ),
    );

    if (response == null) {
      return;
    }

    setState(() {
      displayList.add(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BuyBuddy"),
        actions: [
          IconButton(
            onPressed: newScreenNavigation,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: (_error != null)
          ? Center(
              child: Text(_error!),
            )
          : (_isLoading)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : (displayList.isNotEmpty)
                  ? ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      itemCount: displayList.length,
                      itemBuilder: (ctx, item) {
                        return Dismissible(
                            background: Container(
                            color: Colors.redAccent,
                            padding: const EdgeInsets.only(right: 25),
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.delete),
                          ),
                          key: ValueKey(displayList[item].id),
                          onDismissed: (direction){
                            if(direction==DismissDirection.endToStart){
                              removeData(displayList[item]);
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 20),
                                  child: Container(
                                    decoration: const ShapeDecoration(
                                      shape: CircleBorder(),
                                      color: Colors.blue,
                                    ),
                                    height: 50,
                                    width: 50,
                                    child: const Icon(Icons.local_grocery_store),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(displayList[item].name),
                                    Text(displayList[item].category.title),
                                  ],
                                ),
                                const Spacer(),
                                Text(displayList[item].quantity.toString()),
                                const SizedBox(width: 20,),
                              ],
                            ),
                          )
                        );
                      },)
                  : const Center(
                      child: Text("No items found. Try adding one."),
                    ),
    );
  }
}
