import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);
  //fetch data by setting listener
  //because ProductsGrid doesn't need the product list
  //the ProductItem is the one who needs it
  //now we avoid having to pass data to ProductsGrid constructor
  //in order to forward it to the ProductItem

  @override
  Widget build(BuildContext context) {
    //sets up a direct communication channel behind the scenes (uses inheritedWidget)
    //to one of the provided classes,
    //can only be used in widget which has some direct or indirect parent widget
    //which set up a provider
    //Products object:
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(
          // products[index].id,
          // products[index].title,
          // products[index].imageUrl,
        ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        //the grid items should have a hight of 3 / 2 of their width
        childAspectRatio: 3 / 2,
        //spacing between the columns
        crossAxisSpacing: 10,
        //space between rows
        mainAxisSpacing: 10,
      ),
    );
  }
}
