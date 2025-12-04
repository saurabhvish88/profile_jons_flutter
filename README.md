# Flutter Dynamic Form App

यह Flutter app JSON configuration से dynamically form generate करता है और offline mode में भी काम करता है।

## Features

- ✅ JSON से dynamic form generation
- ✅ Offline support (local storage)
- ✅ Mock API calls for dropdown data
- ✅ Form validation
- ✅ Child sections support (Education, Work Experience)
- ✅ Auto-save functionality
- ✅ Dependent dropdowns (Country → State → City)

## Project Structure

```
lib/
├── models/
│   └── form_config.dart          # JSON data models
├── services/
│   ├── api_service.dart          # Mock API service
│   └── storage_service.dart      # Local storage service
├── widgets/
│   ├── dynamic_form_field.dart   # Dynamic form field widget
│   └── child_section_widget.dart # Child section widget
├── screens/
│   └── profile_form_screen.dart  # Main form screen
└── main.dart                     # App entry point
```

## Setup Instructions

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## How It Works

1. **JSON Loading**: App `assets/Assingment JSON.json` file से form configuration load करता है
2. **Form Generation**: JSON structure के अनुसार dynamically form fields generate होते हैं
3. **Offline Storage**: Form data automatically `SharedPreferences` में save होता है
4. **Mock API**: Dropdown data के लिए mock API calls use होती हैं

## Form Sections

- **BASIC DETAILS**: Job, First Name, Email, Contact Number, etc.
- **LOCATION**: Country, State, City, Pincode
- **REFERRED BY (OPTIONAL)**: Employee Name, Designation
- **EDUCATION DETAILS**: Multiple education entries (add/remove)
- **WORK EXPERIENCE**: Multiple work experience entries (add/remove)

## Dependencies

- `http: ^1.1.0` - For API calls (currently mocked)
- `shared_preferences: ^2.2.2` - For offline storage
- `path_provider: ^2.1.1` - For file system access

## Notes

- Form data automatically save होता है जब user field fill करता है
- App offline mode में भी काम करता है
- Dropdown data mock API से आता है (real API integrate करने के लिए `api_service.dart` में changes करें)

## Author

Saurabh Vishwakarma
