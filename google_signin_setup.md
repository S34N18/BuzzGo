# Google Sign-In Setup Guide for BuzzGo

## ✅ **What's Already Done:**

1. **Dependencies**: Google Sign-In v6.3.0 added to pubspec.yaml
2. **Code Implementation**: Complete Google Sign-In implementation in AuthService
3. **UI Components**: Google Sign-In button added to login screen
4. **Android Config**: Google Services plugin configured in build.gradle.kts
5. **Firebase Config**: google-services.json file is present

## 🔧 **Firebase Console Configuration:**

### **1. Enable Google Sign-In in Firebase Console:**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your **kupatanakenya** project
3. Go to **Authentication** > **Sign-in method**
4. Click on **Google** provider
5. Toggle **Enable**
6. Set **Project support email** (your email)
7. Click **Save**

### **2. Get OAuth 2.0 Client IDs (Important for Android):**
1. In Firebase Console, go to **Project Settings** (gear icon)
2. Click on **General** tab
3. Scroll to **Your apps** section
4. Find your Android app and note the **SHA-1 certificate fingerprints**

### **3. Generate SHA-1 for Debug/Release:**

#### **Debug SHA-1 (for testing):**
```bash
# Generate debug SHA-1 (run this in your project directory)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### **Release SHA-1 (for production):**
```bash
# Generate release SHA-1 (when you have a release keystore)
keytool -list -v -keystore path/to/your/release-keystore.jks -alias your-key-alias
```

Add these SHA-1 fingerprints to your Firebase project:
1. Firebase Console > Project Settings > General
2. Your apps > Android app > Add SHA-1

## 📱 **Testing Google Sign-In:**

### **1. Test on Physical Device (Recommended):**
```bash
# Build and install on physical device
flutter run --release -d <device-id>
```

### **2. Test on Android Emulator:**
```bash
# Make sure your emulator has Google Play Services
# Use an emulator with Play Store support
flutter run -d emulator-5554
```

### **3. Debug Commands:**
```bash
# Check if Google Play Services are available
adb shell am start -a android.intent.action.VIEW -d "https://play.google.com/store/apps/details?id=com.google.android.gms"

# Check device logs for Google Sign-In
flutter logs

# Run with verbose logging
flutter run --verbose
```

## 🐛 **Common Issues & Solutions:**

### **Issue 1: "Google Sign-In is not available"**
**Solution:** 
- Test on physical device with Google Play Services
- Ensure SHA-1 is added to Firebase project
- Check internet connection

### **Issue 2: "SIGN_IN_FAILED"**
**Solution:**
- Verify Google provider is enabled in Firebase Console
- Check SHA-1 certificate fingerprints are correct
- Ensure google-services.json is up to date

### **Issue 3: "Network Error"**
**Solution:**
- Check device internet connection
- Verify Firebase project is active
- Test with different network

### **Issue 4: "Account picker doesn't appear"**
**Solution:**
- Clear Google Play Services data
- Sign out of existing Google accounts and try again
- Test on different device

## 🧪 **Test Script for Google Sign-In:**

Create this test to verify Google Sign-In works:

```dart
// In your test files or debug screen
Future<void> testGoogleSignIn() async {
  final authService = AuthService();
  
  try {
    print('🔍 Testing Google Sign-In...');
    
    final userCredential = await authService.signInWithGoogle();
    
    if (userCredential != null) {
      print('✅ Google Sign-In successful!');
      print('👤 User: ${userCredential.user?.email}');
      print('🆔 UID: ${userCredential.user?.uid}');
      print('📱 Display Name: ${userCredential.user?.displayName}');
      print('🖼️ Photo URL: ${userCredential.user?.photoURL}');
    } else {
      print('❌ Google Sign-In failed or cancelled');
    }
  } catch (e) {
    print('❌ Google Sign-In error: $e');
  }
}
```

## 📊 **Production Checklist:**

- [ ] Add production SHA-1 certificate to Firebase
- [ ] Test on multiple devices
- [ ] Verify user profiles are created in Firestore
- [ ] Test sign-out functionality
- [ ] Verify admin status works correctly for Google users
- [ ] Test error handling for network issues

## 🔐 **Security Notes:**

1. **New Google users are NOT admin by default** (as implemented)
2. **User profiles are automatically created in Firestore**
3. **Existing users can link Google accounts** (Firebase handles this)
4. **Sign-out properly clears both Firebase Auth and Google sessions**

## 🚀 **Next Steps:**

1. Run the app: `flutter run`
2. Test Google Sign-In on the login screen
3. Verify user profile creation in Firestore
4. Test admin promotion for Google users if needed
5. Deploy to production with production SHA-1 certificates
