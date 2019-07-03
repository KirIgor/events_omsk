import 'package:flutter_vk_sdk/flutter_vk_sdk.dart';

abstract class VkSdkProvider {
  void setInstance(VKSdk instance);
  VKSdk getInstance();
}