import 'package:adhan/adhan.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:intl/intl.dart';
import 'package:prayer_time_api/model/calender.dart';

Response onRequest(RequestContext context) {
  final request = context.request;
  final method = request.method.value;
  if (method != 'GET') {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method Not Allowed'},
    );
  }

  final queryParams = request.url.queryParameters;
  final lat = double.tryParse(queryParams['lat'] ?? '');
  final lon = double.tryParse(queryParams['lon'] ?? '');
  if (lat == null || lon == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'Incorrect query parameters',
        'params': [
          {'name': 'lat', 'status': 'Required', 'type': 'double'},
          {'name': 'lon', 'status': 'Required', 'type': 'double'}
        ]
      },
    );
  }

  final coordinates = Coordinates(lat, lon);
  final params = CalculationMethod.dubai.getParameters();
  params.madhab = Madhab.shafi;
  final prayerTimes = PrayerTimes.today(coordinates, params);

  final prayerTimesMap = {
    'fajr': DateFormat.jm().format(prayerTimes.fajr),
    'dhuhr': DateFormat.jm().format(prayerTimes.dhuhr),
    'asr': DateFormat.jm().format(prayerTimes.asr),
    'maghrib': DateFormat.jm().format(prayerTimes.maghrib),
    'isha': DateFormat.jm().format(prayerTimes.isha),
  };

  final calculatedCalenderIndex = DateTime.now()
      .difference(
        DateTime(2023, 3, 24),
      )
      .inDays;

  print(calculatedCalenderIndex);
  final calender = getCalender(cityName: 'Dhaka');

  final ramadanTimes = calender[calculatedCalenderIndex];

  // final ramadanTimes = {
  //   'sehri': DateFormat.jm().format(
  //     prayerTimes.fajr.subtract(const Duration(minutes: 5)),
  //   ),
  //   'iftar': DateFormat.jm().format(prayerTimes.maghrib),
  // };

  return Response.json(
    body: {
      'service': 'Prayer Time API',
      'version': '0.9.0',
      'prayer_times': prayerTimesMap,
      'ramadan_times': ramadanTimes['ramadan_times'],
    },
  );
}
