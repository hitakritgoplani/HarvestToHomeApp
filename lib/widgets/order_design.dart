import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../providers/cart.dart';

class OrderDesign extends StatefulWidget {
  final DateTime dateTime;
  final int total;
  final List<CartItem> items;

  const OrderDesign(
      {Key? key,
      required this.dateTime,
      required this.total,
      required this.items})
      : super(key: key);

  @override
  State<OrderDesign> createState() => _OrderDesignState();
}

class _OrderDesignState extends State<OrderDesign>
    with SingleTickerProviderStateMixin {
  var _extended = false;

  late AnimationController _animationController;
  late Animation<double> _angleAnimation;

  final _controller = ScrollController();

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _angleAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
      ),
      margin: const EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                DateFormat('dd MMM, yy  hh:mm a').format(widget.dateTime),
                style:
                    const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 20),
              Text(
                'Total: \u20b9${widget.total}',
                style:
                    const TextStyle(fontSize: 20),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if(!_extended){
                      _extended = true;
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                      _extended = false;
                    }
                  });
                },
                icon: AnimatedBuilder(
                  animation: _angleAnimation,
                  builder: (ctx, child) => Transform.rotate(
                    angle: _angleAnimation.value.toDouble(),
                    child: child,
                  ),
                  child: const Icon(Icons.expand_more),
                )
              )
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: _extended
                ? min(widget.items.length * 20 + 45, height * 0.3)
                : 0,
            decoration: const BoxDecoration(
              border: BorderDirectional(top: BorderSide(color: Colors.black12)),
            ),
            child: Scrollbar(
              controller: _controller,
              thumbVisibility: true,
              child: ListView(
                controller: _controller,
                children: [
                  ...widget.items.map((e) {
                    return ListTile(
                      title: Text(e.title),
                      subtitle: Text(e.price.toString()),
                      trailing: Text('x${e.quantity}'),
                    );
                  }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
