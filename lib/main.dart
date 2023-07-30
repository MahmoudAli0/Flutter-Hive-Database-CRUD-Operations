import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('shopping_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController quntityController = TextEditingController();
  List<Map<String, dynamic>> items = [];
  final shopingBox = Hive.box('shopping_box');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refershItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade100,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text(
          'hive DB',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: items.isEmpty?  Center(child: Text('please add some items..',style: TextStyle(color: Colors.orange.shade400),)) :ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) {
            final currntItem = items[index];
            return Card(
              color: Colors.orange.shade100,
              margin: const EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          showFormSheet(context, currntItem['key']);
                        },
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => deleteItem(currntItem['key']), icon: const Icon(Icons.delete)),
                  ],
                ),
                title: Text(currntItem['name']),
                subtitle: Text(
                  currntItem['quntity'].toString(),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade100,
        onPressed: () => showFormSheet(context, null),
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  void refershItems() {
    final data = shopingBox.keys.map((e) {
      final item = shopingBox.get(e);
      return {'key': e, 'name': item['name'], 'quntity': item['quntity']};
    }).toList();

    setState(() {
      items = data.reversed.toList();
    });
  }

  Future<void> createItem(Map<String, dynamic> newItem) async {
    await shopingBox.add(newItem);
    print('amount data is ${shopingBox.length}');
    refershItems();
  }

  Future<void> updateItem(int itemKey, Map<String, dynamic> item) async {
    await shopingBox.put(item, itemKey);
    refershItems();
  }

  Future<void> deleteItem(int itemKey) async {
    await shopingBox.delete(itemKey);
    refershItems();
    
    ScaffoldMessenger.of(context).showSnackBar(

       SnackBar(
         backgroundColor:Colors.orange.shade500,
           duration: const Duration(seconds: 3),
           content: const Text('Item Deleted Successfully ..',style: TextStyle(color:  Colors.white),))
    );
  }

  void showFormSheet(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final exsitingItem =
          items.firstWhere((element) => element['key'] == itemKey);
      nameController.text = exsitingItem['name'];
      quntityController.text = exsitingItem['quntity'];
    }
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 15,
          right: 15,
          left: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: quntityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Quntity'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                if (itemKey == null) {
                  createItem({
                    "name": nameController.text,
                    "quntity": quntityController.text,
                  });
                }

                if (itemKey != null) {
                  updateItem(itemKey, {
                    'name': nameController.text.trim(),
                    'quntity': quntityController.text.trim(),
                  });
                }
                nameController.text = '';
                quntityController.text = '';
                Navigator.of(context).pop();
              },
              child:  Text(itemKey ==null ? 'create Now': 'Update'),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
