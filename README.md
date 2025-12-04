# Flutter Dynamic Form App

This Flutter app dynamically generates forms from JSON configuration and works in offline mode as well. This application has been coded by a human developer.

## Features

- ✅ Dynamic form generation from JSON
- ✅ Offline support (local storage)
- ✅ Mock API calls for dropdown data
- ✅ Form validation
- ✅ Child sections support (Education, Work Experience)
- ✅ Auto-save functionality
- ✅ Dependent dropdowns (Country → State → City)
- ✅ Secure data storage with encryption
- ✅ Form details drawer with search functionality
- ✅ Success animation on form submission
- ✅ Number keyboard for numeric fields
- ✅ 10-digit validation for contact numbers

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
│   ├── child_section_widget.dart # Child section widget
│   ├── form_details_drawer.dart  # Form details drawer
│   └── success_card.dart         # Success animation card
├── screens/
│   ├── profile_form_screen.dart  # Main form screen
│   └── form_details_screen.dart # Form details screen
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

1. **JSON Loading**: App loads form configuration from `assets/Assingment JSON.json` file
2. **Form Generation**: Form fields are dynamically generated according to JSON structure
3. **Offline Storage**: Form data is automatically saved in secure storage
4. **Mock API**: Mock API calls are used for dropdown data
5. **Dependent Dropdowns**: State and City dropdowns load data from `assets/country_state_city_data.json` based on parent selection

## Form Sections

- **BASIC DETAILS**: Job, First Name, Email, Contact Number, etc.
- **LOCATION**: Country, State, City, Pincode
- **REFERRED BY (OPTIONAL)**: Employee Name, Designation
- **EDUCATION DETAILS**: Multiple education entries (add/remove)
- **WORK EXPERIENCE**: Multiple work experience entries (add/remove)

## Dependencies

- `http: ^1.1.0` - For API calls (currently mocked)
- `shared_preferences: ^2.2.2` - For offline storage (backup/fallback)
- `flutter_secure_storage: ^9.0.0` - For encrypted secure storage (primary storage)
- `path_provider: ^2.1.1` - For file system access

## Notes

- Form data is automatically saved when user fills fields
- App works in offline mode
- Dropdown data comes from mock API (modify `api_service.dart` to integrate real API)
- Secure storage uses `flutter_secure_storage` package for encrypted data storage
- After form submission, data is saved to local storage and displayed in drawer/details screen
- State and City dropdowns load dynamically based on country/state selection
- Form fields are cleared after submission, but data remains in storage for viewing
- Number fields (experience, passing year, percentage, pincode, contact numbers) open with number keyboard
- Contact and alternate contact numbers have 10-digit validation

## Technical Implementation

- **Dynamic Form Generation**: Form structure is parsed from JSON file and widgets are generated dynamically
- **Dual Storage Strategy**: 
  - `Flutter Secure Storage` - Encrypted storage for sensitive data
  - `SharedPreferences` - Quick access and fallback storage
- **Dependent Dropdowns**: Country → State → City cascading dropdowns load data from JSON file
- **Form Validation**: Email, contact number (10 digits), and required fields validation
- **Offline Support**: All form data persists in local storage
- **Search Functionality**: Form details drawer and screen have search and highlighting features
- **Form Reset**: After submission, form fields are cleared but submitted data remains in storage
- **Success Animation**: Animated success card appears after form submission

## Storage Strategy

The app uses a dual-storage approach:

1. **Flutter Secure Storage** (Primary):
   - Encrypted storage for sensitive data
   - Android: Uses EncryptedSharedPreferences (AES encryption)
   - iOS: Uses Keychain (OS-level security)

2. **SharedPreferences** (Backup/Fallback):
   - Quick access for non-sensitive data
   - Fallback if secure storage fails
   - Backward compatibility

**Why Both?**
- **Security**: Sensitive form data is encrypted
- **Reliability**: If secure storage fails, SharedPreferences acts as backup
- **Data Persistence**: Reduces risk of data loss
- **Backward Compatibility**: Can access old data

## Author

**Developer**: Saurabh Vishwakarma
