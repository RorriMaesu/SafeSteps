import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import MapView, { Marker, Polygon, MapPressEvent, PROVIDER_GOOGLE } from 'react-native-maps';
import { Platform } from 'react-native';
import Constants from 'expo-constants';

export default function FenceEditorScreen() {
  const [coords, setCoords] = useState<{ latitude: number; longitude: number }[]>([]);
  const apiKey = (Constants?.expoConfig?.extra as any)?.googleMapsApiKey ?? (Constants as any)?.manifest?.extra?.googleMapsApiKey;

  return (
    <View style={styles.container}>
      {Platform.OS === 'android' && !apiKey ? (
        <View style={styles.map}>
          <Text style={{ padding: 16 }}>Google Maps API key missing. Set GOOGLE_MAPS_API_KEY and rebuild.</Text>
        </View>
      ) : (
      <MapView style={styles.map}
        provider={PROVIDER_GOOGLE}
        initialRegion={{ latitude: 37.7749, longitude: -122.4194, latitudeDelta: 0.05, longitudeDelta: 0.05 }}
  onPress={(e: MapPressEvent) => setCoords((prev: { latitude: number; longitude: number }[]) => [...prev, e.nativeEvent.coordinate])}
      >
  {coords.map((c: { latitude: number; longitude: number }, i: number) => (
          <Marker key={i} coordinate={c} />
        ))}
        {coords.length >= 3 && (
          <Polygon coordinates={coords} strokeColor="#1E88E5" fillColor="rgba(30,136,229,0.2)" />
        )}
      </MapView>
  )}
      <View style={styles.footer}>
        <Button title="Clear" onPress={() => setCoords([])} />
        <Button title="Save" onPress={() => console.log('save polygon', coords)} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  map: { flex: 1 },
  footer: { flexDirection: 'row', justifyContent: 'space-around', padding: 12, backgroundColor: '#fff' },
});
