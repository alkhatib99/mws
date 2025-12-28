# BAG MWS DApp Deployment Guide

This guide provides comprehensive instructions for deploying the BAG Multi Wallet Sender (MWS) DApp across different platforms and environments.

## 📋 Prerequisites

### Development Environment
- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 2.17.0 or higher
- **Git**: Latest version
- **Code Editor**: VS Code, Android Studio, or IntelliJ

### Platform-Specific Requirements

#### Web Deployment
- **Web Server**: Apache, Nginx, or static hosting
- **SSL Certificate**: Required for HTTPS
- **Domain**: Custom domain recommended

#### Mobile Deployment
- **Android**: Android Studio, Android SDK
- **iOS**: Xcode, iOS SDK, Apple Developer Account
- **Signing Certificates**: Platform-specific certificates

#### Desktop Deployment
- **Windows**: Visual Studio Build Tools
- **macOS**: Xcode Command Line Tools
- **Linux**: Build essentials, GTK development libraries

## 🌐 Web Deployment

### Build Process

1. **Prepare Environment**
   ```bash
   # Ensure Flutter web is enabled
   flutter config --enable-web
   
   # Clean previous builds
   flutter clean
   flutter pub get
   ```

2. **Build for Production**
   ```bash
   # Build optimized web version
   flutter build web --release --web-renderer html
   
   # Alternative: Canvas renderer for better performance
   flutter build web --release --web-renderer canvaskit
   ```

3. **Optimize Build**
   ```bash
   # Build with tree shaking and minification
   flutter build web --release --dart-define=flutter.web.use_skia=true
   ```

### Hosting Options

#### Option 1: Static Hosting (Recommended)

**Netlify Deployment**
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy to Netlify
cd build/web
netlify deploy --prod --dir .
```

**Vercel Deployment**
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy to Vercel
cd build/web
vercel --prod
```

**GitHub Pages**
```bash
# Add to repository
git add build/web/*
git commit -m "Deploy web build"
git subtree push --prefix build/web origin gh-pages
```

#### Option 2: Traditional Web Server

**Nginx Configuration**
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    # SSL Configuration
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    
    # Root directory
    root /var/www/mws/build/web;
    index index.html;
    
    # Handle Flutter routing
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security for sensitive files
    location ~ /\. {
        deny all;
    }
}
```

**Apache Configuration**
```apache
<VirtualHost *:80>
    ServerName yourdomain.com
    DocumentRoot /var/www/mws/build/web
    
    # Redirect to HTTPS
    Redirect permanent / https://yourdomain.com/
</VirtualHost>

<VirtualHost *:443>
    ServerName yourdomain.com
    DocumentRoot /var/www/mws/build/web
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /path/to/certificate.crt
    SSLCertificateKeyFile /path/to/private.key
    
    # Security headers
    Header always set X-Frame-Options DENY
    Header always set X-Content-Type-Options nosniff
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    
    # Handle Flutter routing
    <Directory "/var/www/mws/build/web">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Fallback to index.html for SPA routing
        FallbackResource /index.html
    </Directory>
    
    # Cache static assets
    <LocationMatch "\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
        ExpiresActive On
        ExpiresDefault "access plus 1 year"
        Header set Cache-Control "public, immutable"
    </LocationMatch>
</VirtualHost>
```

### Environment Configuration

**Production Environment Variables**
```bash
# Create .env.production
FLUTTER_WEB_USE_SKIA=true
FLUTTER_WEB_AUTO_DETECT=true

# RPC Endpoints (use your own keys)
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_INFURA_KEY
BSC_RPC_URL=https://bsc-dataseed.binance.org/
POLYGON_RPC_URL=https://polygon-rpc.com/

