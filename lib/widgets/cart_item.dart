import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(
    this.id,
    this.productId,
    this.quantity,
    this.price,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        //returns a Future<bool>
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Are you sure?"),
            content: Text("Do you wan to remove the item from the cart?"),
            actions: [
              FlatButton(
                child: Text("No"),
                //makes sure we don't continue with dismissing the item
                onPressed: () {
                  //closes the AlertDialog
                  //showDialog returns a Future that resolves
                  // to the vallue we pass to pop
                  //passing a value to pop is optional
                  Navigator.of(ctx).pop(false);
                },
              ),
              FlatButton(
                //goes ahead with dismissin the item
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: Text("Yes"),
              ),
            ],
          ),
        );
      },
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(
                  child: Text("\$$price"),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text("Total: \$${(price * quantity)}"),
            trailing: Text("$quantity x"),
          ),
        ),
      ),
    );
  }
}
