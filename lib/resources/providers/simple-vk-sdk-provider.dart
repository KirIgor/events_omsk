import 'package:flutter_vk_sdk/flutter_vk_sdk.dart';

import 'vk-sdk-provider.dart';

class SimpleVkSdkProvider extends VkSdkProvider {
  VKSdk _instance;

  @override
  VKSdk getInstance() => _instance;

  @override
  void setInstance(VKSdk instance) => _instance = instance;
}
