import 'package:flutter/material.dart';
import 'package:autofinder/views/home/provider/home_page_provider.dart';
import 'package:provider/provider.dart';

class HomeFilterController extends ChangeNotifier {
  void onSearchChanged(BuildContext context, String value) {
    final provider = context.read<HomePageProvider>();
    final currentParams = provider.state.params;
    provider.updateState(params: currentParams.copyWith(values: value));
  }
}
