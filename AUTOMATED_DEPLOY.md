# A6 - Automated TestFlight Deployment

## Option 1: Codemagic (Easiest - Recommended)

Codemagic handles all the certificate/signing complexity automatically.

### Setup (One-time, ~5 minutes):

1. **Go to [codemagic.io](https://codemagic.io)** and sign up
2. **Connect your Apple Developer account:**
   - Settings → Integrations → App Store Connect
   - Add your API key (create at developer.apple.com → Users → Keys)
3. **Add this repository**
4. **Click "Start Build"**

That's it! Codemagic will:
- Automatically create certificates and provisioning profiles
- Build your app on a Mac in the cloud
- Upload directly to TestFlight
- Notify you when complete

---

## Option 2: GitHub Actions

Requires more setup but runs in GitHub's cloud.

### Required GitHub Secrets:

1. `APPLE_ID` - Your Apple Developer email
2. `APPLE_APP_SPECIFIC_PASSWORD` - From appleid.apple.com
3. `APPLE_TEAM_ID` - From developer.apple.com → Membership
4. `BUILD_CERTIFICATE_BASE64` - Your .p12 certificate encoded
5. `P12_PASSWORD` - Password for the certificate
6. `KEYCHAIN_PASSWORD` - Any secure password
7. `PROVISIONING_PROFILE_BASE64` - Your provisioning profile encoded

### To encode certificates:
```bash
base64 -i certificate.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
```

### Trigger:
Push to `main` branch or manually trigger in GitHub Actions tab.

---

## Option 3: Local Mac Script

If you have a Mac with Xcode:

```bash
cd ios
./deploy-testflight.sh
```

---

## App Details

- **Bundle ID:** com.sovereign.a6
- **App Name:** A6 - Sovereign Singularity
- **Author:** Jonathan Sherman (steganographically embedded)
