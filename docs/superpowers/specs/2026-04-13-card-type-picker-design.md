# Card Type Picker Feature Design

**Date:** 2026-04-13
**Status:** Approved
**Related Branch:** `feat/add-new-form-updates`

## Overview

Add a card type/variant picker to the add new card form that allows users to manually select their card provider (Visa, MasterCard, Amex, Discover, RuPay, Unknown). This is necessary because the form now supports entering only the last 4 digits, which makes auto-detection impossible in that mode.

## Requirements

1. **Manual Selection:** Users can manually select card type via a picker UI
2. **Auto-Detection:** When entering complete 16-digit card number, auto-detect card type
3. **Manual Override:** User can override auto-detected type with manual selection
4. **Mode Switching:** Reset to "Unknown" when switching to "Last 4" mode
5. **Consistent UI:** Follow existing app design patterns and coding standards

## Component Architecture

### New Components

1. **`CardTypeSelector`** (`lib/components/home/card_type_selector.dart`)
   - Compact form widget showing current selection
   - Tappable to open modal
   - Follows `TextInputField` visual style

2. **`CardTypePickerModal`** (`lib/components/home/card_type_picker_modal.dart`)
   - Bottom sheet modal with card type options
   - Uses `SelectFromOptions` in vertical grid layout
   - Follows existing modal pattern (`AddNewCardModal`, `SortAndFilterModal`)

### Modified Components

1. **`AddNewCardForm`**
   - Adds state: `CardProvider _selectedProvider`
   - Adds state: `bool _isProviderManuallySelected`
   - Integrates `CardTypeSelector` after card number field
   - Adds auto-detection logic

2. **`CardNumberInput`**
   - Adds `onCardNumberChanged` callback prop
   - Notifies parent when card number changes

## Widget Interfaces

### CardTypeSelector

```dart
class CardTypeSelector extends StatelessWidget {
  final String title;                    // "Card Type"
  final CardProvider selectedProvider;   // Current selection
  final VoidCallback onTap;              // Opens the modal
}
```

**UI Specification:**
- Follows `TextInputField` visual style exactly
- Title text: 14px, `ThemeColors.white3`, `Fonts.rubik`
- Container: `ThemeColors.gray2` background, 8px border radius, 16px padding
- Value text: `ThemeColors.white2`, shows current selection label
- Right icon: `Icons.expand_more` or `Icons.keyboard_arrow_up`
- Border: Gray normally, blue when modal is open
- Tap: Calls `onTap()` to open modal

### CardTypePickerModal

```dart
class CardTypePickerModal extends StatelessWidget {
  final String title;                    // "Select Card Type"
  final String closeLabel;               // "Close"
  final VoidCallback onClose;
  final bool isVisible;
  final CardProvider currentProvider;
  final Function(CardProvider) onProviderSelected;
}
```

