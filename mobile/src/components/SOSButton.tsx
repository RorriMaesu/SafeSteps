import React from 'react';
import { TouchableOpacity, Text, StyleSheet, GestureResponderEvent } from 'react-native';

type Props = { onPress: (e: GestureResponderEvent) => void };

export default function SOSButton({ onPress }: Props) {
  return (
    <TouchableOpacity style={styles.btn} onPress={onPress}>
      <Text style={styles.txt}>SOS</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  btn: { position: 'absolute', right: 20, bottom: 90, backgroundColor: '#E53935', paddingVertical: 14, paddingHorizontal: 22, borderRadius: 28, elevation: 4 },
  txt: { color: '#fff', fontWeight: '800', fontSize: 18 },
});
