import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../widgets/app_drawer.dart';

import '../providers/products.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  //helper to check if we are running
  //didChangeDependencies dor the first time
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    //Fetch Products from server
    //WON'T WORK!  because the widget isn't fully wired up
    //with everyhing yet
    //"of(context) doesn't work"
    //if we set the listen to false it does
    // Provider.of<Products>(context).fetchAndSetProducts();
    // -----------------  solution1  -----------------
    // helper function thah creates a future
    // which runs after the specified duration
    //
    //This works even though the duration is zero
    //because this is still registered as a to-do action
    //by Dart & we will first continue initializing the class
    //in the widget before coming back to this code
    //
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    // -----------------  solution2  -----------------
    //using didChangeDepencies hook
    super.initState();
  }

  //runs when the widget is created and a more couple of times
  @override
  void didChangeDependencies() {
    //checks if we are running
    //didChangeDependencies dor the first time
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("MNÉL \'s Shop"),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              print(selectedValue);
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                  // productsContainer.showFavoritesOnly();
                } else {
                  _showOnlyFavorites = false;
                  // productsContainer.showAll();
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text("Show All"),
                value: FilterOptions.All,
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (ctx, cart, unchangeableChildWidget) => Badge(
              child: unchangeableChildWidget,
              //amount of items we have in the cart
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
