class CartItem {
  final String drinkName;
  final String sizeName;
  final String sizeDisplayName;
  final double price;
  final String? orderNotes;
  int quantity;

  CartItem({
    required this.drinkName,
    required this.sizeName,
    required this.sizeDisplayName,
    required this.price,
    this.orderNotes,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  String get displayName => '$drinkName - $sizeDisplayName';
}
