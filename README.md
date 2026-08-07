# Savaio - Personal Finance Tracker 💰

Savaio is a modern, feature-rich personal finance tracking mobile application built with Flutter. It helps users manage their budgets, track expenses, visualize their financial habits, and achieve their financial goals with an intuitive user interface.

## ✨ Features

- **Expense & Income Tracking**: Easily log your daily transactions with categories and tags.
- **Budget Management**: Set monthly budgets and monitor your spending limits.
- **Interactive Dashboards**: Beautiful charts and graphs powered by `fl_chart` to visualize your financial flow.
- **Secure Authentication**: Seamless login via Supabase Auth and Google Sign-In.
- **Offline Support**: Robust local caching utilizing `hive` for offline access.
- **Push Notifications**: Stay updated with Firebase Cloud Messaging integration.
- **Modern UI/UX**: Designed with a sleek aesthetic and smooth animations.

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Backend as a Service:** [Supabase](https://supabase.com/)
- **Local Storage:** [Hive](https://pub.dev/packages/hive)
- **Data Visualization:** [FL Chart](https://pub.dev/packages/fl_chart)
- **Authentication:** Supabase Auth & Google Sign-In

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.11.4 or higher)
- Dart SDK
- Android Studio / Xcode for emulators
- A Supabase Project (for backend configuration)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/savaio-mobile.git
   cd savaio-mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up Environment Variables:**
   Create a `.env` file in the root directory (or inside `assets/.env` as configured) and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

## 📂 Project Structure

- `lib/` - Main source code (Views, Controllers, Models, Services)
- `assets/` - Static files like images, fonts, and `.env` config
- `zzdump/` - Contains documentation, reference specifications (API contracts, ERD, UML), and utility scripts.

## 🤝 Contributing

Contributions are welcome! If you'd like to improve the app, feel free to open a pull request or submit an issue.
