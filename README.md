# FlexDocs - Deployable Claude Context Manager

A complete solution for syncing Claude Code context files between FlutterFlow sessions.

## 🚀 Quick Deploy to Netlify

[![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy?repository=https://github.com/yourusername/flexdocs-deploy)

Or manually:

1. Fork/clone this repository
2. Connect to Netlify
3. Deploy! No build settings needed

## 📱 FlutterFlow Integration

### 1. Add Dependencies

In FlutterFlow, add these packages:
- `webview_flutter: ^4.4.0`
- `url_launcher: ^6.1.0`

### 2. Add Custom Code

Copy the entire contents of `flutter-integration/flexdocs_widget.dart` to your FlutterFlow custom code.

### 3. Create Custom Action

Create a new Custom Action in FlutterFlow:
- Name: `openFlexDocs`
- Code:
```dart
Future<void> openFlexDocs(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FlexDocsWidget(
        siteUrl: 'https://YOUR-SITE.netlify.app',
        apiKey: 'your-api-key',
      ),
    ),
  );
}
```

### 4. Add Trigger

Add a button or keyboard shortcut that calls the `openFlexDocs` action.

## 🔄 How It Works

### Morning Workflow
1. Download fresh FlutterFlow project
2. Open FlexDocs in your app (button/shortcut)
3. Download sync script from the web UI
4. Double-click script to pull all CLAUDE*.md files

### During Development
- Work with Claude Code
- Create/update CLAUDE.md files anywhere in project
- Files maintain their folder structure

### Evening Workflow
1. Run: `./sync-script.sh push`
2. All CLAUDE*.md files upload to cloud
3. Tomorrow they'll be waiting for you

## 🔧 Configuration

### API Keys

Edit `netlify/functions/api.js` to add your API keys:

```javascript
const API_KEYS = {
  'your-secure-key': 'your-project-id',
  // Add more as needed
};
```

### Custom Domain

After deploying to Netlify:
1. Update `siteUrl` in Flutter widget
2. Update `API_URL` in sync script

## 📁 What Gets Synced

The system automatically finds and syncs:
- `CLAUDE.md` (main context file)
- `CLAUDE-*.md` (additional context files)
- Any file matching `*CLAUDE*.md`

Files maintain their relative paths, so:
- `/src/CLAUDE.md` → stored as `src/CLAUDE.md`
- `/docs/CLAUDE-API.md` → stored as `docs/CLAUDE-API.md`

## 🛡️ Security

- API keys control access
- Each project is isolated
- No cross-project access
- HTTPS only in production

## 🎯 Features

- ✅ Zero configuration deployment
- ✅ Web UI for viewing files
- ✅ In-app FlutterFlow integration
- ✅ Double-click sync script
- ✅ Preserves folder structure
- ✅ Multiple CLAUDE files support
- ✅ Real-time sync status

## 🚨 Production Checklist

1. [ ] Generate secure API keys
2. [ ] Set up Netlify environment variables
3. [ ] Enable Netlify Identity (optional)
4. [ ] Configure custom domain
5. [ ] Update Flutter widget URLs
6. [ ] Test sync workflow end-to-end