class DrinkSize {
  final String name;
  final String displayName;
  final double price;
  final String unit; // ml, L, cup, etc.

  DrinkSize({
    required this.name,
    required this.displayName,
    required this.price,
    required this.unit,
  });
}

class DrinkItem {
  final String name;
  final String description;
  final String imagePath;
  final List<DrinkSize> sizes;
  final String category;
  final bool isPopular;
  final bool isHot;
  final bool isCold;

  DrinkItem({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.sizes,
    required this.category,
    this.isPopular = false,
    this.isHot = true,
    this.isCold = true,
  });

  // Get the default/smallest size
  DrinkSize get defaultSize => sizes.first;
  
  // Get price range string
  String get priceRange {
    if (sizes.length == 1) {
      return 'Rp ${sizes.first.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')}';
    } else {
      final minPrice = sizes.map((s) => s.price).reduce((a, b) => a < b ? a : b);
      final maxPrice = sizes.map((s) => s.price).reduce((a, b) => a > b ? a : b);
      return 'Rp ${minPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')} - ${maxPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')}';
    }
  }
}

class DrinkCategory {
  final String name;
  final String icon;
  final List<DrinkItem> items;

  DrinkCategory({
    required this.name,
    required this.icon,
    required this.items,
  });
}
