import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/distributeur_controller.dart';

class DistributeurView extends GetView<DistributeurController> {
  const DistributeurView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DistributeurView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DistributeurView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
