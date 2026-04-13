# Flutter MVVM Architecture Guide

This project follows the **MVVM (Model-View-ViewModel)** architecture using the `provider` package. This structure is designed to be scalable, testable, and beginner-friendly.

## 📂 Project Structure

```text
lib/
├── core/                  # Core configuration and shared resources
│   └── theme.dart         # App theme definitions (colors, fonts)
├── viewmodels/            # Business logic and state management
│   └── home_viewmodel.dart # Logic for the Home screen
├── views/                 # UI Screens (Widgets)
│   └── home_screen.dart   # The visual Home screen
├── widgets/               # Reusable small UI components
│   └── glass_card.dart    # A custom styled container
└── main.dart              # Entry point (sets up Providers)
```

## 🧩 The 3 Layers

### 1. Model (Data)
*Currently implicit in this simple app.*
Data classes (like `User`, `Product`) go here. They are simple Dart classes that hold data.

### 2. View (UI)
**Location:** `lib/views/`
*   Contains the Widgets visible to the user.
*   **Role:** display data and capture user touches.
*   **Rule:** NO business logic (e.g., no calculating prices, no API calls).
*   **Example:** `HomeScreen` listens to `HomeViewModel` to know what text to display.

### 3. ViewModel (Logic)
**Location:** `lib/viewmodels/`
*   Contains the "Brain" of the screen.
*   **Role:** Holds state (variables) and functions to change that state.
*   **Rule:** Extends `ChangeNotifier`. Call `notifyListeners()` whenever data changes so the View updates.
*   **Example:** `HomeViewModel` holds the `_greeting` text and `isExpanded` boolean.

## 🧰 How to Add a New Feature

1.  **Create the ViewModel**: Determine what data/logic you need (e.g., `CounterViewModel`).
    ```dart
    class CounterViewModel extends ChangeNotifier {
      int c = 0;
      void increment() { c++; notifyListeners(); }
    }
    ```
2.  **Create the View**: Create a widget that consumes the ViewModel.
    ```dart
    Consumer<CounterViewModel>(
      builder: (context, vm, child) => Text('${vm.c}'),
    )
    ```
3.  **Register Provider**: content Add it to `main.dart` in the `MultiProvider` list.
    ```dart
    ChangeNotifierProvider(create: (_) => CounterViewModel()),
    ```

## 💡 Why this fits you?
*   **Decoupling**: You can change the Design (View) without breaking the Logic (ViewModel).
*   **Scalability**: As your app grows, you just add more folders, not longer files.
*   **Simplicity**: `Provider` is the standard, easiest way to manage state in Flutter.
