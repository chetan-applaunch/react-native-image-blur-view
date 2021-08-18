import { requireNativeComponent, ViewStyle } from 'react-native';

type ImageBlurViewProps = {
  color: string;
  style: ViewStyle;
};

export const ImageBlurViewManager = requireNativeComponent<ImageBlurViewProps>(
'ImageBlurView'
);

export default ImageBlurViewManager;
