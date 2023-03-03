import 'package:flutter/material.dart';
import 'package:harvesttohome/providers/auth.dart';
import 'package:harvesttohome/providers/orders.dart';
import 'package:harvesttohome/shaders/icon_shader.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class FarmerScreen extends StatefulWidget {
  static const routeName = "/FarmerScreen";

  const FarmerScreen({Key? key}) : super(key: key);

  @override
  State<FarmerScreen> createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductProvider>(context, listen: false)
          .fetchProducts()
          .then((value) {
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 10,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text(
              'Your Profile',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 25,
              ),
            ),
            IconButton(
              onPressed: null,
              icon: Icon(
                Icons.edit,
                size: 30,
              ),
            )
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String userId = Provider.of<ProductProvider>(context).userId;
                        await Provider.of<Orders>(context, listen: false).fetchOrderItemsForParticularFarmer(userId);
                      },
                      child: Container(
                        width: width * 0.3,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Image(
                          image: AssetImage("images/img.png"),
                        ),
                      ),
                    ),
                    Container(
                      width: width * 0.7,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        children: const [
                          FittedBox(
                            child: Text(
                              'Farmer Name',
                              style: TextStyle(
                                fontSize: 30,
                              ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              'ABC FARM',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              'Farm Location',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    Shader(
                      type: 0,
                      child: Container(
                        width: width * 0.95,
                        height: height * 0.07,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/');
                        Provider.of<Auth>(context, listen: false).logout();
                      },
                      style: ButtonStyle(
                         fixedSize: MaterialStateProperty.all(Size(width, height * 0.07)),
                      ),
                      child: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