**UI Specification:**
- Wraps existing `BottomSheet` component (not Flutter's)
- Import pattern: `import 'package:flutter/material.dart' hide BottomSheet;`
- `maxHeightFactor: 0.6`
- Child: `SelectFromOptions` with `vertical: true` (grid layout)

## Auto-Detection Logic

### Real-Time Detection (Complete Mode Only)

```dart
void _onCardNumberChanged(String number) {
  if (!_isProviderManuallySelected && _isCompleteCardNumber) {
    final detected = CardUtils.getProviderFromNumber(number);
    if (detected != _selectedProvider) {
      setState(() {
        _selectedProvider = detected;
      });
    }
  }
}
```

**Behavior:**
- Listens to card number input changes
- Only auto-detects if user hasn't manually selected
- Only auto-detects in "Complete" mode
- Updates state when detected provider differs

### Mode Switching Behavior

**Switch to "Last 4":**
- Reset `_selectedProvider = CardProvider.unknown`
- Reset `_isProviderManuallySelected = false`
- Clear card number input

**Switch to "Complete":**
- Reset `_selectedProvider = CardProvider.unknown`
- Reset `_isProviderManuallySelected = false`
- Clear card number input
- Ready for new input/detection

### Manual Selection Override

```dart
void _onProviderSelected(CardProvider provider) {
  setState(() {
    _selectedProvider = provider;
    _isProviderManuallySelected = true;
  });
}
```

**Behavior:**
- Once user manually selects, auto-detection is disabled
- Manual selection persists even if card number changes
- Only reset when toggling card number mode

## Data Structures

### Card Provider Options

```dart
List<SelectOption> getCardProviderOptions() {
  return [
    SelectOption(key: 'visa', label: 'Visa', icon: Icons.credit_card),
    SelectOption(key: 'mastercard', label: 'MasterCard', icon: Icons.credit_card),
    SelectOption(key: 'amex', label: 'Amex', icon: Icons.credit_card),
    SelectOption(key: 'discover', label: 'Discover', icon: Icons.credit_card),
    SelectOption(key: 'rupay', label: 'RuPay', icon: Icons.credit_card),
    SelectOption(key: 'unknown', label: 'Unknown', icon: Icons.help_outline),
  ];
}
```

### Helper Functions

```dart
// Convert CardProvider enum to string key
String cardProviderToKey(CardProvider provider) {
  return provider.toString().split('.').last;
}

// Convert string key to CardProvider enum
CardProvider keyToCardProvider(String key) {
  return CardProvider.values.firstWhere(
    (p) => cardProviderToKey(p) == key,
    orElse: () => CardProvider.unknown,
  );
}
```

## State Management

### AddNewCardForm State

```dart
CardProvider _selectedProvider = CardProvider.unknown;
bool _isProviderManuallySelected = false;
```

### Key Methods

1. **`_onCardNumberChanged(String)`** - Handle card number input, trigger auto-detection
2. **`_onProviderSelected(CardProvider)`** - Handle manual card type selection
3. **`_resetProvider()`** - Reset provider state to unknown
4. **Modified `onToggleCompleteCardNumber()`** - Reset provider on mode toggle

### Form Submission

No changes needed - already uses `_selectedProvider`:
```dart
..setProvider(_selectedProvider)
```

## Visual Design

### Icons
- Visa, MasterCard, Amex, Discover, RuPay: `Icons.credit_card`
- Unknown: `Icons.help_outline`

### Colors
- Background: `ThemeColors.gray2`
- Text label: `ThemeColors.white3`
- Text value: `ThemeColors.white2`
- Selected border: `ThemeColors.blue`
- Unselected border: `ThemeColors.white3`

### Typography
- Font family: `Fonts.rubik`
- Label size: 14px
- Value size: 16px

## Implementation Checklist

- [ ] Create `CardTypeSelector` widget
- [ ] Create `CardTypePickerModal` widget
- [ ] Add card provider options mapping
- [ ] Add helper functions (enum conversion)
- [ ] Modify `CardNumberInput` to accept `onCardNumberChanged` callback
- [ ] Modify `AddNewCardForm`:
  - Add state variables
  - Add auto-detection logic
  - Integrate `CardTypeSelector` into form layout
  - Add modal state management
  - Update mode toggle logic
- [ ] Test auto-detection with real card numbers
- [ ] Test manual selection override
- [ ] Test mode switching behavior
- [ ] Test form submission with various card types

## Edge Cases

1. **Empty card number:** Provider remains `unknown`
2. **Invalid/incomplete number:** Provider remains `unknown`
3. **Number changes after manual selection:** Keep manual selection (don't re-detect)
4. **User switches modes:** Reset to `unknown`
5. **User closes modal without selecting:** No change to selection

## Testing Considerations

- Auto-detection with valid Visa, MasterCard, Amex, Discover, RuPay numbers
- Auto-detection with invalid numbers (should stay unknown)
- Manual selection overrides auto-detection
- Mode switching resets state correctly
- Form submission stores correct provider
- UI matches existing form fields style
