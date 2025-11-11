import 'package:cards/components/shared/button.dart';
import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/models/card/card.dart';
import 'package:cards/services/notification_service.dart';
import 'package:cards/services/platform_service.dart';
import 'package:cards/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardView extends StatefulWidget {
  final CardModel card;
  final Function(CardModel) onLongPress;
  CardView({required this.card, required this.onLongPress})
      : super(key: ObjectKey((card)));

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  bool _active = false;
  DateTime startTs = DateTime.now(), endTs = DateTime.now();
  void setActive(bool newValue) {
    setState(() {
      _active = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.card.getNumber()));
        String notificationTitle = "Card details: ${widget.card.getTitle()}";
        String notificationBody =
            "Expiry: ${widget.card.getExpiryView()} | CVV: ${widget.card.getCVV()}\nCard number is copied to clipboard.";
        if (PlatformService.isAndroid()) {
          notificationBody =
              "Expiry: <strong>${widget.card.getExpiryView()}</strong> | CVV: <strong>${widget.card.getCVV()}</strong><br/><i>Card number is copied to clipboard.</i>";
        }
        ToastService.show(
            message: "Number copied to clipboard", status: ToastStatus.success);
        NotificationService.showNotification(
            title: notificationTitle, body: notificationBody);
      },
      onTapDown: (TapDownDetails _) {
        setActive(true);
      },
      onTapUp: (TapUpDetails _) {
        setActive(false);
      },
      onTapCancel: () {
        setActive(false);
      },
      onLongPress: () {
        showAdaptiveDialog(
            context: context,
            barrierColor: ThemeColors.gray1.withValues(alpha: 0.9),
            builder: (BuildContext context) {
              return Dialog(
                  // alignment: Alignment.center,
                  child: Container(
                height: 140,
                width: 320,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                    color: ThemeColors.gray3,
                    border: Border.all(color: ThemeColors.white3),
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Do you want to delete this card?",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: Fonts.rubik, color: ThemeColors.white2),
                    ),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Button(
                          color: ThemeColors.blue,
                          buttonType: ButtonType.ghost,
                          text: "No",
                          height: 36,
                          onTap: () {
                            Navigator.of(context).pop();
                            setActive(false);
                          }),
                      const SizedBox(width: 12),
                      Button(
                          color: ThemeColors.red2,
                          buttonType: ButtonType.ghost,
                          text: "Yes",
                          height: 36,
                          onTap: () {
                            widget.onLongPress(widget.card);
                            Navigator.of(context).pop();
                            setActive(false);
                          })
                    ])
                  ],
                ),
              ));
            });
      },
      child: AnimatedContainer(
        // animated props
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        transformAlignment: Alignment.center,
        transform: _active
            ? (Matrix4.identity()..scaleByDouble(0.90, 0.90, 1, 1))
            : (Matrix4.identity()),
        child: Container(
            margin: const EdgeInsets.fromLTRB(4, 16, 4, 16),
            height: 220,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _active
                    ? ThemeColors.red.withValues(alpha: 0.3)
                    : ThemeColors.gray2,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.getTitle(),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                      color: ThemeColors.teal,
                      fontFamily: Fonts.rubik,
                      fontWeight: FontWeight.w400,
                      fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.card.getNumberView(),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                      color: ThemeColors.white2,
                      fontFamily: Fonts.rubik,
                      fontWeight: FontWeight.w400,
                      fontSize: 24),
                ),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.card.getExpiryView(),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            color: ThemeColors.white2,
                            fontFamily: Fonts.rubik,
                            fontWeight: FontWeight.w400,
                            fontSize: 16),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        widget.card.getCVV(),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: ThemeColors.white2,
                            fontFamily: Fonts.rubik,
                            fontWeight: FontWeight.w400,
                            fontSize: 16),
                      )
                    ]),
                Expanded(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                      Expanded(
                          child: Text(
                        widget.card.getOwnerName().toUpperCase(),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            color: ThemeColors.white3,
                            fontFamily: Fonts.rubik,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2,
                            fontSize: 14),
                      )),
                      Text(
                        widget.card.getProviderView(),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color:
                                widget.card.getProvider() == CardProvider.visa
                                    ? ThemeColors.yellow
                                    : widget.card.getProvider() ==
                                            CardProvider.rupay
                                        ? ThemeColors.green
                                        : ThemeColors.red,
                            fontFamily: Fonts.rubik,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      )
                    ]))
              ],
            )),
      ),
    );
  }
}
