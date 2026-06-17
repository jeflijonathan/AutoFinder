import 'package:autofinder/models/service_callback.dart';
import 'package:autofinder/services/workshop/workshop_service.dart';
import 'package:autofinder/utils/snackbar.dart';
import 'package:autofinder/views/home/provider/home_page_provider.dart';

class HomeController {
  WorkshopService service = WorkshopService();

  Future<void> fetchDataRequest(HomePageProvider provider, {double? lat, double? lng, double radiusInKm = 50.0}) async {
    provider.updateState(isLoading: true);

    // Call migration to ensure all old workshops have the 'geo' field for Nearby filtering.
    // It only updates documents that are missing the field, so it is safe to call.
    await service.migrateWorkshopsToGeohash();

    if (lat != null && lng != null) {
      service.getNearbyWorkshops(
        lat,
        lng,
        radiusInKm,
        ServiceCallback(
          onSuccessData: (data) => {
            provider.updateState(data: data, isLoading: false),
          },
          onErrorData: (error) => {
            provider.updateState(isLoading: false),
            SnackbarHelper.showError('Failed Fetch Data: $error'),
          },
          onFullFailed: () {
            provider.updateState(isLoading: false);
          },
        ),
      );
    } else {
      service.getWorkshops(
        ServiceCallback(
          onSuccessData: (data) => {
            provider.updateState(data: data, isLoading: false),
          },
          onErrorData: (error) => {
            provider.updateState(isLoading: false),
            SnackbarHelper.showError('Failed Fetch Data: $error'),
          },
          onFullFailed: () {
            provider.updateState(isLoading: false);
          },
        ),
      );
    }
  }
}
