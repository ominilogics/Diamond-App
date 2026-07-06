import 'package:daimond/l10n/app_localizations.dart';

extension CategoryLocalization on String {
  String localized(AppLocalizations texts) {
    switch (toLowerCase()) {
      case 'love':
        return texts.love;
      case 'congratulations':
        return texts.congratulations;
      case 'birthday':
        return texts.birthday;
      case "mother's day":
      case 'mothers day':
        return texts.mothersDay;
      case "father's day":
      case 'fathers day':
        return texts.fathersDay;
      case 'thank you':
        return texts.thankYou;
      case 'belated birthday':
        return texts.belatedBirthday;
      case 'friendship':
        return texts.friendship;
      case 'sympathy':
        return texts.sympathy;
      case 'missing you':
        return texts.missingYou;
      case 'troubled relationship':
        return texts.troubledRelationship;
      case 'advice':
        return texts.advice;
      case 'wedding':
        return texts.wedding;
      case 'good luck':
        return texts.goodLuck;
      case 'anniversary':
        return texts.anniversary;
      default:
        // Fallback to the database string if not localized yet
        return this;
    }
  }
}
