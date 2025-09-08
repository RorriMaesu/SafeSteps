import React from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../App';

export type LoginProps = NativeStackScreenProps<RootStackParamList, 'Login'>;

export default function LoginScreen({ navigation }: LoginProps) {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>SafeSteps</Text>
      <Text>Login placeholder</Text>
      <Button title="Continue" onPress={() => navigation.replace('ParentDashboard')} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 12 },
});
