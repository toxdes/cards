# Card Type Picker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a card type/variant picker to the add new card form that allows users to manually select their card provider (Visa, MasterCard, Amex, Discover, RuPay, Unknown) while maintaining auto-detection for complete card numbers.

**Architecture:** Two new widgets (CardTypeSelector + CardTypePickerModal) following existing modal patterns. AddNewCardForm manages state and auto-detection logic. CardNumberInput gets a callback to notify parent of number changes.

**Tech Stack:** Flutter, existing CardUtils, SelectFromOptions component, BottomSheet component

---

## File Structure

```
lib/components/home/
  ├── card_type_selector.dart          (NEW) - Compact selector widget
  ├── card_type_picker_modal.dart      (NEW) - Modal with grid of options
  ├── add_new_card_form.dart           (MODIFY) - Add state and integration
  └── card_number_input.dart           (MODIFY) - Add callback prop

lib/utils/card_utils.dart              (MODIFY) - Add helper functions
```

---

## Task 1: Add Helper Functions to CardUtils

**Files:**
- Modify: `lib/utils/card_utils.dart`

**Purpose:** Add utility functions to convert between CardProvider enum and the string keys used by SelectOption.

- [ ] **Step 1: Add cardProviderToKey function**

Add this function to the `CardUtils` class after the existing `getCardProviderFromString` function:

```dart
static String cardProviderToKey(CardProvider provider) {
  return provider.toString().split('.').last;
}
```

- [ ] **Step 2: Add keyToCardProvider function**

Add this function after `cardProviderToKey`:

```dart
static CardProvider keyToCardProvider(String key) {
  return CardProvider.values.firstWhere(
    (p) => cardProviderToKey(p) == key,
    orElse: () => CardProvider.unknown,
  );
}
```

- [ ] **Step 3: Add getCardProviderOptions function**

Add this function after `keyToCardProvider`:

```dart
static List<SelectOption> getCardProviderOptions() {
  return [
    SelectOption(
      key: 'visa',
      label: 'Visa',
      icon: Icons.credit_card,
    ),
    SelectOption(
      key: 'mastercard',
      label: 'MasterCard',
      icon: Icons.credit_card,
    ),
    SelectOption(
      key: 'amex',
      label: 'Amex',
      icon: Icons.credit_card,
    ),
    SelectOption(
      key: 'discover',
      label: 'Discover',
      icon: Icons.credit_card,
    ),
    SelectOption(
      key: 'rupay',
      label: 'RuPay',
      icon: Icons.credit_card,
    ),
    SelectOption(
      key: 'unknown',
      label: 'Unknown',
      icon: Icons.help_outline,
    ),
  ];
}
```

- [ ] **Step 4: Add missing import**

Add this import at the top of the file:

```dart
import 'package:cards/components/shared/select_from_options.dart';
```

- [ ] **Step 5: Run flutter analyze to verify**

Run: `flutter analyze lib/utils/card_utils.dart`
Expected: No errors or warnings

- [ ] **Step 6: Commit**

```bash
git add lib/utils/card_utils.dart
git commit -m "feat: add card provider conversion helpers

Add utility functions to convert between CardProvider enum and
string keys for use with SelectOption component.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 2: Create CardTypeSelector Widget

**Files:**
- Create: `lib/components/home/card_type_selector.dart`

**Purpose:** Compact form widget showing current card type selection. Tappable to open modal.

- [ ] **Step 1: Write the widget**

Create the file with this complete implementation:

```dart
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card/card.dart';
import 'package:flutter/material.dart';

class CardTypeSelector extends StatelessWidget {
  final String title;
  final CardProvider selectedProvider;
  final VoidCallback onTap;

  const CardTypeSelector({
    super.key,
    required this.title,
    required this.selectedProvider,
    required this.onTap,
  });

