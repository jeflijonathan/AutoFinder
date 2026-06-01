import 'package:autofinder/models/service_callback.dart';
import 'package:autofinder/services/workshop/workshop_service.dart';
import 'package:autofinder/utils/snackbar.dart';
import 'package:autofinder/views/home/provider/home_page_provider.dart';

class HomeController {
  WorkshopService service = WorkshopService();

  Future<void> fetchDataRequest(HomePageProvider provider) async {
    provider.updateState(isLoading: true);

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
