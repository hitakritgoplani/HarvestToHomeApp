import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/product_screen.dart';
import 'screens/product_desc.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/manage_products_screen.dart';
import 'screens/edit_add_products.dart';

import 'providers/products_provider.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'providers/auth.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Always use this for main file and .value for lists, grids ...
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
            create: (ctx) => ProductProvider('', '', []),
            update: (ctx, auth, prevProducts) => ProductProvider(
                auth.token ?? '',
                auth.userID ?? '',
                prevProducts?.getItems ?? [])),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders('', '', []),
          update: (ctx, auth, prevOrders) =>
              Orders(auth.token!, auth.userID!, prevOrders!.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ShoppingCart',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Poppins',
            appBarTheme: const AppBarTheme(
              color: Colors.teal,
              titleTextStyle: TextStyle(
                fontSize: 30,
                //fontFamily: 'Cag',
                fontWeight: FontWeight.bold,
                //color: Colors.white,
              ),
            ),
            textTheme: const TextTheme(
              headline1: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(Colors.teal),
              radius: const Radius.circular(20),
            ),
          ),
          home: authData.isAuth
              ? const ProductOverview()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (ctx, authDataSS) =>
                      authDataSS.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            AuthScreen.routeName: (ctx) => const AuthScreen(),
            ProductOverview.routeName: (ctx) => const ProductOverview(),
            ProductDesc.routeName: (ctx) => const ProductDesc(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrderScreen.routeName: (ctx) => const OrderScreen(),
            ManageProducts.routeName: (ctx) => const ManageProducts(),
            EditAddScreen.routeName: (ctx) => const EditAddScreen(),
          },
        ),
      ),
    );
  }
}
