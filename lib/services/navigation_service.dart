import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static GlobalKey<NavigatorState>? _navigatorKey;
  
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static NavigatorState? get navigator => _navigatorKey?.currentState;
  static BuildContext? get context => navigator?.context;

  // Safe navigation methods
  static void pop([dynamic result]) {
    try {
      navigator?.pop(result);
    } catch (e) {
      print('Safe pop failed: $e');
    }
  }

  static Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) async {
    try {
      return await navigator?.pushNamed<T>(routeName, arguments: arguments);
    } catch (e) {
      print('Safe pushNamed failed: $e');
      return null;
    }
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) async {
    try {
      return await navigator?.pushReplacementNamed<T, TO>(
        routeName,
        arguments: arguments,
        result: result,
      );
    } catch (e) {
      print('Safe pushReplacementNamed failed: $e');
      return null;
    }
  }

  static bool canPop() {
    try {
      return navigator?.canPop() ?? false;
    } catch (e) {
      print('Safe canPop failed: $e');
      return false;
    }
  }

  static void showSnackBar(SnackBar snackBar) {
    try {
      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Safe showSnackBar failed: $e');
    }
  }

  static Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    String? barrierLabel,
    Color? barrierColor,
  }) async {
    try {
      if (context != null) {
        return await showDialog<T>(
          
          builder: builder,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          barrierColor: barrierColor,
        );
      }
      return null;
    } catch (e) {
      print('Safe showDialog failed: $e');
      return null;
    }
  }

  static void popUntilRoot() {
    try {
      navigator?.popUntil((route) => route.isFirst);
    } catch (e) {
      print('Safe popUntilRoot failed: $e');
    }
  }

  static void popAll() {
    try {
      while (canPop()) {
        pop();
      }
    } catch (e) {
      print('Safe popAll failed: $e');
    }
  }
}