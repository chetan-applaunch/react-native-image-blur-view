import * as React from 'react';

import { StyleSheet, View } from 'react-native';
import ImageBlurViewManager from 'react-native-image-blur-view';

export default function App() {
  return (
    <View style={styles.container}>
      <ImageBlurViewManager color="#32a852" style={styles.box} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 400,
    height: 400,
    marginVertical: 10,
  },
});
