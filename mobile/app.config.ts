import type { ExpoConfig } from '@expo/config';

const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY || '';

export default ({ config }: { config: ExpoConfig }): ExpoConfig => ({
  name: 'SafeSteps',
  slug: 'safesteps',
  scheme: 'safesteps',
  version: '0.1.0',
  orientation: 'portrait',
  assetBundlePatterns: ['**/*'],
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'com.safesteps.app',
    infoPlist: {
      NSLocationWhenInUseUsageDescription:
        'SafeSteps uses your location to keep you within your safe walking zone.',
      NSLocationAlwaysAndWhenInUseUsageDescription:
        'SafeSteps needs background location for boundary alerts.',
      UIBackgroundModes: ['location', 'audio'],
    },
  },
  android: {
    package: 'com.safesteps.app',
    permissions: [
      'ACCESS_FINE_LOCATION',
      'ACCESS_COARSE_LOCATION',
      'ACCESS_BACKGROUND_LOCATION',
      'FOREGROUND_SERVICE',
    ],
  },
  extra: {
    googleMapsApiKey: GOOGLE_MAPS_API_KEY,
    eas: {
      projectId: (config as any)?.extra?.eas?.projectId,
    },
  },
});
