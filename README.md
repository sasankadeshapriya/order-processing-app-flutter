# Mobile Application (Sales Representative App)

This app includes features for invoice generation, client management, and route tracking, designed for ease of use.

![order-processing](https://github.com/user-attachments/assets/d3ecb8dd-a97d-4954-b998-66176a1535d9)

## How to Setup on Local

### 1. Clone the Repository

```bash
git clone https://github.com/sasankadeshapriya/order-processing-app-flutter.git
cd order-processing-app-flutter
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Add API Keys and Other Configuration

#### 3.1 Google Maps API Key

To use Google Maps services, add your API key directly to the `AndroidManifest.xml` file.

1. Open the file `android/app/src/main/AndroidManifest.xml`.
2. Inside the `<application>` tag, add the following metadata:

   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

   Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key obtained from the Google Cloud Console.

#### 3.2 Environment Variables

If you have any other API keys or environment-specific configurations, you can manage them in the `.env` file.

1. **Create a `.env` file** in the root directory of the project (based on the `.env.example` provided).
2. **Example contents of the `.env` file:**

   ```env
   # .env file for Flutter project

   # Google Maps API Key
   GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY

   # Base URL for API calls
   BASE_URL=https://api.gsutil.xyz
   ```

3. **Important:** Do not commit the `.env` file to version control. Make sure to add it to `.gitignore`.

### 4. Run the Flutter App

```bash
flutter run
```

## Related Repositories

To fully set up the system, you may need to clone and set up the backend repositories:

```bash
git clone https://github.com/sasankadeshapriya/order-processing-backend-laravel.git
git clone https://github.com/sasankadeshapriya/order-processing-api-nodejs.git
```

Follow the instructions provided in these repositories to set up the backend services.

## Additional Notes

- **Security Considerations:** Ensure that sensitive information such as API keys and secrets are securely managed and not exposed publicly.
- **API Key Restrictions:** Use the Google Cloud Console to restrict the usage of your API keys to specific apps and URLs.

---