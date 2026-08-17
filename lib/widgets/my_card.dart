import 'package:flutter/material.dart';
import '../app_config.dart';
import 'package:sltnoc/alarms/alarms_page.dart';
import 'package:sltnoc/clarity_page.dart';
import 'package:sltnoc/escalations_page.dart';
import 'package:sltnoc/planOutages/plan_Outages.dart';
import 'package:sltnoc/ai_chat_page.dart';

/// Unified MyCard widget that replaces duplicate implementations across:
/// - home_page.dart
/// - clarity_page.dart
/// - escalations_page.dart
/// - alarms/current_alarms/selected_metro_region.dart
/// - alarms/current_alarms/regions.dart
class MyCard extends StatelessWidget {
  /// Layout type: 'home' (vertical column), 'list' (horizontal row with icon), 'metro' (horizontal row, title only)
  final String layout;

  /// Card title (main text)
  final String title;

  /// Optional subtitle (used in 'home' and 'list' layouts)
  final String? subtitle;

  /// Optional newSubtitle (used in 'home' and 'list' layouts)
  final String? newSubtitle;

  /// Optional display name (used in 'home' layout for PlanOutagesPage)
  final String? displayName;

  /// Border color for the card
  final Color borderColor;

  /// Navigation target page identifier (used in 'home' layout)
  final String? page;

  /// Tap callback (used in 'list' and 'metro' layouts)
  final VoidCallback? onTap;

  /// Optional badge count (used in 'list' layout for escalations)
  final int badgeCount;

  /// Card height (used in 'metro' layout)
  final double? height;

  /// Card padding (used in 'metro' layout)
  final double? cardPadding;

  /// Width between icon and content (used in 'list' and 'metro' layouts)
  final double? widthBetweenIconAndContent;

  /// Forward icon color override (used in 'metro' layout)
  final Color? forwardIconColor;

  /// Forward icon color 2 override (used in selected_metro_region)
  final Color? forwardIconColor2;

  const MyCard({
    Key? key,
    required this.layout,
    required this.title,
    this.subtitle,
    this.newSubtitle,
    this.displayName,
    required this.borderColor,
    this.page,
    this.onTap,
    this.badgeCount = 0,
    this.height,
    this.cardPadding,
    this.widthBetweenIconAndContent,
    this.forwardIconColor,
    this.forwardIconColor2,
  }) : super(key: key);

  /// Factory for 'home' layout (vertical column, used in home_page.dart)
  factory MyCard.home({
    Key? key,
    required String title,
    required String subtitle,
    required String newSubtitle,
    String? displayName,
    required Color borderColor,
    required String page,
  }) = _HomeCard;

  /// Factory for 'list' layout (horizontal row with icon, used in clarity_page.dart, escalations_page.dart)
    factory MyCard.list({
      Key? key,
      required String title,
      required String subtitle,
      required String newSubtitle,
      required Color borderColor,
      required VoidCallback onTap,
      required int badgeCount,
    }) = _ListCard;

