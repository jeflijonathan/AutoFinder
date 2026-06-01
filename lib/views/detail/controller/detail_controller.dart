import 'package:autofinder/models/service_callback.dart';
import 'package:autofinder/services/workshop/commentar_model.dart';
import 'package:autofinder/services/workshop/workshop_service.dart';
import 'package:autofinder/utils/snackbar.dart';
import 'package:autofinder/views/detail/provider/detail_page_provider.dart';

class DetailController {
  final WorkshopService service = WorkshopService();

  Future<void> fetchComments(DetailPageProvider provider, String workshopId) async {
    provider.updateState(isLoading: true);

    service.getComments(
      workshopId,
      ServiceCallback(
        onSuccessData: (data) {
          provider.updateState(comments: data as List<CommentarModel>, isLoading: false);
        },
        onErrorData: (error) {
          provider.updateState(isLoading: false);
          SnackbarHelper.showError('Failed Fetch Comments: $error');
        },
        onFullFailed: () {
          provider.updateState(isLoading: false);
        },
      ),
    );
  }

  Future<void> fetchWorkshop(DetailPageProvider provider, String workshopId) async {
    final workshop = await service.getWorkshopById(workshopId);
    if (workshop != null) {
      provider.updateState(workshop: workshop);
    }
  }

  Future<bool> submitComment(
    DetailPageProvider provider,
    String workshopId,
    String userId,
    String userName,
    int rating,
    String description,
  ) async {
    try {
      // Cek apakah user sudah pernah review
      final hasReviewed = await service.checkUserHasReviewed(workshopId, userId);
      if (hasReviewed) {
        SnackbarHelper.showError('Anda sudah memberikan ulasan untuk bengkel ini.');
        return false;
      }

      final comment = CommentarModel(
        uid: null,
        userId: userId,
        userName: userName,
        rating: rating,
        description: description,
        workshopId: workshopId,
      );

      await service.addComment(comment);
      SnackbarHelper.showSuccess('Ulasan berhasil dikirim!');

      // Refresh comments and rating
      await fetchComments(provider, workshopId);
      await fetchWorkshop(provider, workshopId);
      return true;
    } catch (e) {
      SnackbarHelper.showError('Gagal mengirim ulasan: $e');
      return false;
    }
  }

  Future<bool> editComment(
    DetailPageProvider provider,
    String workshopId,
    String commentId,
    int rating,
    String description,
  ) async {
    try {
      await service.updateComment(commentId, rating, description);
      SnackbarHelper.showSuccess('Ulasan berhasil diperbarui!');
      await fetchComments(provider, workshopId);
      await fetchWorkshop(provider, workshopId);
      return true;
    } catch (e) {
      SnackbarHelper.showError('Gagal memperbarui ulasan: $e');
      return false;
    }
  }

  Future<bool> deleteComment(
    DetailPageProvider provider,
    String workshopId,
    String commentId,
  ) async {
    try {
      await service.deleteComment(commentId);
      SnackbarHelper.showSuccess('Ulasan berhasil dihapus!');
      await fetchComments(provider, workshopId);
      await fetchWorkshop(provider, workshopId);
      return true;
    } catch (e) {
      SnackbarHelper.showError('Gagal menghapus ulasan: $e');
      return false;
    }
  }

  Future<bool> replyToComment(
    DetailPageProvider provider,
    String workshopId,
    String commentId,
    String userId,
    String userName,
    String text,
  ) async {
    try {
      final reply = {
        'userId': userId,
        'userName': userName,
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await service.addReplyToComment(commentId, reply);
      SnackbarHelper.showSuccess('Balasan berhasil dikirim!');
      await fetchComments(provider, workshopId);
      return true;
    } catch (e) {
      SnackbarHelper.showError('Gagal membalas ulasan: $e');
      return false;
    }
  }
}
