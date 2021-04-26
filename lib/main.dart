import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //provided here because we need to provide it at the highest possible point
    //of all the interested widgets

    //only child widgets which are listening will rebuild
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        //sets up a provider which itself depends on another
        //provider which was defined before the
        //ChangeNotifierProxyProvider
        // <=> provider package looks for a provider
        // (defined before ChangeNotifierProxyProvider)
        // that provides an Auth object and then
        // it takes the Auth object
        //and gives it to the ChangeNotifierProxyProvider (auth)
        //whenever the auth changes the ChangeNotifierProxyProvider
        //will be rebuilt
        //ChangeNotifierProxyProvider<Provider you depend on, type of data you'll provide>(

        ChangeNotifierProxyProvider<Auth, Products>(
          //when this rebuilds we will loose all our items (Data we had there before)
          // update: (ctx, auth, previousProducts) => Products(auth.token), 
          create: null,
          update: (ctx, auth, previousProducts) =>
              Products(auth.token, previousProducts == null ? [] : previousProducts.items), 
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Orders(),
        ),
      ],
      child: Consumer<Auth>(
        //auth : latest auth object
        //builder runs whenever the auth object changes
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MNÉL\'s Shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: "Lato",
          ),
          home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
