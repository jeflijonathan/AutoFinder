import 'package:autofinder/models/service_callback.dart';
import 'package:autofinder/services/workshop/workshop_service.dart';
import 'package:autofinder/utils/snackbar.dart';
import 'package:autofinder/views/search/provider/search_page_provider.dart';

class SearchController {
  final WorkshopService service = WorkshopService();

  Future<void> fetchDataRequest(SearchPageProvider provider, {bool silent = false}) async {
    if (!silent) provider.updateState(isLoading: true);

    service.getWorkshops(
      ServiceCallback(
        onSuccessData: (data) {
          provider.updateState(data: data, isLoading: false, searchLoading: false);
        },
        onErrorData: (error) {
          provider.updateState(isLoading: false, searchLoading: false);
          SnackbarHelper.showError('Failed Fetch Data: $error');
        },
        onFullFailed: () {
          provider.updateState(isLoading: false, searchLoading: false);
        },
      ),
    );
  }

  void onSearchChanged(SearchPageProvider provider, String value) {
    provider.updateState(searchQuery: value);
  }

  Future<void> onSearchDebounced(
    SearchPageProvider provider,
    String value,
  ) async {
    provider.updateState(searchLoading: true, searchQuery: value);
    await fetchDataRequest(provider, silent: true);
  }

  void toggleOpenNow(SearchPageProvider provider) {
    provider.updateState(openNow: !provider.state.openNow);
  }

  void toggleTopRated(SearchPageProvider provider) {
    provider.updateState(topRated: !provider.state.topRated);
  }

  void toggleSpecialization(SearchPageProvider provider, String spec) {
    final currentList = List<String>.from(provider.state.selectedSpecializations);
    if (currentList.contains(spec)) {
      currentList.remove(spec);
    } else {
      currentList.add(spec);
    }
    provider.updateState(selectedSpecializations: currentList);
  }
}
