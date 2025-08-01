import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulparambil/Core/Utils/size_utils.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:auto_scroll_text/auto_scroll_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../Core/CommenWidgets/custom_image_view.dart';
import '../../../Core/CommenWidgets/space.dart';
import '../../../Core/Theme/new_custom_text_style.dart';
import '../../../Core/Theme/theme_helper.dart';
import '../../../Core/Utils/image_constant.dart';
import '../../../Models/spread_document_model.dart';
import '../../NewsScreen/Controller/news_controller.dart';
import '../Controller/live_controller.dart';
import 'dart:math' as Math;

import '../Repository/live_repository.dart';
import '../Repository/newTest.dart';
import 'commodity_list.dart';
import 'live_rate_widget.dart';

final rateBidValue = StateProvider(
  (ref) {
    return 0.0;
  },
);

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState createState() => _LivePageState();
}

final spreadDataProvider2 = StateProvider<SpreadDocumentModel?>(
  (ref) {
    return null;
  },
);

class _LivePageState extends ConsumerState<LivePage> {
  late Timer _timer;
  String formattedTime = DateFormat('h:mm:ss a').format(DateTime.now());
  final formattedTimeProvider = StateProvider(
    (ref) => DateFormat('h:mm a').format(DateTime.now()),
  );
  final bdTimeProvider = StateProvider(
    (ref) => "",
  );
  final uaeTimeProvider = StateProvider(
    (ref) => "",
  );
  final usTimeProvider = StateProvider(
    (ref) => "",
  );