# WalletConnect Configuration
WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
```

## 📱 Mobile Deployment

### Android Deployment

1. **Prepare Android Build**
   ```bash
   # Generate signing key
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   
   # Configure key.properties
   echo "storePassword=your_store_password" > android/key.properties
   echo "keyPassword=your_key_password" >> android/key.properties
   echo "keyAlias=upload" >> android/key.properties
   echo "storeFile=../upload-keystore.jks" >> android/key.properties
   ```

2. **Update build.gradle**
   ```gradle
   // android/app/build.gradle
   android {
       compileSdkVersion 33
       
       defaultConfig {
           applicationId "com.bagguild.mws"
           minSdkVersion 21
           targetSdkVersion 33
           versionCode 1
           versionName "1.0.0"
       }
       
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       
       buildTypes {
           release {
               signingConfig signingConfigs.release
               minifyEnabled true
               shrinkResources true
           }
       }
   }
   ```

3. **Build APK/AAB**
   ```bash
   # Build APK
   flutter build apk --release
   
   # Build App Bundle (recommended for Play Store)
   flutter build appbundle --release
   ```

4. **Deploy to Play Store**
   - Upload AAB to Google Play Console
   - Configure store listing
   - Set up release management
   - Submit for review

### iOS Deployment

1. **Prepare iOS Build**
   ```bash
   # Open iOS project in Xcode
   open ios/Runner.xcworkspace
   ```

2. **Configure Xcode Project**
   - Set Bundle Identifier
   - Configure signing certificates
   - Set deployment target (iOS 11.0+)
   - Configure app icons and launch screens

3. **Build for iOS**
   ```bash
   # Build iOS app
   flutter build ios --release
   
   # Archive in Xcode
   # Product > Archive
   ```

4. **Deploy to App Store**
   - Upload to App Store Connect
   - Configure app metadata
   - Submit for review
   - Manage releases

## 🖥️ Desktop Deployment

### Windows Deployment

1. **Build Windows App**
   ```bash
   # Enable Windows desktop
   flutter config --enable-windows-desktop
   
   # Build Windows executable
   flutter build windows --release
   ```

2. **Create Installer**
   ```bash
   # Using Inno Setup
   # Create installer script (mws_installer.iss)
   
   # Using NSIS
   # Create NSIS script for installer
   ```

3. **Distribution Options**
   - Microsoft Store
   - Direct download from website
   - Third-party distribution platforms

### macOS Deployment

1. **Build macOS App**
   ```bash
   # Enable macOS desktop
   flutter config --enable-macos-desktop
   
   # Build macOS app
   flutter build macos --release
   ```

2. **Code Signing**
   ```bash
   # Sign the app
   codesign --force --verify --verbose --sign "Developer ID Application: Your Name" build/macos/Build/Products/Release/mws.app
   
   # Create DMG
   hdiutil create -volname "BAG MWS" -srcfolder build/macos/Build/Products/Release/mws.app -ov -format UDZO mws.dmg
   ```

3. **Distribution**
   - Mac App Store
   - Direct download
   - Homebrew cask

### Linux Deployment

1. **Build Linux App**
   ```bash
   # Enable Linux desktop
   flutter config --enable-linux-desktop
   
   # Install dependencies
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   
   # Build Linux app
   flutter build linux --release
   ```

2. **Package Formats**
   ```bash
   # Create AppImage
   # Using appimagetool
   
   # Create Snap package
   snapcraft
   
   # Create Flatpak
   flatpak-builder build-dir com.bagguild.mws.yml
   ```

## 🔧 CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy BAG MWS

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    - run: flutter pub get
    - run: flutter test
    - run: flutter analyze

  build-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    - run: flutter config --enable-web
    - run: flutter pub get
    - run: flutter build web --release
    - name: Deploy to Netlify
      uses: nwtgck/actions-netlify@v1.2
      with:
        publish-dir: './build/web'
        production-branch: main
      env:
        NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
        NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-java@v2
      with:
        distribution: 'zulu'
        java-version: '11'
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    - run: flutter pub get
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: android-apk
        path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    - run: flutter pub get
    - run: flutter build ios --release --no-codesign
    - uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app
```

## 🔒 Security Configuration

### SSL/TLS Setup

**Let's Encrypt (Free SSL)**
```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Security Headers

**Content Security Policy**
```html
<meta http-equiv="Content-Security-Policy" content="
    default-src 'self';
    script-src 'self' 'unsafe-inline' 'unsafe-eval';
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: https:;
    connect-src 'self' https: wss:;
    font-src 'self' data:;
    object-src 'none';
    media-src 'self';
    frame-src 'none';
">
```

### Environment Security

**Production Checklist**
- [ ] HTTPS enabled
- [ ] Security headers configured
- [ ] Environment variables secured
- [ ] API keys rotated
- [ ] Access logs enabled
- [ ] Error reporting configured
- [ ] Backup strategy implemented

## 📊 Monitoring & Analytics

### Performance Monitoring

**Web Vitals Tracking**
```javascript
// Add to index.html
import {getCLS, getFID, getFCP, getLCP, getTTFB} from 'web-vitals';

getCLS(console.log);
getFID(console.log);
getFCP(console.log);
getLCP(console.log);
getTTFB(console.log);
```

### Error Tracking

**Sentry Integration**
```dart
// Add to main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

## 🚀 Deployment Checklist

### Pre-Deployment
- [ ] Code review completed
- [ ] Tests passing
- [ ] Security audit completed
- [ ] Performance testing done
- [ ] Documentation updated
- [ ] Environment variables configured

### Deployment
- [ ] Build artifacts generated
- [ ] SSL certificates configured
- [ ] DNS records updated
- [ ] CDN configured (if applicable)
- [ ] Monitoring enabled
- [ ] Backup strategy verified

### Post-Deployment
- [ ] Functionality testing
- [ ] Performance monitoring
- [ ] Error tracking active
- [ ] User feedback collection
- [ ] Analytics configured
- [ ] Support documentation updated

## 🆘 Troubleshooting

### Common Issues

**Build Failures**
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Update Flutter
flutter upgrade

# Check for platform-specific issues
flutter doctor
```

**Web Deployment Issues**
- Check MIME types configuration
- Verify HTTPS setup
- Test routing configuration
- Check browser compatibility

**Mobile Deployment Issues**
- Verify signing certificates
- Check platform versions
- Test on physical devices
- Review store guidelines

### Support Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **GitHub Issues**: Repository issue tracker
- **Community Discord**: Real-time support
- **Stack Overflow**: Technical questions

---

This deployment guide ensures successful deployment across all platforms while maintaining security and performance standards. Regular updates and monitoring are essential for maintaining a production-ready application.