  /// Factory for 'metro' layout (horizontal row, title only, used in alarms pages)
  factory MyCard.metro({
    Key? key,
    required String title,
    required Color borderColor,
    required VoidCallback onTap,
    double? height,
    double? cardPadding,
    double? widthBetweenIconAndContent,
    Color? forwardIconColor,
    Color? forwardIconColor2,
  }) = _MetroCard;

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case 'home':
        return _buildHomeCard(context);
      case 'list':
        return _buildListCard(context);
      case 'metro':
        return _buildMetroCard(context);
      default:
        return _buildHomeCard(context);
    }
  }

  Widget _buildHomeCard(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {
        if (page == 'alarms') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AlarmsPage(
                title: 'Alarms',
                subtitle: 'Network Alarms',
                newSubtitle: 'EMS / NMS',
              ),
            ),
          );
        } else if (page == 'clarity') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClarityPage(
                title: 'Clarity',
                subtitle: 'Clarity Fault Dockets',
                newSubtitle: 'Clarity',
              ),
            ),
          );
        } else if (page == 'escalations') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EscalationsPage(
                title: 'Escalations',
                subtitle: 'Fault Escalations',
                newSubtitle: 'FMT / SAT',
              ),
            ),
          );
        } else if (page == 'planOutages') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanOutagesPage(
                title: 'Planned Outages',
                name: displayName ?? title,
              ),
            ),
          );
        } else if (page == 'aiChat') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AIChatPage(),
            ),
          );
        }
      },
      splashColor: Colors.white,
      child: Card(
        elevation: AppConfig.elevation,
        margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConfig.cardBackgroundImagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppConfig.homePageCardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 0.04 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                    height: 0.01 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight)),
                Text(
                  subtitle ?? '',
                  style: TextStyle(
                      color: Color(0xFF0056A2),
                      fontSize: 0.035 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                    height: 0.01 *
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? screenWidth
                            : screenHeight)),
                Text(
                  newSubtitle ?? '',
                  style: TextStyle(
                      color: Color(0xFF50B748),
                      fontSize: 0.035 *
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? screenWidth
                              : screenHeight),
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white,
      child: Card(
        elevation: AppConfig.elevation,
        margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConfig.cardBackgroundImagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIcon(context),
                SizedBox(
                    width: widthBetweenIconAndContent ??
                        AppConfig.widthBetweenIconAndContent),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 0.042 *
                                (MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? screenWidth
                                    : screenHeight),
                            fontWeight: FontWeight.w900,
                            color: Colors.black),
                      ),
                      const SizedBox(height: AppConfig.lineSpacing),
                      Text(
                        subtitle ?? '',
                        style: TextStyle(
                            color: Color(0xFF0056A2),
                            fontSize: 0.037 *
                                (MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? screenWidth
                                    : screenHeight),
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: AppConfig.lineSpacing),
                      Text(
                        newSubtitle ?? '',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 0.037 *
                                (MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? screenWidth
                                    : screenHeight),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                Icon(AppConfig.forwardIcon,
                    size: AppConfig.forwardIconSize,
                    color: AppConfig.forwardIconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetroCard(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white,
      child: Card(
        elevation: AppConfig.elevation,
        margin: EdgeInsets.symmetric(vertical: AppConfig.heightBetweenCards),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        color: Colors.transparent,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConfig.cardBackgroundImagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding ?? AppConfig.metroCardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIcon(context),
                SizedBox(
                    width: widthBetweenIconAndContent ??
                        AppConfig.widthBetweenIconAndContent),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 0.042 *
                                (MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? screenWidth
                                    : screenHeight),
                            fontWeight: FontWeight.w800,
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Icon(
                    AppConfig.forwardIcon,
                    size: AppConfig.forwardIconSize,
                    color: forwardIconColor2 ??
                        forwardIconColor ??
                        AppConfig.forwardIconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Icon based on title/page
    IconData iconData;
    Color iconColor;

    if (layout == 'home') {
      switch (page) {
        case 'alarms':
          iconData = Icons.warning_amber_rounded;
          iconColor = Colors.red;
          break;
        case 'clarity':
          iconData = Icons.visibility_rounded;
          iconColor = Color(0xFF0056A2);
          break;
        case 'escalations':
          iconData = Icons.trending_up_rounded;
          iconColor = Colors.orange;
          break;
        case 'planOutages':
          iconData = Icons.schedule_rounded;
          iconColor = Colors.purple;
          break;
        case 'aiChat':
          iconData = Icons.smart_toy_rounded;
          iconColor = Colors.green;
          break;
        default:
          iconData = Icons.dashboard_rounded;
          iconColor = Color(0xFF0056A2);
      }
    } else if (layout == 'list') {
      // Clarity page icons
      if (title.toLowerCase().contains('clarity') ||
          title.toLowerCase().contains('fault')) {
        iconData = Icons.visibility_rounded;
        iconColor = Color(0xFF0056A2);
      } else if (title.toLowerCase().contains('escalation')) {
        iconData = Icons.trending_up_rounded;
        iconColor = Colors.orange;
      } else {
        iconData = Icons.dashboard_rounded;
        iconColor = Color(0xFF0056A2);
      }
    } else {
      // Metro layout - use a generic icon
      iconData = Icons.location_city_rounded;
      iconColor = Color(0xFF0056A2);
    }

    return Icon(
      iconData,
      size: 0.06 * (MediaQuery.of(context).orientation == Orientation.portrait
          ? screenWidth
          : screenHeight),
      color: iconColor,
    );
  }
}

/// Private subclass for home layout
class _HomeCard extends MyCard {
  const _HomeCard({
    Key? key,
    required String title,
    required String subtitle,
    required String newSubtitle,
    String? displayName,
    required Color borderColor,
    required String page,
  }) : super(
          key: key,
          layout: 'home',
          title: title,
          subtitle: subtitle,
          newSubtitle: newSubtitle,
          displayName: displayName,
          borderColor: borderColor,
          page: page,
        );
}

/// Private subclass for list layout
class _ListCard extends MyCard {
  const _ListCard({
    Key? key,
    required String title,
    required String subtitle,
    required String newSubtitle,
    required Color borderColor,
    required VoidCallback onTap,
    required int badgeCount,
  }) : super(
          key: key,
          layout: 'list',
          title: title,
          subtitle: subtitle,
          newSubtitle: newSubtitle,
          borderColor: borderColor,
          onTap: onTap,
          badgeCount: badgeCount,
        );
}

/// Private subclass for metro layout
class _MetroCard extends MyCard {
  const _MetroCard({
    Key? key,
    required String title,
    required Color borderColor,
    required VoidCallback onTap,
    double? height,
    double? cardPadding,
    double? widthBetweenIconAndContent,
    Color? forwardIconColor,
    Color? forwardIconColor2,
  }) : super(
          key: key,
          layout: 'metro',
          title: title,
          borderColor: borderColor,
          onTap: onTap,
          height: height,
          cardPadding: cardPadding,
          widthBetweenIconAndContent: widthBetweenIconAndContent,
          forwardIconColor: forwardIconColor,
          forwardIconColor2: forwardIconColor2,
        );
}