  final goldAskPrice = StateProvider.autoDispose<double>(
    (ref) => 0,
  );
  final silverAskPrice = StateProvider.autoDispose<double>(
    (ref) => 0,
  );
  void _updateTime(Timer timer) {
    ref.read(formattedTimeProvider.notifier).update(
          (state) => DateFormat('h:mm a').format(DateTime.now()),
        );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String getMarketStatus() {
    DateTime now = DateTime.now();
    int currentDay = now.weekday;

    DateTime nextOpeningTime;
    if (currentDay >= DateTime.monday && currentDay <= DateTime.friday) {
      if (now.hour == 0 && now.minute == 0) {
        return 'Market is open.';
      } else {
        // Next opening time is tomorrow at midnight
        nextOpeningTime =
            DateTime(now.year, now.month, now.day).add(Duration(days: 1));
      }
    } else {
      // It's weekend, next opening is on Monday
      int daysUntilMonday = (DateTime.monday - currentDay + 7) % 7;
      nextOpeningTime = DateTime(now.year, now.month, now.day)
          .add(Duration(days: daysUntilMonday));
    }

    Duration timeUntilOpen = nextOpeningTime.difference(now);
    int days = timeUntilOpen.inDays;
    int hours = timeUntilOpen.inHours % 24;
    int minutes = timeUntilOpen.inMinutes % 60;

    List<String> parts = [];
    if (days > 0) parts.add('$days d${days > 1 ? 's' : ''}');
    if (hours > 0) parts.add('$hours h${hours > 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes m${minutes > 1 ? 's' : ''}');

    String countdownText = parts.join(', ');

    return 'Market is closed. It will open in $countdownText.';
  }

  @override
  void initState() {
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        _updateTime(timer);
        // convertTimes(timer);
      },
    );
    super.initState();
  }

  final bannerBool = StateProvider.autoDispose(
    (ref) => false,
  );
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 18.0.v, right: 18.v),
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      // width: SizeUtils.width / 3,
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            color: appTheme.whiteA700,
                          ),
                          Text(
                            DateFormat("MMM dd yyyy").format(DateTime.now()),
                            style: CustomPoppinsTextStyles.bodyText12,
                          ),
                          Text(
                              DateFormat("EEEE")
                                  .format(DateTime.now())
                                  .toUpperCase(),
                              style: CustomPoppinsTextStyles.bodyText12)
                        ],
                      ),
                    ),
                    CustomImageView(
                      imagePath: ImageConstants.logo,
                      width: 220.h,
                    ),
                    SizedBox(
                      // width: SizeUtils.width / 3,
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            color: appTheme.whiteA700,
                          ),
                          Consumer(
                            builder: (context, ref, child) => Text(
                              ref.watch(formattedTimeProvider),
                              style: CustomPoppinsTextStyles.bodyText12,
                            ),
                          ),
                          space()
                        ],
                      ),
                    )
                  ],
                ),
                space(),
                space(),
                Container(
                  height: 55.h,
                  decoration: BoxDecoration(
                    color: appTheme.gold,
                    borderRadius: BorderRadius.circular(15.v),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      space(w: 50.h),
                      Spacer(),
                      Text(
                        "BUY\$",
                        style: CustomPoppinsTextStyles.bodyText1White,
                      ),
                      Spacer(),
                      Text(
                        "SELL\$",
                        style: CustomPoppinsTextStyles.bodyText1White,
                      ),
                      space(w: 50.h)
                    ],
                  ),
                ),
                space(),
                Consumer(
                  builder: (context, ref1, child) {
                    return ref1.watch(spotRateProvider).when(
                      data: (spotRate) {
                        if (spotRate != null) {
                          final liveRateData = ref1.watch(liveRateProvider);
                          if (liveRateData != null &&
                              liveRateData.gold != null &&
                              liveRateData.silver != null) {
                            final spreadNow = spotRate.info;
                            WidgetsBinding.instance.addPostFrameCallback(
                              (timeStamp) {
                                ref1.read(bannerBool.notifier).update(
                                  (state) {
                                    return liveRateData.gold!.marketStatus !=
                                            "TRADEABLE"
                                        ? true
                                        : false;
                                  },
                                );
                                ref1.read(rateBidValue.notifier).update(
                                  (state) {
                                    return liveRateData.gold!.bid +
                                        (spreadNow.goldBidSpread);
                                  },
                                );
                                ref1.read(goldAskPrice.notifier).update(
                                  (state) {
                                    final res = (liveRateData.gold!.bid +
                                        (spreadNow.goldBidSpread));
                                    return res;
                                  },
                                );
                                ref1.read(silverAskPrice.notifier).update(
                                  (state) {
                                    final res = (liveRateData.gold!.bid +
                                        (spreadNow.goldAskSpread) +
                                        (spreadNow.goldBidSpread) +
                                        0.5);
                                    return res;
                                  },
                                );
                              },
                            );
                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius:
                                          BorderRadius.circular(10.v)),
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Gold",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize))
                                      ])),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ValueDisplayWidget(
                                              value: (liveRateData.gold!.bid +
                                                  (spreadNow.goldBidSpread))),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                                size: 20.v,
                                              ),
                                              Text(
                                                "${liveRateData.gold!.low + (spreadNow.goldLowMargin)}",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ValueDisplayWidget2(
                                              value: liveRateData.gold!.bid +
                                                  spreadNow.goldBidSpread +
                                                  spreadNow.goldAskSpread +
                                                  0.5),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                                size: 20.v,
                                              ),
                                              Text(
                                                "${liveRateData.gold!.high + (spreadNow.goldHighMargin)}",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                space(),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius:
                                          BorderRadius.circular(10.v)),
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Silver",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize))
                                      ])),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ValueDisplayWidgetSilver1(
                                              value: (liveRateData.silver!.bid +
                                                  (spreadNow.silverBidSpread ??
                                                      0))),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                                size: 20.v,
                                              ),
                                              Text(
                                                (liveRateData.silver!.low +
                                                        (spreadNow
                                                            .silverLowMargin))
                                                    .toStringAsFixed(2),
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ValueDisplayWidgetSilver2(
                                              value: (liveRateData.silver!.bid +
                                                  (spreadNow.silverBidSpread ??
                                                      0) +
                                                  (spreadNow.silverAskSpread ??
                                                      0) +
                                                  0.05)),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                                size: 20.v,
                                              ),
                                              Text(
                                                (liveRateData.silver!.high +
                                                        (spreadNow
                                                            .silverHighMargin))
                                                    .toStringAsFixed(2),
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                space(),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Card(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: SizeUtils.width,
                                    height: SizeUtils.height * 0.1,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                              text: "Gold",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextGold),
                                          TextSpan(
                                              text: "OZ",
                                              style: GoogleFonts.poppins(
                                                  // fontFamily: marine,
                                                  color: appTheme.gold,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15.fSize))
                                        ])),
                                        Column(
                                          children: [
                                            ValueDisplayWidget(value: 0.0),
                                            Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .arrowtriangle_down_fill,
                                                  color: appTheme.red700,
                                                ),
                                                Text(
                                                  "0.0",
                                                  style: CustomPoppinsTextStyles
                                                      .bodyTextSemiBold,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            ValueDisplayWidget2(value: 0.0),
                                            Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .arrowtriangle_up_fill,
                                                  color: appTheme.mainGreen,
                                                ),
                                                Text(
                                                  "0.0",
                                                  style: CustomPoppinsTextStyles
                                                      .bodyTextSemiBold,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                space(),
                                Card(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: SizeUtils.width,
                                    height: SizeUtils.height * 0.1,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                              text: "Silver",
                                              style: CustomPoppinsTextStyles
                                                  .bodyTextGold),
                                          TextSpan(
                                              text: "OZ",
                                              style: GoogleFonts.poppins(
                                                  // fontFamily: marine,
                                                  color: appTheme.gold,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15.fSize))
                                        ])),
                                        Column(
                                          children: [
                                            ValueDisplayWidgetSilver1(
                                                value: 0.0),
                                            Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .arrowtriangle_down_fill,
                                                  color: appTheme.red700,
                                                ),
                                                Text(
                                                  "0.0",
                                                  style: CustomPoppinsTextStyles
                                                      .bodyTextSemiBold,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            ValueDisplayWidgetSilver2(
                                                value: 0.0),
                                            Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .arrowtriangle_up_fill,
                                                  color: appTheme.mainGreen,
                                                ),
                                                Text(
                                                  "0.0",
                                                  style: CustomPoppinsTextStyles
                                                      .bodyTextSemiBold,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                space(),
                              ],
                            );
                          }
                        } else {
                          return Column(
                            children: [
                              Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Gold",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize))
                                      ])),
                                      Column(
                                        children: [
                                          ValueDisplayWidget(value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ValueDisplayWidget2(value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              space(),
                              Card(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: SizeUtils.width,
                                  height: SizeUtils.height * 0.1,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "Silver",
                                            style: CustomPoppinsTextStyles
                                                .bodyTextGold),
                                        TextSpan(
                                            text: "OZ",
                                            style: GoogleFonts.poppins(
                                                // fontFamily: marine,
                                                color: appTheme.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.fSize))
                                      ])),
                                      Column(
                                        children: [
                                          ValueDisplayWidgetSilver1(value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_down_fill,
                                                color: appTheme.red700,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ValueDisplayWidgetSilver2(value: 0.0),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .arrowtriangle_up_fill,
                                                color: appTheme.mainGreen,
                                              ),
                                              Text(
                                                "0.0",
                                                style: CustomPoppinsTextStyles
                                                    .bodyTextSemiBold,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              space(),
                            ],
                          );
                        }
                      },
                      error: (error, stackTrace) {
                        print("###ERROR###");
                        print(error.toString());
                        print(stackTrace);
                        return const Center(
                          child: Text("Something Went Wrong"),
                        );
                      },
                      loading: () {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  },
                ),
                Center(
                  child: Consumer(
                    builder: (context, ref2, child) => CommodityList(
                      price: ref2.watch(goldAskPrice),
                      slverPrice: ref2.watch(silverAskPrice),
                    ),
                  ),
                ),
                space(),
                Consumer(
                  builder: (context, ref1, child) {
                    return ref1.watch(newsProvider).when(
                          data: (data123) {
                            if (data123 != null) {
                              return AutoScrollText(
                                delayBefore: const Duration(seconds: 1),
                                "${data123.news.news[0].title}    ${data123.news.news[0].title}",
                                style: CustomPoppinsTextStyles.bodyText,
                              );
                            } else {
                              return Text(
                                "PULPARAMBIL GOLD & DIAMONDS    PULPARAMBIL GOLD & DIAMONDS   PULPARAMBIL GOLD & DIAMONDS",
                                style: CustomPoppinsTextStyles.bodyText,
                              );
                            }
                          },
                          error: (error, stackTrace) {
                            print(stackTrace);
                            print(error.toString());
                            return SizedBox();
                          },
                          loading: () => SizedBox(),
                        );
                  },
                ),
              ],
            ),
          ),
        ),
        if (ref.watch(bannerBool))
          Positioned(
            top: 15.v,
            right: 90.h,
            child: Transform.rotate(
              angle: -Math.pi / 4,
              child: Consumer(
                builder: (context, refBanner, child) {
                  return Container(
                    width: SizeUtils.width,
                    height: 30.h,
                    color: Colors.red,
                    child: Center(
                      child: AutoScrollText(
                        delayBefore: const Duration(seconds: 3),
                        "           Market is closed. It will open soon!            ",
                        style: CustomPoppinsTextStyles.buttonText,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
