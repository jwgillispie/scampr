import 'package:flutter/material.dart';

class NatureTheme {
  // Enhanced Nature Color Palette
  static const Color deepForest = Color(0xFF1B4332);
  static const Color forestGreen = Color(0xFF2E7D32);
  static const Color mossGreen = Color(0xFF52796F);
  static const Color leafGreen = Color(0xFF74C69D);
  static const Color springGreen = Color(0xFF95D5B2);
  static const Color paleGreen = Color(0xFFB7E4C7);
  static const Color mintGreen = Color(0xFFD8F3DC);
  
  // Earth Tones
  static const Color darkBrown = Color(0xFF3C2415);
  static const Color chestnutBrown = Color(0xFF8D6E63);
  static const Color warmBrown = Color(0xFFA1887F);
  static const Color lightBrown = Color(0xFFBCAAA4);
  static const Color cream = Color(0xFFF3E5AB);
  
  // Sky & Nature Accents
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color cloudWhite = Color(0xFFF8F8FF);
  static const Color sunYellow = Color(0xFFFFD700);
  static const Color autumnOrange = Color(0xFFFF8C00);
  static const Color berryRed = Color(0xFFDC143C);
  
  // Seasonal Themes
  static const Color springBlossom = Color(0xFFFFB6C1);
  static const Color summerGold = Color(0xFFFFA500);
  static const Color autumnAmber = Color(0xFFFF8C00);
  static const Color winterBlue = Color(0xFF4682B4);
  
  // Gradient Definitions
  static const LinearGradient forestGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepForest, forestGreen, mossGreen],
  );
  
  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sunYellow, autumnOrange, berryRed],
  );
  
  static const LinearGradient leafGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [leafGreen, springGreen, paleGreen],
  );
  
  static const LinearGradient earthGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBrown, chestnutBrown, warmBrown],
  );
  
  // Shadow Definitions
  static const BoxShadow forestShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 8,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow leafShadow = BoxShadow(
    color: Colors.green,
    blurRadius: 12,
    offset: Offset(0, 6),
    spreadRadius: 1,
  );
  
  static const BoxShadow glowShadow = BoxShadow(
    color: Colors.lightGreenAccent,
    blurRadius: 20,
    offset: Offset(0, 0),
    spreadRadius: 5,
  );
  
  // Nature-inspired Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forestGreen,
        brightness: Brightness.light,
        primary: forestGreen,
        secondary: chestnutBrown,
        tertiary: leafGreen,
        surface: cloudWhite,
        onSurface: deepForest,
      ),
      fontFamily: 'Georgia',
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: forestGreen,
        foregroundColor: cloudWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
          color: cloudWhite,
        ),
        iconTheme: const IconThemeData(
          color: cloudWhite,
          size: 28,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: cloudWhite,
          elevation: 8,
          shadowColor: Colors.black38,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: forestGreen,
        foregroundColor: cloudWhite,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        surfaceTintColor: paleGreen,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: deepForest,
        selectedItemColor: springGreen,
        unselectedItemColor: mossGreen,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Georgia',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paleGreen.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: forestGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: mossGreen, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: forestGreen, width: 3),
        ),
        prefixIconColor: forestGreen,
        suffixIconColor: forestGreen,
        hintStyle: TextStyle(
          color: mossGreen,
          fontFamily: 'Georgia',
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: paleGreen,
        selectedColor: leafGreen,
        secondarySelectedColor: springGreen,
        labelStyle: const TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      iconTheme: const IconThemeData(
        color: forestGreen,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: mossGreen,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: deepForest,
        contentTextStyle: const TextStyle(
          color: cloudWhite,
          fontFamily: 'Georgia',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forestGreen,
        brightness: Brightness.dark,
        primary: leafGreen,
        secondary: chestnutBrown,
        tertiary: springGreen,
        surface: darkBrown,
        onSurface: cloudWhite,
      ),
      fontFamily: 'Georgia',
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: AppBarTheme(
        backgroundColor: deepForest,
        foregroundColor: cloudWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
          color: cloudWhite,
        ),
        iconTheme: const IconThemeData(
          color: cloudWhite,
          size: 28,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: leafGreen,
          foregroundColor: deepForest,
          elevation: 8,
          shadowColor: Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: leafGreen,
        foregroundColor: deepForest,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        surfaceTintColor: darkBrown,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBrown,
        selectedItemColor: springGreen,
        unselectedItemColor: mossGreen,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Georgia',
        ),
      ),
    );
  }
  
  static TextTheme _buildTextTheme({bool isDark = false}) {
    final Color textColor = isDark ? cloudWhite : deepForest;
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Georgia',
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Georgia',
        color: textColor,
      ),
    );
  }
}

// Custom Decorations for Nature Effects
class NatureDecorations {
  static BoxDecoration get forestCard => BoxDecoration(
    gradient: NatureTheme.leafGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [NatureTheme.forestShadow],
  );
  
  static BoxDecoration get earthCard => BoxDecoration(
    gradient: NatureTheme.earthGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [NatureTheme.forestShadow],
  );
  
  static BoxDecoration get sunriseCard => BoxDecoration(
    gradient: NatureTheme.sunriseGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [NatureTheme.forestShadow],
  );
  
  static BoxDecoration get glowingCard => BoxDecoration(
    color: NatureTheme.paleGreen,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [NatureTheme.glowShadow],
  );
}

// Custom Animations for Nature Effects
class NatureAnimations {
  static const Duration gentle = Duration(milliseconds: 800);
  static const Duration moderate = Duration(milliseconds: 1200);
  static const Duration slow = Duration(milliseconds: 2000);
  
  static const Curve organic = Curves.elasticOut;
  static const Curve natural = Curves.easeInOutCubic;
  static const Curve flowing = Curves.fastOutSlowIn;
}