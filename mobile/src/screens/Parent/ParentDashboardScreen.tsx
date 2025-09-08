import React from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';

export default function ParentDashboardScreen() {
  const navigation = useNavigation();

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Parent Dashboard</Text>
      <View style={styles.row}>
        <Button title="Edit Fence" onPress={() => navigation.navigate('FenceEditor' as never)} />
      </View>
      <View style={styles.row}>
        <Button title="Child View" onPress={() => navigation.navigate('ChildMap' as never)} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 16 },
  title: { fontSize: 22, fontWeight: '600', marginBottom: 16 },
  row: { marginVertical: 8 },
});
