import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:shopping_card_app/cart_provider.dart';
import 'package:shopping_card_app/cart_model.dart';
import 'package:shopping_card_app/db_helper.dart';
import 'package:shopping_card_app/cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<String> productName = [
    'Mango',
    'Orange',
    'Grapes',
    'Banana',
    'Cherry',
    'Peach',
    'Mixed Fruit Basket'
  ];

  List<String> productUnit = ['KG', 'Dozen', 'KG', 'Dozen', 'KG', 'KG', 'KG'];
  List<int> productPrice = [10, 20, 30, 40, 50, 60, 70];
  List<String> productImage = [
    'assets/images/mangoes.webp',
    'assets/images/orange.jpg',
    'assets/images/angur.jpg',
    'assets/images/banana.jpg',
    'assets/images/Cherry.jpg',
    'assets/images/Peach.jpg',
    'assets/images/Mixed Fruit Basket.jpg',
  ];

  DBHelper? dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    Provider.of<CartProvider>(context, listen: false).loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFruitShop'),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            child: Center(
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                badgeContent: Consumer<CartProvider>(
                  builder: (context, value, child) {
                    return Text(
                      value.counter.toString(),
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 20.0),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: productName.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image(
                              height: 100,
                              width: 100,
                              image: AssetImage(productImage[index]),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName[index],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${productUnit[index]} \$${productPrice[index]}",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () async {
                                        String productId = index.toString();
                                        bool exists = await dbHelper!.isProductInCart(productId);

                                        if (!exists) {
                                          dbHelper!
                                              .insert(
                                            Cart(
                                              id: null,
                                              productId: productId,
                                              productName: productName[index],
                                              initialPrice: productPrice[index],
                                              productPrice: productPrice[index],
                                              quantity: 1,
                                              unitTag: productUnit[index],
                                              image: productImage[index],
                                            ),
                                          )
                                              .then((value) {
                                            cart.addTotalPrice(productPrice[index].toDouble());
                                            cart.addCounter();

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.green,
                                                content: Text('Product added to cart'),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text('Already added to cart'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Add to cart',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
