import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Brand palette
// ─────────────────────────────────────────────
const _kPrimary = Color(0xFF006C67);
const _kError = Color(0xFFB3261E);

// ─────────────────────────────────────────────
// Status system
// ─────────────────────────────────────────────
class BookingStatus {
  BookingStatus._();

  static String label(String raw) {
    switch (raw) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'en_route':
        return 'On the way';
      case 'in_progress':
        return 'In progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return raw[0].toUpperCase() + raw.substring(1);
    }
  }

  static Color color(String raw) {
    switch (raw) {
      case 'pending':
        return const Color(0xFFE07B00);
      case 'accepted':
        return const Color(0xFF1565C0);
      case 'en_route':
        return const Color(0xFF4527A0);
      case 'in_progress':
        return _kPrimary;
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'cancelled':
        return const Color(0xFF757575);
      default:
        return const Color(0xFF757575);
    }
  }
}

// ─────────────────────────────────────────────
// Service icon helper (by name keyword)
// ─────────────────────────────────────────────
class ServiceIcon {
  ServiceIcon._();

  static IconData forName(String nameEn) {
    final n = nameEn.toLowerCase();
    if (n.contains('ac') || n.contains('air') || n.contains('cool') || n.contains('hvac')) {
      return Icons.ac_unit_rounded;
    }
    if (n.contains('plumb') || n.contains('pipe') || n.contains('water') || n.contains('drain')) {
      return Icons.plumbing_rounded;
    }
    if (n.contains('electr') || n.contains('wiring') || n.contains('power')) {
      return Icons.electrical_services_rounded;
    }
    if (n.contains('paint')) return Icons.format_paint_rounded;
    if (n.contains('clean')) return Icons.cleaning_services_rounded;
    if (n.contains('pest') || n.contains('insect')) return Icons.bug_report_rounded;
    if (n.contains('lock') || n.contains('key')) return Icons.lock_rounded;
    return Icons.home_repair_service_rounded;
  }
}

// ─────────────────────────────────────────────
// App theme
// ─────────────────────────────────────────────
ThemeData buildAppTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: _kPrimary,
    error: _kError,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: base,
    scaffoldBackgroundColor: const Color(0xFFF6F8FA),
    appBarTheme: AppBarTheme(
      backgroundColor: base.surface,
      foregroundColor: base.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: TextStyle(
        color: base.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kError, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade600),
      floatingLabelStyle: const TextStyle(color: _kPrimary),
      prefixIconColor: Colors.grey.shade600,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _kPrimary),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade200, space: 1),
    tabBarTheme: TabBarThemeData(
      labelColor: _kPrimary,
      unselectedLabelColor: Colors.grey.shade600,
      indicatorColor: _kPrimary,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const Color(0xFF2E7D32);
        return Colors.grey.shade300;
      }),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    ),
  );
}

// ─────────────────────────────────────────────
// Reusable UI widgets
// ─────────────────────────────────────────────

/// Color-coded status badge chip.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.small = false});
  final String status;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final color = BookingStatus.color(status);
    final label = BookingStatus.label(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: small ? 11 : 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// Section label used in detail screens.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Standard empty state placeholder.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standard error state.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
