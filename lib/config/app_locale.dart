import 'package:autofinder/config/localization/lang_en.dart';
import 'package:autofinder/config/localization/lang_id.dart';
import 'package:autofinder/config/localization/lang_ja.dart';
import 'package:autofinder/config/localization/lang_th.dart';
import 'package:autofinder/config/localization/lang_zh.dart';
import 'package:flutter/rendering.dart';
import 'package:translator/translator.dart';
import 'package:flutter_localization/flutter_localization.dart';

mixin AppLocale {
  static const String securityOfAccount = 'securityOfAccount';
  static const String securityDesc = 'securityDesc';
  static const String password = 'password';
  static const String currentPassword = 'currentPassword';
  static const String newPassword = 'newPassword';
  static const String confirmation = 'confirmation';
  static const String confirmPasswordHint = 'confirmPasswordHint';
  static const String updatePassword = 'updatePassword';
  static const String accountSecuritySettings = 'accountSecuritySettings';

  static const String personalInformation = 'personalInformation';
  static const String personalInfoDesc = 'personalInfoDesc';
  static const String fullName = 'fullName';
  static const String fullNameHint = 'fullNameHint';
  static const String email = 'email';
  static const String phoneNumber = 'phoneNumber';
  static const String saveChanges = 'saveChanges';
  static const String cancel = 'cancel';
  static const String profileSettings = 'profileSettings';

  static const String title = 'title';
  static const String theme = 'theme';
  static const String themeSubtitle = 'themeSubtitle';
  static const String language = 'language';
  static const String languageSubtitle = 'languageSubtitle';
  static const String profile = 'profile';
  static const String accountAndSecurity = 'accountAndSecurity';
  static const String accountSecurity = 'accountSecurity';
  static const String accountSecuritySubtitle = 'accountSecuritySubtitle';
  static const String editProfile = 'editProfile';
  static const String editProfileSubtitle = 'editProfileSubtitle';
  static const String preferences = 'preferences';
  static const String logout = 'logout';
  static const String logoutSubtitle = 'logoutSubtitle';
  static const String home = 'home';
  static const String search = 'search';
  static const String post = 'post';
  static const String favorite = 'favorite';

  static const String addWorkshopTitle = 'addWorkshopTitle';

  static const String identityTitle = 'identityTitle';
  static const String identitySubtitle = 'identitySubtitle';
  static const String phoneLabel = 'phoneLabel';
  static const String workshopNameLabel = 'workshopNameLabel';
  static const String workshopNameHint = 'workshopNameHint';
  static const String missionLabel = 'missionLabel';
  static const String missionHint = 'missionHint';
  static const String specializationLabel = 'specializationLabel';

  static const String locationTitle = 'locationTitle';
  static const String locationSubtitle = 'locationSubtitle';
  static const String locationChange = 'locationChange';
  static const String locationAddressHint = 'locationAddressHint';

  static const String servicesTitle = 'servicesTitle';
  static const String servicesSubtitle = 'servicesSubtitle';
  static const String addService = 'addService';

  static const String scheduleTitle = 'scheduleTitle';
  static const String scheduleOpen = 'scheduleOpen';
  static const String scheduleClosed = 'scheduleClosed';
  static const String openingTime = 'openingTime';
  static const String closingTime = 'closingTime';
  static const String scheduleError = 'scheduleError';

  static const String documentationTitle = 'documentationTitle';
  static const String documentationSubtitle = 'documentationSubtitle';
  static const String photoCount = 'photoCount';
  static const String addPhoto = 'addPhoto';
  static const String maxPhotoWarning = 'maxPhotoWarning';
  static const String noPhotoUploaded = 'noPhotoUploaded';

  static const Map<String, dynamic> EN = langEN;
  static const Map<String, dynamic> ID = langID;
  static const Map<String, dynamic> JA = langJA;
  static const Map<String, dynamic> TH = langTH;
  static const Map<String, dynamic> ZH = langZH;

  static Future<String> translateLive(String text) async {
    if (text.trim().isEmpty) return '';

    final String targetLang =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';

    try {
      final translator = GoogleTranslator();
      final translation = await translator.translate(text, to: targetLang);

      return translation.text;
    } catch (e) {
      debugPrint("Gagal menerjemahkan teks database: $e");
      return text;
    }
  }
}
