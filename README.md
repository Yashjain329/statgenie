# StatGenie Flutter App

StatGenie is a Flutter mobile application designed for field surveyors to upload, process, and analyze statistical data with offline-first capabilities and cloud synchronization.

## Features

- 🔐 **Authentication**: Supabase-powered authentication with email/password and social login
- 📊 **Data Analysis**: Upload CSV/Excel files and get comprehensive statistical analysis
- 📱 **Three Dashboards**: Home, Upload/Output, and Profile screens
- 🔄 **Offline-First**: Works offline with automatic sync when online
- 📈 **Dynamic Charts**: Interactive charts that sync with data filters
- 🎛️ **Data Slicers**: Filter and slice data with categorical, numeric, and date filters
- 🎨 **Cyan Theme**: Beautiful cyan-colored UI matching the design requirements

## Screenshots

[Add screenshots here]

## Setup Instructions

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Supabase account
- StatGenie API access

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/statgenie-flutter.git
   cd statgenie-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Configuration**

   Create a `.env` file in the root directory:
   ```env
   # Supabase Configuration
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here

   # API Configuration
   STATGENIE_API_URL=https://statgenie-163827097277.asia-south1.run.app

   # App Configuration
   APP_NAME=StatGenie
   APP_VERSION=1.0.0
   ```

4. **Supabase Setup**

   Create the following tables in your Supabase database:
   ```sql
   -- Users table
   CREATE TABLE users (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     email TEXT UNIQUE NOT NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Datasets table for file collection
   CREATE TABLE datasets (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     user_id UUID REFERENCES users(id),
     name TEXT NOT NULL,
     file_url TEXT,
     file_size BIGINT,
     row_count INTEGER,
     column_count INTEGER,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     pending_sync BOOLEAN DEFAULT true
   );

   -- Enable Row Level Security
   ALTER TABLE users ENABLE ROW LEVEL SECURITY;
   ALTER TABLE datasets ENABLE ROW LEVEL SECURITY;

   -- Policies
   CREATE POLICY "Users can view their own data" ON users
     FOR ALL TO authenticated
     USING (auth.uid() = id);

   CREATE POLICY "Users can insert their own datasets" ON datasets
     FOR INSERT TO authenticated
     WITH CHECK (user_id = auth.uid());

   CREATE POLICY "Users can view their own datasets" ON datasets
     FOR SELECT TO authenticated
     USING (user_id = auth.uid());
   ```

5. **Configure Authentication Redirect URIs**

   In your Supabase project settings, add these redirect URIs:
    - `com.example.statgenie://statgenie/login-callback`
    - `com.example.statgenie://statgenie/reset-password`

6. **Add Assets**

   Place your app logo and splash screen video in:
    - `assets/images/logo.png`
    - `assets/videos/splash.mp4`

### Running the App

1. **Development Mode**
   ```bash
   flutter run
   ```

2. **Release Build**
   ```bash
   flutter build apk --release
   ```

## Project Structure

```
lib/
├── src/
│   ├── app.dart                 # Main app configuration
│   ├── models/                  # Data models
│   │   ├── analysis_result.dart
│   │   └── dataset.dart
│   ├── providers/               # State management
│   │   ├── auth_provider.dart
│   │   ├── chart_provider.dart
│   │   ├── data_provider.dart
│   │   └── sync_provider.dart
│   ├── screens/                 # UI screens
│   │   ├── auth/
│   │   ├── main/
│   │   └── splash/
│   ├── services/                # API and database services
│   │   ├── api_service.dart
│   │   └── database_service.dart
│   ├── utils/                   # Utilities and themes
│   │   └── app_theme.dart
│   └── widgets/                 # Reusable widgets
│       ├── analysis_results.dart
│       ├── data_slicers.dart
│       ├── dynamic_charts.dart
│       └── ...
└── main.dart                    # App entry point
```

## API Integration

The app integrates with the StatGenie API:

- **Base URL**: `https://statgenie-163827097277.asia-south1.run.app`
- **Upload Endpoint**: `POST /clean_and_analyze`
- **Download Endpoint**: `GET /download_report`
- **Health Check**: `GET /health`

## Key Features

### Dynamic Charts
- **Pie Charts**: Category distribution
- **Bar Charts**: Comparative analysis
- **Line Charts**: Trend analysis
- **Histograms**: Distribution analysis

### Data Slicers
- **Categorical Filters**: Multi-select category filters
- **Numeric Filters**: Range sliders for numeric data
- **Date Filters**: Date picker for time-based filtering

### Offline Capabilities
- Local SQLite database for offline storage
- Automatic sync when connectivity is restored
- Queue system for pending uploads

## Dependencies

### Main Dependencies
- `flutter_dotenv`: Environment variable management
- `supabase_flutter`: Authentication and backend
- `provider`: State management
- `fl_chart`: Chart visualization
- `sqflite`: Local database
- `file_picker`: File selection
- `connectivity_plus`: Network monitoring

### Development Dependencies
- `flutter_lints`: Code analysis
- `build_runner`: Code generation

## Building for Production

1. **Update app version** in `pubspec.yaml`
2. **Update environment variables** for production
3. **Build release APK**:
   ```bash
   flutter build apk --release --split-per-abi
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Email: support@statgenie.com
- Documentation: [Link to docs]
- Issues: [GitHub Issues]
```