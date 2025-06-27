import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shopping_card_app/cart_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get database async {
    if (_db != null) return _db;
    _db = await initDatabase();
    return _db;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'cart.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId TEXT,
            productName TEXT,
            initialPrice INTEGER,
            productPrice INTEGER,
            quantity INTEGER,
            unitTag TEXT,
            image TEXT
          )
        ''');
      },
    );
  }

  /// ✅ Insert new cart item
  Future<Cart> insert(Cart cart) async {
    final db = await database;
    await db!.insert(
      'cart',
      cart.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return cart;
  }

  /// ✅ Get all cart items
  Future<List<Cart>> getCartList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('cart');

    return List.generate(maps.length, (index) {
      return Cart(
        id: maps[index]['id'],
        productId: maps[index]['productId'],
        productName: maps[index]['productName'],
        initialPrice: maps[index]['initialPrice'],
        productPrice: maps[index]['productPrice'],
        quantity: maps[index]['quantity'],
        unitTag: maps[index]['unitTag'],
        image: maps[index]['image'],
      );
    });
  }

  /// ✅ Delete cart item
  Future<int> delete(int id) async {
    final db = await database;
    return await db!.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  /// ✅ Update quantity or price (if needed)
  Future<int> updateQuantity(Cart cart) async {
    final db = await database;
    return await db!.update(
      'cart',
      cart.toMap(),
      where: 'id = ?',
      whereArgs: [cart.id],
    );
  }

  /// ✅ Check if product is already in cart
  Future<bool> isProductInCart(String productId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'cart',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    return maps.isNotEmpty;
  }

  /// ✅ Clear the cart completely
  Future<void> clearCart() async {
    final db = await database;
    await db!.delete('cart');
  }
}
