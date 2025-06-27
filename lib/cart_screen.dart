import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_card_app/cart_model.dart';
import 'package:shopping_card_app/cart_provider.dart';
import 'package:shopping_card_app/db_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  DBHelper? dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Cart>>(
        future: dbHelper!.getCartList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var cartItem = snapshot.data![index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              (cartItem.image ?? '').startsWith('http')
                                  ? Image.network(
                                cartItem.image ?? '',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                cartItem.image ?? '',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.productName ?? '',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${cartItem.unitTag ?? ''} \$${cartItem.productPrice ?? 0}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            int quantity =
                                                cartItem.quantity ?? 1;
                                            int price =
                                                cartItem.initialPrice ?? 0;
                                            quantity--;

                                            if (quantity > 0) {
                                              dbHelper!
                                                  .updateQuantity(
                                                Cart(
                                                  id: cartItem.id,
                                                  productId:
                                                  cartItem.productId,
                                                  productName:
                                                  cartItem.productName,
                                                  initialPrice:
                                                  cartItem.initialPrice,
                                                  productPrice:
                                                  cartItem.productPrice,
                                                  quantity: quantity,
                                                  unitTag: cartItem.unitTag,
                                                  image: cartItem.image,
                                                ),
                                              )
                                                  .then((_) {
                                                cart.removeTotalPrice(
                                                    price.toDouble());
                                                cart.removeCounter();
                                                setState(() {});
                                              });
                                            }
                                          },
                                          icon: const Icon(Icons.remove),
                                        ),
                                        Text("${cartItem.quantity ?? 1}"),
                                        IconButton(
                                          onPressed: () {
                                            int quantity =
                                                cartItem.quantity ?? 1;
                                            int price =
                                                cartItem.initialPrice ?? 0;
                                            quantity++;

                                            dbHelper!
                                                .updateQuantity(
                                              Cart(
                                                id: cartItem.id,
                                                productId:
                                                cartItem.productId,
                                                productName:
                                                cartItem.productName,
                                                initialPrice:
                                                cartItem.initialPrice,
                                                productPrice:
                                                cartItem.productPrice,
                                                quantity: quantity,
                                                unitTag: cartItem.unitTag,
                                                image: cartItem.image,
                                              ),
                                            )
                                                .then((_) {
                                              cart.addTotalPrice(
                                                  price.toDouble());
                                              cart.addCounter();
                                              setState(() {});
                                            });
                                          },
                                          icon: const Icon(Icons.add),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            dbHelper!
                                                .delete(cartItem.id ?? 0)
                                                .then((value) {
                                              cart.removeCounter();
                                              cart.removeTotalPrice((cartItem
                                                  .productPrice ??
                                                  0)
                                                  .toDouble());
                                              setState(() {});
                                            });
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Consumer<CartProvider>(
                  builder: (context, value, child) {
                    double discount = 0.05 * value.totalPrice;
                    double subTotal = value.totalPrice;
                    double total = subTotal;

                    return Column(
                      children: [
                        ReusableWidget(
                          title: 'Sub Total',
                          value: '\$${subTotal.toStringAsFixed(2)}',
                        ),
                        ReusableWidget(
                          title: 'Discount 5%',
                          value: '\$${discount.toStringAsFixed(2)}',
                        ),
                        const Divider(thickness: 2),
                        ReusableWidget(
                          title: 'Total',
                          value: '\$${total.toStringAsFixed(2)}',
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          } else {
            // 🖼️ Cart is empty UI with image
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/EmptyCart.webp',
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;

  const ReusableWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
