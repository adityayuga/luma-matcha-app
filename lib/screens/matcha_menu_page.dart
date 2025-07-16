import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/drink_item.dart';
import '../models/cart_item.dart';

class MatcDrinkMenuPage extends StatefulWidget {
  const MatcDrinkMenuPage({super.key});

  @override
  State<MatcDrinkMenuPage> createState() => _MatcDrinkMenuPageState();
}

class _MatcDrinkMenuPageState extends State<MatcDrinkMenuPage> {
  int selectedCategoryIndex = 0;
  final TextEditingController _orderNotesController = TextEditingController();
  final List<CartItem> _cart = [];

  @override
  void dispose() {
    _orderNotesController.dispose();
    super.dispose();
  }

  void _addToCart(DrinkItem drink, DrinkSize size, [String? orderNotes]) {
    setState(() {
      // Check if item already exists in cart
      final existingItemIndex = _cart.indexWhere(
        (item) =>
            item.drinkName == drink.name &&
            item.sizeName == size.name &&
            item.orderNotes == orderNotes,
      );

      if (existingItemIndex >= 0) {
        // Increase quantity if item exists
        _cart[existingItemIndex].quantity++;
      } else {
        // Add new item to cart
        _cart.add(
          CartItem(
            drinkName: drink.name,
            sizeName: size.name,
            sizeDisplayName: size.displayName,
            price: size.price,
            orderNotes: orderNotes,
          ),
        );
      }
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drink.name} added to cart!'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromRGBO(69, 99, 48, 1),
      ),
    );
  }

  double _getTotalCartPrice() {
    return _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int _getTotalCartItems() {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')}';
  }

  double _getMinPrice(DrinkItem drink) {
    return drink.sizes.map((s) => s.price).reduce((a, b) => a < b ? a : b);
  }

  final List<DrinkCategory> categories = [
    DrinkCategory(
      name: 'Signature',
      icon: '⭐',
      items: [
        DrinkItem(
          name: 'Luma Signature Matcha',
          description: 'Premium ceremonial grade matcha with perfect balance',
          imagePath: 'assets/drinks/signature_matcha.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 28000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 32000,
              unit: 'ml',
            ),
            DrinkSize(
              name: '1L',
              displayName: '1 Liter',
              price: 95000,
              unit: 'L',
            ),
          ],
          category: 'Signature',
          isPopular: true,
        ),
        DrinkItem(
          name: 'Matcha Latte Premium',
          description: 'Rich matcha blended with steamed milk',
          imagePath: 'assets/drinks/matcha_latte.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 25000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 28000,
              unit: 'ml',
            ),
            DrinkSize(
              name: '1L',
              displayName: '1 Liter',
              price: 85000,
              unit: 'L',
            ),
          ],
          category: 'Signature',
          isPopular: true,
        ),
        DrinkItem(
          name: 'Matcha Espresso Fusion',
          description: 'Bold matcha meets espresso in perfect harmony',
          imagePath: 'assets/drinks/matcha_espresso.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 30000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 35000,
              unit: 'ml',
            ),
          ],
          category: 'Signature',
        ),
      ],
    ),
    DrinkCategory(
      name: 'Hot Drinks',
      icon: '🔥',
      items: [
        DrinkItem(
          name: 'Hot Matcha Latte',
          description: 'Warm comforting matcha with steamed milk',
          imagePath: 'assets/drinks/hot_matcha_latte.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 23000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 26000,
              unit: 'ml',
            ),
            DrinkSize(
              name: '1L',
              displayName: '1 Liter',
              price: 78000,
              unit: 'L',
            ),
          ],
          category: 'Hot Drinks',
          isHot: true,
          isCold: false,
        ),
        DrinkItem(
          name: 'Matcha Cappuccino',
          description: 'Matcha with perfectly foamed milk and cocoa dust',
          imagePath: 'assets/drinks/matcha_cappuccino.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 25000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 28000,
              unit: 'ml',
            ),
          ],
          category: 'Hot Drinks',
          isHot: true,
          isCold: false,
        ),
        DrinkItem(
          name: 'Traditional Matcha Tea',
          description: 'Pure ceremonial grade matcha in traditional style',
          imagePath: 'assets/drinks/traditional_matcha.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 20000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 23000,
              unit: 'ml',
            ),
            DrinkSize(
              name: '1L',
              displayName: '1 Liter',
              price: 70000,
              unit: 'L',
            ),
          ],
          category: 'Hot Drinks',
          isHot: true,
          isCold: false,
        ),
        DrinkItem(
          name: 'Matcha Genmaicha',
          description: 'Matcha blended with roasted rice tea',
          imagePath: 'assets/drinks/matcha_genmaicha.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 22000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 25000,
              unit: 'ml',
            ),
            DrinkSize(
              name: '1L',
              displayName: '1 Liter',
              price: 75000,
              unit: 'L',
            ),
          ],
          category: 'Hot Drinks',
          isHot: true,
          isCold: false,
        ),
      ],
    ),
    DrinkCategory(
      name: 'Cold Drinks',
      icon: '🧊',
      items: [
        DrinkItem(
          name: 'Iced Matcha Latte',
          description: 'Refreshing cold matcha with milk over ice',
          imagePath: 'assets/drinks/iced_matcha_latte.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 25000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 28000,
              unit: 'ml',
            ),
            DrinkSize(
              name: '1L',
              displayName: '1 Liter',
              price: 85000,
              unit: 'L',
            ),
          ],
          category: 'Cold Drinks',
          isHot: false,
          isCold: true,
        ),
        DrinkItem(
          name: 'Matcha Frappuccino',
          description: 'Blended iced matcha with whipped cream',
          imagePath: 'assets/drinks/matcha_frappuccino.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 32000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 35000,
              unit: 'ml',
            ),
          ],
          category: 'Cold Drinks',
          isHot: false,
          isCold: true,
        ),
        DrinkItem(
          name: 'Matcha Bubble Tea',
          description: 'Matcha with chewy tapioca pearls',
          imagePath: 'assets/drinks/matcha_bubble_tea.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 28000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 32000,
              unit: 'ml',
            ),
          ],
          category: 'Cold Drinks',
          isHot: false,
          isCold: true,
        ),
        DrinkItem(
          name: 'Matcha Smoothie',
          description: 'Creamy matcha blended with banana and yogurt',
          imagePath: 'assets/drinks/matcha_smoothie.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 30000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 35000,
              unit: 'ml',
            ),
          ],
          category: 'Cold Drinks',
          isHot: false,
          isCold: true,
        ),
        DrinkItem(
          name: 'Iced Matcha Americano',
          description: 'Cold matcha with water, pure and refreshing',
          imagePath: 'assets/drinks/iced_matcha_americano.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 22000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 25000,
              unit: 'ml',
            ),
            DrinkSize(
              name: '1L',
              displayName: '1 Liter',
              price: 75000,
              unit: 'L',
            ),
          ],
          category: 'Cold Drinks',
          isHot: false,
          isCold: true,
        ),
      ],
    ),
    DrinkCategory(
      name: 'Desserts',
      icon: '🍰',
      items: [
        DrinkItem(
          name: 'Matcha Affogato',
          description: 'Vanilla ice cream drowned in hot matcha shot',
          imagePath: 'assets/drinks/matcha_affogato.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 35000,
              unit: 'cup',
            ),
          ],
          category: 'Desserts',
        ),
        DrinkItem(
          name: 'Matcha Float',
          description: 'Matcha drink with vanilla ice cream float',
          imagePath: 'assets/drinks/matcha_float.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 32000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 38000,
              unit: 'ml',
            ),
          ],
          category: 'Desserts',
        ),
        DrinkItem(
          name: 'Matcha Parfait Drink',
          description: 'Layered matcha drink with cream and mochi bits',
          imagePath: 'assets/drinks/matcha_parfait.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 38000,
              unit: 'cup',
            ),
          ],
          category: 'Desserts',
        ),
        DrinkItem(
          name: 'Matcha Milkshake',
          description: 'Thick and creamy matcha milkshake',
          imagePath: 'assets/drinks/matcha_milkshake.png',
          sizes: [
            DrinkSize(
              name: 'cup',
              displayName: 'Cup',
              price: 35000,
              unit: 'cup',
            ),
            DrinkSize(
              name: '250ml',
              displayName: '250ml',
              price: 40000,
              unit: 'ml',
            ),
          ],
          category: 'Desserts',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(254, 255, 250, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(69, 99, 48, 1),
        foregroundColor: Colors.white,
        title: Text(
          'Matcha Menu',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // Cart icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showCartModal,
              ),
              if (_getTotalCartItems() > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_getTotalCartItems()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category tabs
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = index == selectedCategoryIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color.fromRGBO(69, 99, 48, 1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromRGBO(69, 99, 48, 1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.name,
                          style: GoogleFonts.poppins(
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color.fromRGBO(69, 99, 48, 1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Drinks grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid based on screen width with taller cards
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                  double aspectRatio =
                      constraints.maxWidth > 600 ? 0.65 : 0.75; // Made taller

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: aspectRatio,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: categories[selectedCategoryIndex].items.length,
                    itemBuilder: (context, index) {
                      final drink =
                          categories[selectedCategoryIndex].items[index];
                      return _buildDrinkCard(drink);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkCard(DrinkItem drink) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                color: Colors.grey[100],
              ),
              child: Stack(
                children: [
                  // Placeholder for image
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(69, 99, 48, 0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.local_drink,
                        size: 40,
                        color: Color.fromRGBO(69, 99, 48, 1),
                      ),
                    ),
                  ),

                  // Popular badge
                  if (drink.isPopular)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Popular',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    drink.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(69, 99, 48, 1),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Description
                  Expanded(
                    child: Text(
                      drink.description,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Price and actions - simplified layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Price column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Show minimum price with "from" indicator for multiple sizes
                            Text(
                              drink.sizes.length > 1
                                  ? 'from ${_formatPrice(_getMinPrice(drink))}'
                                  : _formatPrice(drink.sizes.first.price),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromRGBO(69, 99, 48, 1),
                              ),
                            ),
                            // Size indicator
                            if (drink.sizes.length > 1)
                              Container(
                                margin: EdgeInsets.only(top: 2),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.teal.shade200,
                                  ),
                                ),
                                child: Text(
                                  '${drink.sizes.length} sizes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Add to cart button
                      GestureDetector(
                        onTap: () {
                          if (drink.sizes.length > 1) {
                            // Show size selection for multi-size drinks
                            _showSizeSelectionDialog(drink);
                          } else {
                            // Add single size drink directly to cart
                            _addToCart(drink, drink.sizes.first);
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(69, 99, 48, 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            drink.sizes.length > 1 ? Icons.tune : Icons.add,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSizeSelectionDialog(DrinkItem drink) {
    _orderNotesController.clear(); // Clear previous notes
    DrinkSize? selectedSize;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(69, 99, 48, 0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.local_drink,
                                size: 25,
                                color: Color.fromRGBO(69, 99, 48, 1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    drink.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromRGBO(
                                        69,
                                        99,
                                        48,
                                        1,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Select your preferred size',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Size options
                        ...drink.sizes.map(
                          (size) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setModalState(() {
                                    selectedSize = size;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          selectedSize == size
                                              ? const Color.fromRGBO(
                                                69,
                                                99,
                                                48,
                                                1,
                                              )
                                              : Colors.grey.shade300,
                                      width: selectedSize == size ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color:
                                        selectedSize == size
                                            ? const Color.fromRGBO(
                                              69,
                                              99,
                                              48,
                                              0.05,
                                            )
                                            : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      // Size icon
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              selectedSize == size
                                                  ? const Color.fromRGBO(
                                                    69,
                                                    99,
                                                    48,
                                                    0.2,
                                                  )
                                                  : const Color.fromRGBO(
                                                    69,
                                                    99,
                                                    48,
                                                    0.1,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Icon(
                                          _getSizeIcon(size.name),
                                          size: 20,
                                          color: const Color.fromRGBO(
                                            69,
                                            99,
                                            48,
                                            1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Size details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              size.displayName,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color.fromRGBO(
                                                  69,
                                                  99,
                                                  48,
                                                  1,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _getSizeDescription(size.name),
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Price and selection indicator
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatPrice(size.price),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color.fromRGBO(
                                                69,
                                                99,
                                                48,
                                                1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Icon(
                                            selectedSize == size
                                                ? Icons.check_circle
                                                : Icons.circle_outlined,
                                            size: 16,
                                            color:
                                                selectedSize == size
                                                    ? const Color.fromRGBO(
                                                      69,
                                                      99,
                                                      48,
                                                      1,
                                                    )
                                                    : Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Order Notes Input
                        Text(
                          'Order Notes (Optional)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromRGBO(69, 99, 48, 1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _orderNotesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'e.g., Less sugar, extra hot, no ice...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color.fromRGBO(69, 99, 48, 1),
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Add to Cart button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                selectedSize != null
                                    ? () {
                                      Navigator.pop(context);
                                      _addToCart(
                                        drink,
                                        selectedSize!,
                                        _orderNotesController.text,
                                      );
                                    }
                                    : null,
                            icon: const Icon(Icons.add_shopping_cart, size: 20),
                            label: Text(
                              selectedSize != null
                                  ? 'Add to Cart - ${_formatPrice(selectedSize!.price)}'
                                  : 'Select a size first',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  selectedSize != null
                                      ? const Color.fromRGBO(69, 99, 48, 1)
                                      : Colors.grey.shade300,
                              foregroundColor:
                                  selectedSize != null
                                      ? Colors.white
                                      : Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Cancel button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _showCartModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  padding: const EdgeInsets.all(24),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Cart',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromRGBO(69, 99, 48, 1),
                            ),
                          ),
                          if (_cart.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _cart.clear();
                                });
                                setModalState(() {}); // Update modal UI
                              },
                              child: Text(
                                'Clear All',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Cart items
                      if (_cart.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your cart is empty',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add some delicious matcha drinks!',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final item = _cart[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Drink info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.drinkName,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color.fromRGBO(
                                                    69,
                                                    99,
                                                    48,
                                                    1,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Size: ${item.sizeDisplayName}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              if (item.orderNotes != null &&
                                                  item.orderNotes!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    'Notes: ${item.orderNotes}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        // Remove button
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _cart.removeAt(index);
                                            });
                                            setModalState(
                                              () {},
                                            ); // Update modal UI
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          color: Colors.red,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Quantity and price
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Quantity controls
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (item.quantity <= 1) {
                                                    _cart.removeAt(index);
                                                  } else {
                                                    _cart[index].quantity--;
                                                  }
                                                });
                                                setModalState(
                                                  () {},
                                                ); // Update modal UI
                                              },
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.remove,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              child: Text(
                                                '${item.quantity}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _cart[index].quantity++;
                                                });
                                                setModalState(
                                                  () {},
                                                ); // Update modal UI
                                              },
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Price
                                        Text(
                                          _formatPrice(item.totalPrice),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: const Color.fromRGBO(
                                              69,
                                              99,
                                              48,
                                              1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      // Bottom section with total and checkout
                      if (_cart.isNotEmpty) ...[
                        const Divider(height: 32),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total (${_getTotalCartItems()} items)',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(69, 99, 48, 1),
                              ),
                            ),
                            Text(
                              _formatPrice(_getTotalCartPrice()),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromRGBO(69, 99, 48, 1),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Checkout button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _sendCartToWhatsApp();
                            },
                            icon: const Icon(Icons.chat, size: 20),
                            label: Text(
                              'Order via WhatsApp',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(
                                69,
                                99,
                                48,
                                1,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
          ),
    );
  }

  void _sendCartToWhatsApp() async {
    if (_cart.isEmpty) return;

    String message = 'Hi! I would like to order:\n\n';

    for (int i = 0; i < _cart.length; i++) {
      final item = _cart[i];
      message += '${i + 1}. ${item.drinkName}\n';
      message += '   Size: ${item.sizeDisplayName}\n';
      message += '   Quantity: ${item.quantity}\n';
      message += '   Price: ${_formatPrice(item.totalPrice)}\n';
      if (item.orderNotes != null && item.orderNotes!.isNotEmpty) {
        message += '   Notes: ${item.orderNotes}\n';
      }
      message += '\n';
    }

    message += 'Total: ${_formatPrice(_getTotalCartPrice())}\n';
    message += 'Total Items: ${_getTotalCartItems()}\n\n';
    message +=
        'Please let me know about availability and pickup/delivery options. Thank you!';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl =
        'https://api.whatsapp.com/send?phone=6285946404657&text=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
      // Clear cart after successful order
      setState(() {
        _cart.clear();
      });
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  IconData _getSizeIcon(String sizeName) {
    switch (sizeName.toLowerCase()) {
      case 'cup':
        return Icons.coffee;
      case '250ml':
        return Icons.local_drink;
      case '1l':
        return Icons.sports_bar;
      default:
        return Icons.local_drink;
    }
  }

  String _getSizeDescription(String sizeName) {
    switch (sizeName.toLowerCase()) {
      case 'cup':
        return 'Perfect for a quick drink';
      case '250ml':
        return 'Standard serving size';
      case '1l':
        return 'Great for sharing or bulk';
      default:
        return 'Delicious matcha drink';
    }
  }
}
