import 'package:flutter/material.dart';
import 'package:harvesttohome/screens/auth_screen.dart';
import 'package:provider/provider.dart';

import 'screens/product_screen.dart';

import 'providers/products_provider.dart';
import 'providers/auth.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
            create: (ctx) => ProductProvider('', '', []),
            update: (ctx, auth, prevProducts) => ProductProvider(
                auth.token ?? '',
                auth.userID ?? '',
                prevProducts?.getItems ?? [])),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ShoppingCart',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
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
                ? const Center(child: CircularProgressIndicator(),)
                : const AuthScreen(),
          ),
          routes: {
            AuthScreen.routeName: (ctx) => const AuthScreen(),
            ProductOverview.routeName: (ctx) => const ProductOverview(),
          },
        ),
      ),
    );
  }
}
