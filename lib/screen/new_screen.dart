import "dart:convert";

import "package:flutter/material.dart";
import "package:grocery_app/model/grocery_model.dart";
import 'package:http/http.dart' as http;
import "package:grocery_app/dataset/category_data.dart";
import "package:grocery_app/model/category_model.dart";

class NewScreen extends StatefulWidget {
  const NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String name = "";
  int quantity = 1;
  Category selectedCategory = categories[Categories.vegetables]!;

  void onPressed(String identifier) async {
    if (identifier == "Add") {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        final url = Uri.https(
          "grocery-app-cf51e-default-rtdb.firebaseio.com",
          "smirthi-list.json",
        );

        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "name": name,
            "quantity": quantity,
            "category": selectedCategory.title,
          }),
        );

        setState(() {
          _isLoading = true;
        });

        final id = json.decode(response.body);

        if(!context.mounted){
          return ;
        }
        Navigator.of(context).pop(
          GroceryItem(id["name"], name, quantity, selectedCategory),
        );
      }
    } else {
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
                validator: (state) {
                  if (state == null || state.trim().length <= 1) {
                    return "Enter name";
                  }
                  return null;
                },
                onSaved: (str) {
                  name = str!;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: "quantity",
                      ),
                      initialValue: "1",
                      validator: (state) {
                        if (int.parse(state!) < 1) {
                          return "Enter valid quantity";
                        }
                        return null;
                      },
                      onSaved: (str) {
                        quantity = int.parse(str!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedCategory,
                      items: categories.values.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                color: e.color,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(e.title),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedCategory = value!;
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed:  (_isLoading)?null:() {
                      onPressed("reset");
                    },
                    child: const Text("Reset"),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: (_isLoading)?null:() {
                      onPressed("Add");
                    },
                    child:(_isLoading)?const SizedBox(height:16, width:16, child: CircularProgressIndicator(),):const Text("Add"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


