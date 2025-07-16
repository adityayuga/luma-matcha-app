# Matcha Menu - Multi-Size Pricing Feature

## Overview
The matcha menu now supports multiple size options with different pricing for each drink item.

## Features

### Data Model
- **DrinkSize**: New model supporting different sizes (Cup, 250ml, 1L)
- **DrinkItem**: Updated to contain a list of sizes instead of single price
- **Flexible Pricing**: Each size has its own price and display name

### Available Sizes
1. **Cup** - Traditional serving size
2. **250ml** - Standard bottle size
3. **1 Liter** - Bulk/family size

### Menu Categories
1. **Signature** - Premium drinks with all size options
2. **Hot Drinks** - Traditional warm matcha beverages
3. **Cold Drinks** - Refreshing iced matcha options
4. **Desserts** - Special matcha-based dessert drinks

### UI Features
- **Price Range Display**: Shows "Rp 25.000 - Rp 85.000" for multi-size items
- **Size Indicators**: Shows "3 sizes" badge on cards with multiple options
- **Size Selection Dialog**: Interactive dialog for choosing size before ordering
- **Modal Details**: Enhanced drink details showing all available sizes and prices

### WhatsApp Integration
- **Smart Ordering**: Automatically shows size selection for multi-size items
- **Single Size**: Direct ordering for items with only one size
- **Formatted Messages**: Includes size and price information in WhatsApp messages

## Implementation Details

### Price Formatting
```dart
String _formatPrice(double price) {
  return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.')}';
}
```

### Size Selection
- Multiple sizes trigger a dialog for selection
- Single size items proceed directly to WhatsApp
- Size information is included in order messages

### Data Structure
```dart
DrinkItem(
  name: 'Matcha Latte Premium',
  description: 'Rich matcha blended with steamed milk',
  sizes: [
    DrinkSize(name: 'cup', displayName: 'Cup', price: 25000, unit: 'cup'),
    DrinkSize(name: '250ml', displayName: '250ml', price: 28000, unit: 'ml'),
    DrinkSize(name: '1L', displayName: '1 Liter', price: 85000, unit: 'L'),
  ],
  // ... other properties
)
```

## Usage
1. Navigate to the matcha menu
2. Browse drinks by category
3. View price ranges and size options
4. Tap "Order Now" to select size (if multiple options)
5. Confirm order via WhatsApp

## Benefits
- **Flexible Pricing**: Different sizes for different needs
- **Clear Information**: Users see all options before ordering
- **Seamless UX**: Smooth flow from browsing to ordering
- **Real-world Ready**: Matches actual menu structure
