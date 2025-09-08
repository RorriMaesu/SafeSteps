import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import LoginScreen from './screens/Auth/LoginScreen';
import ParentDashboardScreen from './screens/Parent/ParentDashboardScreen';
import FenceEditorScreen from './screens/Parent/FenceEditorScreen';
import ChildMapScreen from './screens/Child/ChildMapScreen';

export type RootStackParamList = {
  Login: undefined;
  ParentDashboard: undefined;
  FenceEditor: undefined;
  ChildMap: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  const isAuthed = true; // TODO: wire to auth state

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {!isAuthed ? (
          <Stack.Screen name="Login" component={LoginScreen} />
        ) : (
          <>
            <Stack.Screen name="ParentDashboard" component={ParentDashboardScreen} />
            <Stack.Screen name="FenceEditor" component={FenceEditorScreen} />
            <Stack.Screen name="ChildMap" component={ChildMapScreen} />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}
