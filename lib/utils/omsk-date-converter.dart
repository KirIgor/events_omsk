import 'date-converter.dart';

class OmskDateConverter implements DateConverter {
  @override
  DateTime convert(DateTime dateTime) {
    return dateTime.toUtc().add(Duration(hours: 6));
  }
}
