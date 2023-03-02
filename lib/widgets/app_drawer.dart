import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/manage_products_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/product_screen.dart';

import '../providers/auth.dart';

import '../shaders/icon_shader.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: height * 0.1,
          ),
          const Shader(
            type: 0,
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 70,
              color: Colors.white,
            ),
          ),
          SizedBox(height: height * 0.1),
          const Divider(),
          ListTile(
            leading: const Shader(
                type: 0,
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                )),
            title: const Text('Home'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(ProductOverview.routeName),
          ),
          ListTile(
            leading: const Shader(
                type: 0,
                child: Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                )),
            title: const Text('Orders'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(OrderScreen.routeName),
          ),
          ListTile(
            leading: const Shader(
                type: 0,
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                )),
            title: const Text('Manage Products'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(ManageProducts.routeName),
          ),
          ListTile(
            leading: const Shader(
                type: 0,
                child: Icon(
                  Icons.key_rounded,
                  color: Colors.white,
                )),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
