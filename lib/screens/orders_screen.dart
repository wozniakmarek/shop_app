import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  /*var _isLoading = false;
  @override
  void initState() {
    /*
    //Future.delayed(Duration.zero).then((_) async {
    // setState(() {
        _isLoading = true;
    //  });
     // await 
      Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_){;
      setState(() {
        _isLoading = false;
      });
    });*/
    super.initState();
  }*/
  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        // ignore: missing_return
        builder: (ctx, dataSnapshot) {
          dataSnapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : dataSnapshot.error != null
                  ? Center(
                      child: Text('An error occured'),
                    )
                  : Consumer<Orders>(
                      builder: (ctx, orderData, child) => ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                      ),
                    );
        },
      ),
    );
  }
}
