import React, { Component } from 'react';
import { StyleSheet, View } from 'react-native';
import ImageBlurViewManager from 'react-native-image-blur-view';
import { NativeAppEventEmitter } from 'react-native';

export default class App extends Component {
  constructor(props) {
    super(props);
    this.state = {

    };
  }
  
  componentDidMount(){
    console.log('>>>>> componentDidMount called <<<<<<<<');
   
    var blurEventListener = NativeAppEventEmitter.addListener(
      'BlurImageEvent',
      (path) => console.log(path)
    );

  }

  render() {
  
    return (
       <View style={styles.container}>
      <ImageBlurViewManager imagePath="/private/var/mobile/Containers/Data/Application/C4486D89-689C-40B0-935A-BDCF78E6CA0F/tmp/react-native-image-blur-view/F1F72ECB-62DB-4843-A1BA-7B7EEB46D986.jpg" style={styles.box} />
    </View>
    );
  }
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 400,
    height: 800,
    marginVertical: 2,
  },
});