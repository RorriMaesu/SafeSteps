import React, { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import LoginScreen from './screens/Auth/LoginScreen';
import ParentDashboardScreen from './screens/Parent/ParentDashboardScreen';
import FenceEditorScreen from './screens/Parent/FenceEditorScreen';
import ChildMapScreen from './screens/Child/ChildMapScreen';
import { onAuthStateChanged } from './services/auth';

export type RootStackParamList = {
  Login: undefined;
  ParentDashboard: undefined;
  FenceEditor: undefined;
  ChildMap: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  const [isAuthed, setIsAuthed] = useState<boolean | null>(null);

  useEffect(() => {
    const unsub = onAuthStateChanged((user) => setIsAuthed(!!user));
    return unsub;
  }, []);

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {isAuthed === false ? (
          <Stack.Screen name="Login" component={LoginScreen} />
        ) : isAuthed === true ? (
          <>
            <Stack.Screen name="ParentDashboard" component={ParentDashboardScreen} />
            <Stack.Screen name="FenceEditor" component={FenceEditorScreen} />
            <Stack.Screen name="ChildMap" component={ChildMapScreen} />
          </>
        ) : (
          // Splash/loading fallthrough
          <Stack.Screen name="Login" component={LoginScreen} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}
