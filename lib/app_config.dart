import 'package:flutter/material.dart';

class AppConfig {
  // App bar
  static const Color appBarBG = Color(0xFF0056a2); // App Bar BG color
  static const TextStyle appBarTextStyle = TextStyle(
      fontSize: 18,
      color: Colors.white,
      fontWeight: FontWeight.bold); // Styles for App Bar texts
  static const double toolbarHeight = 60.0; // Height of the App Bar

  // Body
  static Color BodyBG = Colors.grey[300]!; // BG color of the Page
  static const double tablePagePadding =
      15.0; // Padding of the pages which have TABLES
  static const String bodyBackgroundImagePath = 'assets/appbarbg2.png';

  // API Configuration
  static String get apiBaseUrl {
    // Try to get from environment variable (--dart-define)
    String envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    // Fallback to default Azure URL
    return 'https://sltnoc-api.azurewebsites.net';
  }

  // Card
  static const double homePageCardPadding = 15.0; // Padding
  static const double cardPadding = 15.0; // Padding
  static double cardBorderRadius = 10.0; // Border Radius
  static double heightBetweenCards = 5.0; // Height between two cards
  static double elevation = 4.0; // Shadow of a card
  static const double widthBetweenIconAndContent =
      20.0; // Width between icon and the Card content
  static const TextStyle title = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: Colors.black); // Styles for title
  static const TextStyle subtitle = TextStyle(
      color: Color(0xFF0056A2),
      fontSize: 18,
      fontWeight: FontWeight.w500); // Styles for subtitle
  static const TextStyle newSubtitle = TextStyle(
      color: Colors.green,
      fontSize: 18,
      fontWeight: FontWeight.w500); // Styles for newSubtitle
  static const double lineSpacing =
      4.0; // Line spacing between title, subtitle and newSubtitle
  static const double iconSize = 30.0; // Size of the icon
  static Color iconColor = Colors.blue[700]!; // Icon color
  static Color iconColor2 = Colors.green[700]!; // Icon color
  static const IconData forwardIcon =
      Icons.arrow_forward_ios_rounded; // Navigation indicator icon type
  static const double forwardIconSize = 20; // Size of the navigator icon
  static Color forwardIconColor =
      Colors.blue[700]!; // Color of the navigator icon
  static Color forwardIconColor2 =
      Colors.green[700]!; // Color of the navigator icon
  static const String cardBackgroundImagePath =
      'assets/CardBG.png'; // BG of the card as an image path

  // Card - Metro and Regions
  static const String metroCardBackgroundImagePath =
      'assets/CardBGMetros.png'; // BG of the card as an image path
  static const double metroCardPadding = 20.0; // Padding
  static const double metroWidthBetweenIconAndContent =
      20.0; // Width between icon and the Card content

  // Table
  static Color tableHeadingColor =
      Colors.green[100]!; // Color of the Table Header
  static TextStyle tableHeadingTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.grey[800]); // Table Header text styles
  static Color tableBorderColor =
      Colors.grey[500]!; // Color of the Table border
  static const Color tableRowColor = Colors.white; // Color of the Table Rows
  static const TextAlign secondColumnDataAlignment =
      TextAlign.right; // Alignment of 2nd column data
  static const TextStyle secondColumnTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF00305e)); // Color of 2nd column data
  static const TextStyle singleLineTableFistColumnTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF00305e)); // Styles for the 1st column values
  static const TextStyle alarmDetails1stLine = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF00305e));
  static const TextStyle alarmDetails2ndLine =
      TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500);
  static const TextStyle alarmDetails3rdLine = TextStyle(
      fontSize: 14,
      color: Colors.green,
      height: 1.3,
      fontWeight: FontWeight.w500);
  static const double SizedBoxHeight = 20.0;
  static const double tableBorderRadius = 5.0; // Table border radius
  static const double columnSpacing = 16.0; // Column space in table

  // Row text styles for
  // Work Groups (2nd page), Faults, Planned Events, Problems, Common Issues
  static const TextStyle firstLineTextStyles1 = TextStyle(
      fontSize: 16,
      color: Color(0xFF00305e),
      fontWeight: FontWeight.bold); // Styles for 1st line
  static const TextStyle secondLineTextStyles1 = TextStyle(
      fontSize: 14,
      color: Colors.red,
      fontWeight: FontWeight.w500); // Styles for 2nd line
  static const TextStyle thirdLineTextStyles1 = TextStyle(
      fontSize: 14,
      color: Colors.green,
      height: 1.3,
      fontWeight: FontWeight.w500); // Styles for 3rd line
  static const double SizedBoxHeight1 = 24.0;

  // Row text styles for
  // CEN-CSC-NW & CEN-CSC-DATA
  static const TextStyle firstLineTextStyles2 = TextStyle(
      fontSize: 14,
      color: Color(0xFF00305e),
      fontWeight: FontWeight.bold); // Styles for 1st line
  static const TextStyle secondLineTextStyles2 = TextStyle(
      fontSize: 14,
      color: Color(0xFF0056A2),
      fontWeight: FontWeight.w500,
      height: 1.3); // Styles for 2nd line
  static const TextStyle thirdLineTextStyles2 =
      TextStyle(fontSize: 14, color: Colors.green); // Styles for 3rd line
  static const double SizedBoxHeight2 = 24.0;

  // Key-Value pair box between App Bar and Data Table
  static const TextStyle labelTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black); // Styles for Label
  static const TextStyle valueTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF0056A2)); // Styles for Value
  static const double SizedBoxWidth = 8.0; // Width between Label and Value
  static const double textBoxPadding =
      12.0; // Padding for the key-value pair box
  static const double textBoxBorderRadius =
      0.0; // Border radius for the key-value pair box
  static Color bgColor1 = Colors.white; // BG color for the key-value pair box
  static const double heightBelowBox = 12.0;
  static BoxShadow fixedTextBoxShadow = BoxShadow(
      color: Colors.grey.withValues(alpha: 0.3),
      spreadRadius: 1,
      blurRadius: 5,
      offset: Offset(0, 3));

  static const Color textColor = Color(0xFF0056A2);

  // Node Details card
  static const Color NDBorderColor = Color(0xFF0056A2);
  static Color NDDivider = Colors.grey.shade300;
  static const double NDBorderRadius = 10.0;
  static const double NDBorderWidth = 1.0;
  static const double NDCardPadding = 20.0;
  static const TextStyle NDTitleTextStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextAlign NDTitleAlignment =
      TextAlign.center; // Alignment of title
  static const double NDlineSpacing =
      3.0; // Line spacing between title, subtitle and newSubtitle

  static const double SizedBoxPlanOutages = 6.0;
  static const TextAlign planOutagesValuesAlign = TextAlign.right;
  static const TextStyle planOutageslabelTextStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.black); // Styles for Label
  static const TextStyle planOutagesvalueTextStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Color(0xFF0056A2)); // Styles for Value
  static const TextStyle planOutagesToandFromvalueTextStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Colors.red); // Styles for Value
}
