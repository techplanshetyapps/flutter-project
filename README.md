# Flutter Application: Dynamic Design & Widget Showcase

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=materialdesign&logoColor=white)
![Dio](https://img.shields.io/badge/Dio-HTTP%20Client-blue?style=for-the-badge&logo=dart&logoColor=white)
![Dart SDK](https://img.shields.io/badge/Dart-%3E%3D3.0-0175C2?style=flat&logo=dart&logoColor=0175C2&color=121212)

A comprehensive, production-ready Flutter project demonstrating advanced UI development, custom Material Design implementation, dynamic color schemes, and a robust widget architecture.

---

## Project Overview

This project serves as a reference architecture and showcase for modern Flutter development. It implements adaptive Material Design (Material 3), robust state management patterns, custom animations, and a rich library of reusable custom widgets. Designed for high performance, accessibility, and fluid cross-platform execution (iOS, Android, Web, Desktop).

---

## Color Palette & Theming (Material 3)

The application utilizes a sophisticated, desaturated, and professional color palette built on Material 3 guidelines. It supports both dynamic light and dark themes with seamless surface tonal elevations.

| Role | Light Theme Hex | Dark Theme Hex | Description |
| :--- | :--- | :--- | :--- |
| **Primary** | `#1B365D` (Deep Slate Navy) | `#4A7BB0` (Muted Steel Blue) | Brand identity, primary buttons, active tabs |
| **Secondary** | `#D99B26` (Warm Amber/Gold) | `#E6B34D` (Soft Amber) | Accent highlights, floating action buttons, call-to-actions |
| **Tertiary** | `#2E6B5E` (Muted Teal) | `#4DA694` (Bright Teal) | Success states, informational chips, badges |
| **Background** | `#F8F9FA` (Clean Off-White) | `#121619` (Deep Charcoal) | Main scaffold and canvas background |
| **Surface** | `#FFFFFF` (Pure White) | `#1A2128` (Elevated Card Dark) | Cards, dialogs, bottom sheets, navigation bars |
| **Error** | `#BA1A1A` (Coral Red) | `#FFB4AB` (Light Coral) | Form validation errors, destructive actions |

### Typography Scale (Material 3 Type Tokens)
* **Display Large / Medium / Small:** Custom font family implementation (`Inter` / `Roboto`) with proportional line heights.
* **Body Large (`16sp`):** Main descriptive content and paragraphs.
* **Body Medium (`14sp`):** Secondary captions, secondary list tile descriptions.
* **Label Large (`14sp` medium weight):** Button labels, interactive triggers, input labels.

---

## Core Widgets & Architecture

The application is structured around a modular widget tree, leveraging stateless and stateful separation alongside modern reactive controllers.

### 1. Custom & Reusable Widgets (`lib/widgets/`)
* **`AppCard`**: A custom container with elevation shadow, rounded corners (`BorderRadius.circular(16)`), and custom padding supporting dynamic light/dark surface colors.
* **`PrimaryButton`**: Material 3 elevated/filled button wrapper with built-in loading indicator, ripple splash customizer, and semantic accessibility labels.
* **`StatusBadge`**: Inline chip widget with customizable background opacity, text color, and icon prefix for displaying transaction or workflow states.
* **`EmptyStateView`**: Reusable placeholder widget displaying an SVG/Icon, header message, description, and action button when lists are empty.

### 2. Scaffold & Navigation Structure (`lib/screens/`)
* **`HomeScreen`**: Dashboard view featuring a staggered grid layout (`GridView.builder`), custom app bar with dynamic greeting, and quick action tiles.
* **`WidgetShowcaseScreen`**: Interactive playground exhibiting all atomic UI components, form inputs, toggles, sliders, and bottom sheets.
* **`SettingsScreen`**: Preference management screen utilizing grouped list tiles for theme switching (`Light`/`Dark`/`System`), notification toggles, and account settings.

---

## Networking with Dio (`lib/data/network/`)

```dart
// lib/data/network/dio_client.dart
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '[https://api.example.com/v1](https://api.example.com/v1)',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.addAll([
        AuthInterceptor(),
        LoggingInterceptor(),
      ]);
  }

  Dio get instance => _dio;
}
```

---

## Project Structure

```text
lib/
│
├── core/
│   ├── constants/       # App-wide constants, string literals, dimensions
│   ├── theme/           # AppTheme, ColorSchemes (Light & Dark), Typography
│   └── utils/           # Extension methods, formatters, screen utils
│
├── data/
│   ├── models/          # Dart serializable data models (JSON serialization)
│   └── repositories/    # API clients, local storage, mock data sources
│
├── logic/
│   └── bloc/ or providers/ # State management controllers (Riverpod / BLoC / Provider)
│
├── presentation/
│   ├── screens/         # Feature-level screens (Home, Detail, Settings)
│   └── widgets/         # Reusable atomic UI components (Buttons, Cards, Badges)
│
└── main.dart            # Application entry point & theme initialization
```