import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-products";

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Your Products"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async{
          //adding await so that only after the fetching is done 
          //the Fututre object will be returned => not showing the RefreshIndicator
          await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
        },
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: (ctx, index) => Column(
              children: [
                UserProductItem(
                  productsData.items[index].id,
                  productsData.items[index].title,
                  productsData.items[index].imageUrl,
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
