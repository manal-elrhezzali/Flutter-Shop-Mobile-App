import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }
  //this ensures that no new Fututre is created just because the build() is rebuilt
  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    //removed this and used Consummer to wrap the widget interested in ordersData 
    //instead to avoid an infinite loop
    //by using Provider orders listener here the whole widget will rebuild
    
    // final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: AppDrawer(),
      //to avoid using a StatefulWidget just for using initState()
      //but if we have another state using like this will cause a 
      //new Future object initialization with every build re-run
      //dataSnapshot is the data currently returned by the Future
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          // means we are currently loading
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            //we got an error while loading
            if (dataSnapshot.error != null) {
              //handling the error
              //.................
              return Center(
                child: Text("An error occurred!"),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, index) =>
                      OrderItem(orderData.orders[index]),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
