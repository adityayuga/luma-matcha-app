# Matcha Drinks Menu Feature

## Overview
A modern and simple matcha drinks menu page has been added to the Luma Matcha app. This feature allows customers to browse through different categories of matcha drinks with beautiful UI and easy ordering options.

## Features

### 🍵 **Categorized Menu**
- **Signature Drinks**: Featured premium matcha beverages
- **Hot Drinks**: Warm matcha beverages
- **Cold Drinks**: Refreshing iced matcha drinks
- **Desserts**: Matcha-based dessert drinks

### 🎨 **Modern UI Design**
- Clean, minimalist card-based layout
- Smooth category navigation tabs
- Popular drink badges
- Responsive grid layout (2 columns on mobile)

### 💰 **Pricing Display**
- Clear price formatting (Rp format with thousand separators)
- Prominent display of drink prices

### 📱 **Easy Ordering**
- Direct WhatsApp ordering with pre-filled message
- GrabFood integration for delivery orders
- Modal bottom sheet for ordering options

### 🔧 **Navigation**
- Seamless integration with existing app navigation
- Back button to return to main menu
- Clean URL routing (`/matcha-menu`)

## Implementation Details

### Files Added:
1. `lib/models/drink_item.dart` - Data models for drinks and categories
2. `lib/screens/matcha_menu_page.dart` - Main menu page implementation

### Files Modified:
1. `lib/main.dart` - Added routing and navigation for the new menu page

### UI Components:
- **Category Tabs**: Horizontal scrollable tabs with icons
- **Drink Cards**: Modern card design with images, names, descriptions, and prices
- **Order Modal**: Bottom sheet with ordering options
- **Navigation**: Clean app bar with back button

### Integration:
- **WhatsApp**: Pre-filled message with drink details
- **GrabFood**: Direct link to restaurant's GrabFood page
- **Navigation**: Uses GoRouter for seamless navigation

## Usage

1. From the main menu, tap on "Matcha Drinks" 
2. Browse through categories using the top navigation tabs
3. View drink details including name, description, and price
4. Tap the "+" button on any drink card to see ordering options
5. Choose between WhatsApp or GrabFood ordering

## Customization

### Adding New Drinks:
Update the `categories` list in `MatcDrinkMenuPageState` with new `DrinkItem` objects.

### Modifying Categories:
Add new `DrinkCategory` objects to the `categories` list.

### Styling:
Colors and styling can be modified in the page's build methods. The app uses:
- Primary color: `Color.fromRGBO(69, 99, 48, 1)` (Green)
- Background: `Color.fromRGBO(254, 255, 250, 1)` (Light cream)
- Google Fonts: Poppins for consistent typography

## Future Enhancements

- [ ] Add actual drink images (currently uses placeholder icons)
- [ ] Implement shopping cart functionality
- [ ] Add drink customization options (size, sweetness, etc.)
- [ ] Add favorites/wishlist feature
- [ ] Include nutritional information
- [ ] Add user reviews and ratings
- [ ] Implement search functionality
- [ ] Add inventory management (sold out indicators)

## Development Notes

The feature is fully integrated into the existing app architecture and uses the same design patterns and color scheme for consistency.
