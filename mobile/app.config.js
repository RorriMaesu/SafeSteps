// Loads environment variables from repo root .env and exposes them to Expo config
// This ensures android manifest placeholders and JS can access GOOGLE_MAPS_API_KEY
const path = require('path');
const fs = require('fs');

function loadDotenvFromRepoRoot() {
  const repoRoot = path.resolve(__dirname, '..');
  const envPath = path.join(repoRoot, '.env');
  if (fs.existsSync(envPath)) {
    const content = fs.readFileSync(envPath, 'utf8');
    for (const line of content.split(/\r?\n/)) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#') || !trimmed.includes('=')) continue;
      const idx = trimmed.indexOf('=');
      const key = trimmed.slice(0, idx).trim();
      let value = trimmed.slice(idx + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
        value = value.slice(1, -1);
      }
      process.env[key] ||= value;
    }
  }
}

loadDotenvFromRepoRoot();

module.exports = ({ config }) => ({
  ...config,
  expo: {
    ...(config?.expo || {}),
    extra: {
      ...(config?.expo?.extra || {}),
      googleMapsApiKey: process.env.GOOGLE_MAPS_API_KEY || '',
  googleWebClientId: process.env.GOOGLE_WEB_CLIENT_ID || '',
    },
  },
});
