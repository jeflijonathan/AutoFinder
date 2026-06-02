import 'package:autofinder/models/service_callback.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/services/workshop/workshop_service.dart';
import 'package:autofinder/utils/snackbar.dart';
import 'package:autofinder/views/my_post/provider/my_post_provider.dart';

class MyPostController {
  WorkshopService service = WorkshopService();

  Future<void> fetchMyPosts(MyPostProvider provider, String userId) async {
    provider.updateState(isLoading: true);

    service.getWorkshopsByUserId(
      userId,
      ServiceCallback(
        onSuccessData: (data) {
          provider.updateState(data: data, isLoading: false);
        },
        onErrorData: (error) {
          provider.updateState(isLoading: false, errorMessage: error);
          SnackbarHelper.showError('Failed Fetch Data: $error');
        },
        onFullFailed: () {
          provider.updateState(isLoading: false);
        },
      ),
    );
  }

  // =========================================================================
  // FETCH WORKSHOP BY ID
  // =========================================================================
  Future<void> fetchByIdPost(String workshopId, MyPostProvider provider) async {
    provider.updateState(isLoading: true);

    await service.getWorkshopById(
      workshopId,
      ServiceCallback(
        onSuccessData: (data) {
          // Menyimpan data workshop spesifik ke dataWorkshopById di dalam state
          provider.updateState(dataWorkshopById: data, isLoading: false);
        },
        onErrorData: (error) {
          provider.updateState(isLoading: false, errorMessage: error);
          SnackbarHelper.showError('Failed Fetch Detail: $error');
        },
        onFullFailed: () {
          provider.updateState(isLoading: false);
        },
      ),
    );
  }

  Future<void> updatePost({
    required String workshopId,
    required WorkshopModel updatedWorkshop,
    required MyPostProvider provider,
    required String userId,
  }) async {
    provider.updateState(isLoading: true);

    await service.updateWorkshop(
      workshopId,
      updatedWorkshop,
      ServiceCallback(
        onSuccessData: (message) {
          SnackbarHelper.showSuccess('Workshop updated successfully');
          fetchMyPosts(provider, userId); // Reload setelah update
        },
        onErrorData: (error) {
          provider.updateState(isLoading: false, errorMessage: error);
          SnackbarHelper.showError('Failed to update workshop: $error');
        },
        onFullFailed: () {
          provider.updateState(isLoading: false);
        },
      ),
    );
  }

  Future<void> deletePost(
    String workshopId,
    MyPostProvider provider,
    String userId,
  ) async {
    provider.updateState(isLoading: true);

    await service.deleteWorkshop(
      workshopId,
      ServiceCallback(
        onSuccessData: (message) {
          SnackbarHelper.showSuccess('Workshop deleted successfully');
          fetchMyPosts(provider, userId); // Reload setelah hapus
        },
        onErrorData: (error) {
          provider.updateState(isLoading: false, errorMessage: error);
          SnackbarHelper.showError('Failed to delete workshop: $error');
        },
        onFullFailed: () {
          provider.updateState(isLoading: false);
        },
      ),
    );
  }
}