  String _getProviderLabel() {
    switch (selectedProvider) {
      case CardProvider.visa:
        return "Visa";
      case CardProvider.mastercard:
        return "MasterCard";
      case CardProvider.amex:
        return "Amex";
      case CardProvider.discover:
        return "Discover";
      case CardProvider.rupay:
        return "RuPay";
      case CardProvider.unknown:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8));
    const EdgeInsets padding = EdgeInsets.all(16);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontFamily: Fonts.rubik,
            fontSize: 14,
            color: ThemeColors.white3,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: ThemeColors.gray2,
              borderRadius: borderRadius,
              border: Border.all(
                width: 1,
                color: ThemeColors.white3,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getProviderLabel(),
                  style: const TextStyle(
                    fontFamily: Fonts.rubik,
                    fontSize: 16,
                    color: ThemeColors.white2,
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  color: ThemeColors.white3,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze to verify**

Run: `flutter analyze lib/components/home/card_type_selector.dart`
Expected: No errors or warnings

- [ ] **Step 3: Commit**

```bash
git add lib/components/home/card_type_selector.dart
git commit -m "feat: add CardTypeSelector widget

Add compact selector widget for card type that displays
current selection and opens picker modal on tap.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 3: Create CardTypePickerModal Widget

**Files:**
- Create: `lib/components/home/card_type_picker_modal.dart`

**Purpose:** Bottom sheet modal with grid of card type options using SelectFromOptions.

- [ ] **Step 1: Write the widget**

Create the file with this complete implementation:

```dart
import 'package:cards/components/shared/select_from_options.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/utils/card_utils.dart';
import 'package:cards/components/shared/bottom_sheet.dart';
import 'package:flutter/material.dart' hide BottomSheet;

class CardTypePickerModal extends StatelessWidget {
  final String title;
  final String closeLabel;
  final VoidCallback onClose;
  final bool isVisible;
  final CardProvider currentProvider;
  final Function(CardProvider) onProviderSelected;

  const CardTypePickerModal({
    super.key,
    required this.title,
    required this.closeLabel,
    required this.onClose,
    required this.isVisible,
    required this.currentProvider,
    required this.onProviderSelected,
  });

  SelectOption? _findSelectedOption() {
    final providerKey = CardUtils.cardProviderToKey(currentProvider);
    final options = CardUtils.getCardProviderOptions();

    for (final option in options) {
      if (option.key == providerKey) {
        return option;
      }
    }
    return null;
  }

  void _handleOptionSelection(SelectOption selectedOption) {
    final provider = CardUtils.keyToCardProvider(selectedOption.key);
    onProviderSelected(provider);
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = _findSelectedOption();

    return BottomSheet(
      title: title,
      closeLabel: closeLabel,
      onClose: onClose,
      isVisible: isVisible,
      maxHeightFactor: 0.6,
      child: SelectFromOptions(
        options: CardUtils.getCardProviderOptions(),
        selectedOption: selectedOption,
        onSelectOption: _handleOptionSelection,
        vertical: true,
      ),
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze to verify**

Run: `flutter analyze lib/components/home/card_type_picker_modal.dart`
Expected: No errors or warnings

- [ ] **Step 3: Commit**

```bash
git add lib/components/home/card_type_picker_modal.dart
git commit -m "feat: add CardTypePickerModal widget

Add bottom sheet modal for card type selection using
SelectFromOptions in vertical grid layout.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 4: Modify CardNumberInput to Add Callback

**Files:**
- Modify: `lib/components/home/card_number_input.dart`

**Purpose:** Add callback to notify parent when card number changes for auto-detection.

- [ ] **Step 1: Add onCardNumberChanged prop**

Add the new property to the `CardNumberInput` class:

```dart
final VoidCallback? onCardNumberChanged;
```

Add it after the `onToggleCompleteCardNumber` prop (around line 17).

- [ ] **Step 2: Update constructor**

Update the constructor to include the new parameter. Add it after `onToggleCompleteCardNumber`:

```dart
const CardNumberInput(
    {super.key,
    required this.title,
    required this.helper,
    required this.hint,
    required this.keyboardType,
    required this.inputFormatters,
    required this.validator,
    required this.controller,
    required this.updateFormStatus,
    required this.onToggleCompleteCardNumber,
    required this.isCompleteCardNumber,
    this.onCardNumberChanged});
```

- [ ] **Step 3: Update TextInputField in build method**

Modify the `TextInputField` in the build method to add `onChanged` callback. Find the `TextInputField` widget (around line 65) and add the `onChanged` parameter:

```dart
Widget build(BuildContext context) {
  return TextInputField(
      title: "Card number",
      helper: "All good!",
      hint: isCompleteCardNumber ? "XXXX XXXX XXXX XXXX" : "XXXX",
      keyboardType: TextInputType.number,
      inputFormatters: inputFormatters,
      validator: validator,
      prefix: prefix,
      controller: controller,
      updateFormStatus: updateFormStatus,
      onChanged: (_) => onCardNumberChanged?.call());
}
```

- [ ] **Step 4: Add onChanged to TextInputField widget (if needed)**

If `TextInputField` doesn't already support `onChanged`, you'll need to add it. Check the widget definition in `lib/components/shared/textinput.dart`. It should already call `updateFormStatus` in `onChanged`, so we may need to modify that.

Looking at the TextInputField code, it already has `onChanged` internal logic. We need to add an optional callback prop. Let's modify TextInputField first.

- [ ] **Step 5: Add onChanged callback to TextInputField**

Actually, looking at the code, `TextInputField` already calls `updateFormStatus()` in its `onChanged`. We need to add an additional callback. Modify `lib/components/shared/textinput.dart`:

Add prop to `TextInputField` class:
```dart
final VoidCallback? onChanged;
```

Add to constructor (after `updateFormStatus`):
```dart
final void Function() updateFormStatus;
final VoidCallback? onChanged;
```

Update the `onChanged` in `TextFormField` (around line 108):
```dart
onChanged: (String? value) {
  widget.updateFormStatus();
  widget.onChanged?.call();
},
```

- [ ] **Step 6: Update CardNumberInput to pass the callback**

Now update the `TextInputField` call in `CardNumberInput`:

```dart
Widget build(BuildContext context) {
  return TextInputField(
      title: "Card number",
      helper: "All good!",
      hint: isCompleteCardNumber ? "XXXX XXXX XXXX XXXX" : "XXXX",
      keyboardType: TextInputType.number,
      inputFormatters: inputFormatters,
      validator: validator,
      prefix: prefix,
      controller: controller,
      updateFormStatus: updateFormStatus,
      onChanged: onCardNumberChanged);
}
```

- [ ] **Step 7: Run flutter analyze to verify**

Run: `flutter analyze lib/components/home/card_number_input.dart lib/components/shared/textinput.dart`
Expected: No errors or warnings

- [ ] **Step 8: Commit**

```bash
git add lib/components/home/card_number_input.dart lib/components/shared/textinput.dart
git commit -m "feat: add card number change callback

Add onChanged callback to TextInputField and CardNumberInput
to support auto-detection of card type from number input.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 5: Modify AddNewCardForm - Add State

**Files:**
- Modify: `lib/components/home/add_new_card_form.dart`

**Purpose:** Add state variables for card provider selection and manual selection flag.

- [ ] **Step 1: Add state variables**

Add these state variables to `_AddNewCardFormState` class after the existing state variables (around line 24):

```dart
CardProvider _selectedProvider = CardProvider.unknown;
bool _isProviderManuallySelected = false;
bool _isCardTypePickerVisible = false;
```

- [ ] **Step 2: Run flutter analyze to verify**

Run: `flutter analyze lib/components/home/add_new_card_form.dart`
Expected: No errors or warnings

- [ ] **Step 3: Commit**

```bash
git add lib/components/home/add_new_card_form.dart
git commit -m "feat: add card provider state to AddNewCardForm

Add state variables for tracking selected card provider,
manual selection flag, and picker visibility.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 6: Modify AddNewCardForm - Add Handler Methods

**Files:**
- Modify: `lib/components/home/add_new_card_form.dart`

**Purpose:** Add methods to handle card number changes, provider selection, and provider reset.

- [ ] **Step 1: Add _onCardNumberChanged method**

Add this method after the `updateFormValidationStatus` method (around line 66):

```dart
void _onCardNumberChanged(String _) {
  if (!_isProviderManuallySelected && _isCompleteCardNumber) {
    final cleanNumber = StringUtils.removeAll(_numberController.text, ' ');
    final detected = CardUtils.getProviderFromNumber(cleanNumber);
    if (detected != _selectedProvider) {
      setState(() {
        _selectedProvider = detected;
      });
    }
  }
}
```

- [ ] **Step 2: Add _onProviderSelected method**

Add this method after `_onCardNumberChanged`:

```dart
void _onProviderSelected(CardProvider provider) {
  setState(() {
    _selectedProvider = provider;
    _isProviderManuallySelected = true;
  });
  _toggleCardTypePicker(false);
}
```

- [ ] **Step 3: Add _resetProvider method**

Add this method after `_onProviderSelected`:

```dart
void _resetProvider() {
  setState(() {
    _selectedProvider = CardProvider.unknown;
    _isProviderManuallySelected = false;
  });
}
```

- [ ] **Step 4: Add _toggleCardTypePicker method**

Add this method after `_resetProvider`:

```dart
void _toggleCardTypePicker(bool? visibility) {
  setState(() {
    _isCardTypePickerVisible = visibility ?? !_isCardTypePickerVisible;
  });
}
```

- [ ] **Step 5: Modify onToggleCompleteCardNumber method**

Update the existing `onToggleCompleteCardNumber` method to call `_resetProvider()` (around line 68):

```dart
void onToggleCompleteCardNumber() {
  CardFieldsValidator.setIsCompleteCardNumber(!_isCompleteCardNumber);
  _cardNumberFormatter.setIsCompleteCardNumber(!_isCompleteCardNumber);
  _numberController.text = "";
  _resetProvider();
  setState(() {
    _isCompleteCardNumber = !_isCompleteCardNumber;
  });
}
```

- [ ] **Step 6: Run flutter analyze to verify**

Run: `flutter analyze lib/components/home/add_new_card_form.dart`
Expected: No errors or warnings

- [ ] **Step 7: Commit**

```bash
git add lib/components/home/add_new_card_form.dart
git commit -m "feat: add card type handlers to AddNewCardForm

Add methods for handling card number changes (auto-detection),
manual provider selection, provider reset, and picker visibility.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 7: Modify AddNewCardForm - Update CardNumberInput

**Files:**
- Modify: `lib/components/home/add_new_card_form.dart`

**Purpose:** Pass the new callback to CardNumberInput.

- [ ] **Step 1: Update CardNumberInput widget call**

Find the `CardNumberInput` widget in the build method (around line 88) and add the `onCardNumberChanged` parameter:

```dart
CardNumberInput(
  title: "Card number",
  helper: "All good!",
  hint: "XXXX XXXX XXXX XXXX",
  keyboardType: TextInputType.number,
  inputFormatters: [_cardNumberFormatter],
  validator: CardFieldsValidator.number,
  controller: _numberController,
  updateFormStatus: updateFormValidationStatus,
  isCompleteCardNumber: _isCompleteCardNumber,
  onToggleCompleteCardNumber: onToggleCompleteCardNumber,
  onCardNumberChanged: () => _onCardNumberChanged(_numberController.text),
),
```

- [ ] **Step 2: Run flutter analyze to verify**

Run: `flutter analyze lib/components/home/add_new_card_form.dart`
Expected: No errors or warnings

- [ ] **Step 3: Commit**

```bash
git add lib/components/home/add_new_card_form.dart
git commit -m "feat: wire card number change callback

Connect CardNumberInput's onChanged callback to enable
real-time card type auto-detection.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 8: Modify AddNewCardForm - Add CardTypeSelector and Modal

**Files:**
- Modify: `lib/components/home/add_new_card_form.dart`

**Purpose:** Integrate CardTypeSelector into the form layout and add the modal.

- [ ] **Step 1: Add imports**

Add these imports at the top of the file:

```dart
import 'package:cards/components/home/card_type_selector.dart';
import 'package:cards/components/home/card_type_picker_modal.dart';
```

- [ ] **Step 2: Add CardTypeSelector after CardNumberInput**

In the build method, after the `CardNumberInput` widget (after line 99), add:

```dart
const SizedBox(height: 8),
CardTypeSelector(
  title: "Card type",
  selectedProvider: _selectedProvider,
  onTap: () => _toggleCardTypePicker(true),
),
const SizedBox(height: 8),
```

- [ ] **Step 3: Add CardTypePickerModal at the end of Column**

Add the modal widget at the end of the Column's children array (after the Button widget, around line 183):

```dart
CardTypePickerModal(
  title: "Select Card Type",
  closeLabel: "Close",
  onClose: () => _toggleCardTypePicker(false),
  isVisible: _isCardTypePickerVisible,
  currentProvider: _selectedProvider,
  onProviderSelected: _onProviderSelected,
),
```

Note: The Column should still have `mainAxisSize: MainAxisSize.min`, so the modal being a child won't affect the form layout since BottomSheet uses Positioned/Stack internally.

- [ ] **Step 4: Run flutter analyze to verify**

Run: `flutter analyze lib/components/home/add_new_card_form.dart`
Expected: No errors or warnings

- [ ] **Step 5: Commit**

```bash
git add lib/components/home/add_new_card_form.dart
git commit -m "feat: integrate CardTypeSelector and modal into form

Add CardTypeSelector widget after card number field and
CardTypePickerModal to the form for card type selection.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 9: Verify Form Submission Uses Selected Provider

**Files:**
- Modify: `lib/components/home/add_new_card_form.dart`

**Purpose:** Ensure form submission uses the selected provider from state.

- [ ] **Step 1: Check form submission code**

Verify that the Button's `onTap` callback (around line 160) already uses `_selectedProvider`:

```dart
..setProvider(_isCompleteCardNumber
    ? CardUtils.getProviderFromNumber(
        StringUtils.removeAll(_numberController.text, ' '))
    : CardProvider.unknown)
```

This should be changed to:

```dart
..setProvider(_selectedProvider)
```

- [ ] **Step 2: Update the setProvider call**

Find and replace the old logic with:

```dart
Button(
    color: ThemeColors.blue,
    onTap: () {
      if (_isFormValid) {
        CardModel card = CardModelFactory.blank()
          ..setTitle(_titleController.text)
          ..setNumber(
              StringUtils.removeAll(_numberController.text, ' '))
          ..setExpiry(_expiryController.text)
          ..setOwnerName(_ownerNameController.text)
          ..setProvider(_selectedProvider)
          ..setCVV(_cvvController.text)
          ..setCardNumberType(_isCompleteCardNumber
              ? CardNumberType.complete
              : CardNumberType.last4);
        widget.onSubmit(card);
      }
    },
    disabled: !_isFormValid,
    alignment: Alignment.center,
    height: 48,
    label: "Save card")
```

- [ ] **Step 3: Run flutter analyze to verify**

Run: `flutter analyze lib/components/home/add_new_card_form.dart`
Expected: No errors or warnings

- [ ] **Step 4: Commit**

```bash
git add lib/components/home/add_new_card_form.dart
git commit -m "fix: use selected provider in form submission

Update form submission to use the _selectedProvider state
instead of re-detecting from card number.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 10: Manual Testing

**Files:**
- None (testing)

**Purpose:** Manually test the implementation to ensure all behaviors work correctly.

- [ ] **Step 1: Build and run the app**

Run: `flutter run`

- [ ] **Step 2: Test auto-detection with complete card number**

1. Open "Add new card" form
2. Ensure "Complete" mode is selected
3. Enter a Visa test number: `4111111111111111`
4. Expected: Card type should auto-detect to "Visa"
5. Enter a MasterCard test number: `5555555555554444`
6. Expected: Card type should auto-detect to "MasterCard"

- [ ] **Step 3: Test manual selection override**

1. With a card number entered that detected "Visa"
2. Tap on "Card type" field
3. Expected: Modal opens with card type options
4. Tap "MasterCard"
5. Expected: Modal closes, Card type shows "MasterCard"
6. Change card number to another Visa number
7. Expected: Card type stays "MasterCard" (manual selection persists)

- [ ] **Step 4: Test mode switching**

1. With a card number entered and type detected
2. Tap "Last 4" button
3. Expected: Card number clears, Card type resets to "Unknown"
4. Tap "Complete" button
5. Expected: Card type stays "Unknown" ready for new input

- [ ] **Step 5: Test last 4 mode**

1. Switch to "Last 4" mode
2. Enter 4 digits: `1234`
3. Tap "Card type" field
4. Expected: Modal opens
5. Select "Visa"
6. Expected: Modal closes, Card type shows "Visa"
7. Fill out rest of form and submit
8. Expected: Card is saved with provider=Visa

- [ ] **Step 6: Test form submission**

1. Fill out complete form with all fields
2. Ensure form validation passes
3. Tap "Save card"
4. Expected: Card is saved successfully with selected provider

- [ ] **Step 7: Test unknown card type**

1. Select "Complete" mode
2. Enter an invalid number: `9999999999999999`
3. Expected: Card type shows "Unknown"
4. Tap "Card type" and select "RuPay"
5. Expected: Card type changes to "RuPay"

- [ ] **Step 8: Test modal close behavior**

1. Open card type picker modal
2. Tap "Close" button
3. Expected: Modal closes, card type unchanged

- [ ] **Step 9: Test all card types**

Verify all card types are selectable:
- Visa ✓
- MasterCard ✓
- Amex ✓
- Discover ✓
- RuPay ✓
- Unknown ✓

- [ ] **Step 10: Check for visual consistency**

1. Verify CardTypeSelector matches other form fields
2. Verify spacing is consistent
3. Verify colors match app theme
4. Verify modal follows existing modal pattern
5. Verify icons display correctly

---

## Task 11: Final Review and Documentation

**Files:**
- None (review)

**Purpose:** Final code review and ensure everything is working.

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors or warnings

- [ ] **Step 2: Run formatter**

Run: `dart format .`
Expected: Code is properly formatted

- [ ] **Step 3: Check for unused imports**

Verify no unused imports in modified files:
- `lib/utils/card_utils.dart`
- `lib/components/home/card_type_selector.dart`
- `lib/components/home/card_type_picker_modal.dart`
- `lib/components/home/add_new_card_form.dart`
- `lib/components/home/card_number_input.dart`
- `lib/components/shared/textinput.dart`

- [ ] **Step 4: Verify git status**

Run: `git status`
Expected: All changes are staged and committed appropriately

- [ ] **Step 5: Final commit (if any formatting fixes)**

If formatter made changes:

```bash
git add -u
git commit -m "style: apply dart formatter

Run dart format to ensure code formatting consistency.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

- [ ] **Step 6: Document the feature (optional)**

If you want to add documentation, update relevant README or docs files with information about the new card type picker feature.

---

## Completion Checklist

- [ ] All tasks completed
- [ ] All tests pass (manual testing completed)
- [ ] No analyzer errors or warnings
- [ ] Code is formatted
- [ ] Feature works as specified in design document
- [ ] All edge cases handled
- [ ] UI matches existing app design

## Summary

This implementation adds a card type picker to the add new card form with the following capabilities:

1. **Auto-detection**: Card type is automatically detected from complete card numbers
2. **Manual selection**: Users can override auto-detection by manually selecting a card type
3. **Mode awareness**: Resets to "Unknown" when switching to "Last 4" mode
4. **Consistent UI**: Follows existing app patterns and design system
5. **Modal picker**: Uses bottom sheet modal with grid layout for selection

The implementation follows TDD principles where applicable, maintains code consistency with the existing codebase, and provides a clean separation of concerns.
