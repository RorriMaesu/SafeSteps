import React, { useEffect, useState } from 'react';
import { View, Text, Button, StyleSheet, ActivityIndicator, Alert } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../App';
import { configureGoogleSignIn, signInWithGoogle, onAuthStateChanged } from '../../services/auth';

export type LoginProps = NativeStackScreenProps<RootStackParamList, 'Login'>;

export default function LoginScreen({ navigation }: LoginProps) {
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    configureGoogleSignIn();
    const unsub = onAuthStateChanged((user) => {
      if (user) {
        navigation.replace('ParentDashboard');
      }
    });
    return unsub;
  }, [navigation]);

  const handleGoogle = async () => {
    try {
      setLoading(true);
      await signInWithGoogle();
      // onAuthStateChanged will navigate on success
    } catch (e: any) {
      console.warn('Google sign-in failed', e);
      Alert.alert('Sign-in failed', e?.message ?? 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>SafeSteps</Text>
      {loading ? (
        <ActivityIndicator />
      ) : (
        <>
          <Button title="Sign in with Google" onPress={handleGoogle} />
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 12 },
});
