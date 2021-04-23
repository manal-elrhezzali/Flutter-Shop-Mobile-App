import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text("\$${widget.order.amount}"),
            subtitle: Text(
              DateFormat("dd/MM/yyyy hh:mm").format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          //dart:math gives us the min function to use the minimum value out of two values
          //the first value ensures that we never have a too height container if we have only one product for example
          //the 2nd value ensures that we don't expand the container infinitly and have a super big
          //container
          if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 4,
              ),
              height: min(widget.order.products.length * 20.0 + 15, 100),
              child: ListView(
                //map the list of data to a list of widgets
                children: widget.order.products
                    .map(
                      (prod) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            prod.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${prod.quantity}x \$${prod.price}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
