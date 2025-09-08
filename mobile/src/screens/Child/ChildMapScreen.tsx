import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import MapView, { Marker, PROVIDER_GOOGLE } from 'react-native-maps';
import * as Location from 'expo-location';
import * as Speech from 'expo-speech';
import Constants from 'expo-constants';

export default function ChildMapScreen() {
  const [location, setLocation] = useState<{ latitude: number; longitude: number } | null>(null);
  const apiKey = (Constants?.expoConfig?.extra as any)?.googleMapsApiKey ?? (Constants as any)?.manifest?.extra?.googleMapsApiKey;

  useEffect(() => {
    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') return;
      const loc = await Location.getCurrentPositionAsync({});
      setLocation({ latitude: loc.coords.latitude, longitude: loc.coords.longitude });
      Speech.speak('This is a SafeSteps demo. Stay inside your safe area.', { rate: 1.0 });
    })();
  }, []);

  return (
    <View style={styles.container}>
      {Platform.OS === 'android' && !apiKey ? (
        <View style={styles.map}>
          <Text style={{ padding: 16 }}>Google Maps API key missing. Set GOOGLE_MAPS_API_KEY and rebuild.</Text>
        </View>
      ) : (
        <MapView style={styles.map}
          provider={PROVIDER_GOOGLE}
          initialRegion={{ latitude: location?.latitude ?? 37.7749, longitude: location?.longitude ?? -122.4194, latitudeDelta: 0.05, longitudeDelta: 0.05 }}>
          {location && <Marker coordinate={location} />}
        </MapView>
      )}
      <View style={styles.banner}>
        <Text style={styles.bannerText}>Status: SAFE</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  map: { flex: 1 },
  banner: { position: 'absolute', bottom: 20, left: 20, right: 20, backgroundColor: '#1E88E5', padding: 12, borderRadius: 8 },
  bannerText: { color: '#fff', fontWeight: '600', textAlign: 'center' },
});
