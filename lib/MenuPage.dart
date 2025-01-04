import 'package:final_project/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int _selectedIndex = 1;
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> cartItems = [];
  int cartItemCount = 0;
  Map<String, dynamic> recommendations = {};

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final snapshot = await _database.child('recommendations').get();
      if (snapshot.exists) {
        setState(() {
          recommendations = Map<String, dynamic>.from(snapshot.value as Map);
        });
      }
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
    }
  }

  Future<void> _loadMenuItems() async {
    try {
      final snapshot = await _database.child('food').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final menus = data['Menu'] as List<dynamic>;
        final cuisines = data['Cuisine'] as List<dynamic>;
        final types = data['Type'] as List<dynamic>;
        final spiciness = data['Spiciness'] as List<dynamic>;
        final ingredients = data['Key_Ingredients'] as List<dynamic>;

        setState(() {
          menuItems = List.generate(menus.length, (index) {
            return {
              'name': menus[index]['name'],
              'description': menus[index]['description'],
              'price': menus[index]['price'],
              'cuisine': cuisines[index],
              'type': types[index],
              'spiciness': spiciness[index],
              'ingredients': ingredients[index],
              'quantity': 1,
            };
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading menu items')),
      );
    }
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      int existingIndex = cartItems.indexWhere((cartItem) => cartItem['name'] == item['name']);

      if (existingIndex != -1) {
        cartItems[existingIndex]['quantity'] = (cartItems[existingIndex]['quantity'] as int) + 1;
      } else {
        cartItems.add({...item, 'quantity': 1});
      }
      cartItemCount = cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => setState(() => _selectedIndex = 2),
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (cartItems.isEmpty) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final ordersRef = _database.child('orders/$userId');
      final newOrderRef = ordersRef.push();


      try {
        double totalAmount = cartItems.fold(
            0, (sum, item) =>
        sum + (item['price'] as num) * (item['quantity'] as num));

        await newOrderRef.set({
          'items': cartItems.map((item) =>
          {
            'name': item['name'],
            'price': item['price'],
            'quantity': item['quantity'],
          }).toList(),
          'totalAmount': totalAmount,
          'orderId': newOrderRef.key,
          'timestamp': ServerValue.timestamp,
          'status': 'pending',
        });

        setState(() {
          cartItems.clear();
          cartItemCount = 0;
          _selectedIndex = 1;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error placing order. Please try again.')),
        );
      }
    }else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You are not logged in. Please try again.')),
      );
    }
  }

  Widget _buildCartIcon() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _selectedIndex == 2 ? Colors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.shopping_cart,
            color: _selectedIndex == 2 ? Colors.white : Colors.indigo,
          ),
        ),
        if (cartItemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                cartItemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHoverCard(Map<String, dynamic> item) {
    final itemRecs = recommendations[item['name']]?['recommendations'] as List<dynamic>? ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    image: DecorationImage(
                      image: AssetImage('assets/images/${item['name'].toString().toLowerCase().replaceAll(' ', '_')}.jpg'),
                      fit: BoxFit.cover,
                      onError: (_, __) => const AssetImage('assets/images/default_food.jpg'),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      onHover: (isHovering) {
                        if (isHovering) {
                          _showItemDetails(context, item);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Rs. ${item['price']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (itemRecs.isNotEmpty) ...[
                    const Text(
                      'You may also like:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: itemRecs.map((rec) => Chip(
                        label: Text(
                          rec.toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.indigo[50],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);
    final Size size = button.size;
    final recommendations = (item['recommendations'] as List<String>?) ?? [];

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + (size.width - 250) / 2,
        top: position.dy + (size.height - 200) / 2,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['description'],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Price: Rs. ${item['price']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo,
                  ),
                ),
                Text('Cuisine: ${item['cuisine']}'),
                Text('Type: ${item['type']}'),
                Text('Spiciness: ${item['spiciness']}'),
                if (recommendations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'You may also like:',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(recommendations.join(', ')),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry?.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const Center(child: Text('Profile Page')),
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) => _buildHoverCard(menuItems[index]),
          ),
          cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      title: Text(cartItems[index]['name']),
                      subtitle: Text('Quantity: ${cartItems[index]['quantity']}'),
                      trailing: Text(
                        'Rs. ${(cartItems[index]['price'] as num) * (cartItems[index]['quantity'] as num)}',
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Place Order',style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailsScreen()));
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Person'),
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: _buildCartIcon(), label: 'Cart'),
        ],
      ),
    );
  }
}