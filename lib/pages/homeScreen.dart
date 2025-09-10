import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_application/pages/weather_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final ForecastService _forecastService = ForecastService();
  final TextEditingController _cityController = TextEditingController();

  Map<String, dynamic>? _weatherData;
  List<dynamic>? _forecastData;
  bool loading = false;
  bool forecastLoading = false;
  String errorMessage = '';
  String forecastErrorMessage = '';

  Future<void> _getWeather(String city) async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      final weatherData = await _weatherService.fetchWeather(city);
      setState(() {
        _weatherData = weatherData;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = "Could not fetch weather data";
      });
    }
  }

  Future<void> _getForecast(String city) async {
    setState(() {
      forecastLoading = true;
      forecastErrorMessage = '';
    });

    try {
      final forecastData = await _forecastService.fetchWeather(city);
      setState(() {
        _forecastData = forecastData['list']; // Extract forecast list
        forecastLoading = false;
      });
    } catch (e) {
      setState(() {
        forecastLoading = false;
        forecastErrorMessage = "Could not fetch forecast data";
      });
    }
  }

  /// 🔥 Get main weather icon
  String _getWeatherImage() {
    if (_weatherData == null) return 'assets/image/cloudy.png';
    final weatherMain = _weatherData!['weather'][0]['main'].toString().toLowerCase();
    if (weatherMain.contains('clear')) return 'assets/image/sunny.png';
    if (weatherMain.contains('cloud')) return 'assets/image/cloudy.png';
    if (weatherMain.contains('rain')) return 'assets/image/rainy.png';
    if (weatherMain.contains('storm') || weatherMain.contains('thunder')) {
      return 'assets/image/storm.png';
    }
    return 'assets/image/cloudy.png';
  }

  List<Map<String, dynamic>> _getDailyForecast() {
    if (_forecastData == null) return [];
    final Map<String, Map<String, dynamic>> dailyData = {};

    for (var entry in _forecastData!) {
      final date = DateTime.fromMillisecondsSinceEpoch(entry['dt'] * 1000, isUtc: true).toLocal();
      final dayKey = "${date.year}-${date.month}-${date.day}";

      // Pick the first midday forecast (12:00) or fallback to first of the day
      if (!dailyData.containsKey(dayKey) || date.hour == 12) {
        dailyData[dayKey] = entry;
      }
    }

    return dailyData.values.take(4).toList(); // Return 4 days
  }

  /// 🔥 Get weather icon for forecast
  String _getWeatherImageFromCondition(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('clear')) return 'assets/image/sunny.png';
    if (condition.contains('cloud')) return 'assets/image/cloudy.png';
    if (condition.contains('rain')) return 'assets/image/rainy.png';
    if (condition.contains('storm') || condition.contains('thunder')) {
      return 'assets/image/storm.png';
    }
    return 'assets/image/cloudy.png';
  }

  String _formatTime(int timestamp) {
    final DateTime time =
    DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
        .toLocal();
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _formatDate(int timestamp) {
    final DateTime date =
    DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
        .toLocal();
    return "${date.day}/${date.month}";
  }

  Widget _infoTile(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 34),
        SizedBox(width: 5),
        Text(value, style: TextStyle(fontSize: 20, color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.cloud, color: Colors.white, size: 50),
            SizedBox(width: 10),
            Text(
              "Weatherly",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color(0xff4a90e2),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20,),
            // 🔍 Search bar
            Center(
              child: Container(
                width: 300,
                height: 50,
                margin: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: "Enter a city",
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.grey),
                        onPressed: () {
                          if (_cityController.text.isNotEmpty) {
                            _getWeather(_cityController.text);
                            _getForecast(_cityController.text);
                            _cityController.clear();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Loader or Error
            if (loading) CircularProgressIndicator(),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(errorMessage, style: TextStyle(color: Colors.red)),
              ),

            if (_weatherData != null) ...[
              SizedBox(height: 20),

              // 🌡️ Weather Card
              Container(
                height: 400,
                width: 300,
                child: Card(
                  color: Colors.black,
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10,),
                          Icon(Icons.location_on, size: 30, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "${_weatherData!['name']}",
                            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
                          ),

                        ],
                      ),
                      SizedBox(height: 50),
                      Image.asset(
                        _getWeatherImage(),
                        height: 100,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${_weatherData!['main']['temp'].toStringAsFixed(1)}°C",
                        style: TextStyle(fontSize: 58, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Min: ${_weatherData!['main']['temp_min']}°C / Max: ${_weatherData!['main']['temp_max']}°C",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 💧Humidity, Pressure, Wind
              Container(
                width: 400,
                height: 80,
                child: Card(
                  color: Colors.black,
                  elevation: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoTile(Icons.water_drop,
                          '${_weatherData!['main']['humidity']}%'),
                      _infoTile(Icons.thermostat,
                          '${_weatherData!['main']['pressure']} hPa'),
                      _infoTile(Icons.wind_power,
                          '${_weatherData!['wind']['speed']} km/h'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 🌅 Sunrise & Sunset
              Container(
                width: 370,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Other Details',
                            style:
                            TextStyle(fontSize: 24, color: Colors.white)),
                        Icon(Icons.calendar_month,
                            size: 28, color: Colors.white),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset('assets/image/sun rise.png',
                            height: 50, width: 50),
                        SizedBox(width: 10),
                        Text('Sunrise: ',
                            style:
                            TextStyle(fontSize: 22, color: Colors.white)),
                        SizedBox(width: 10),
                        Text(
                          _formatTime(_weatherData!['sys']['sunrise']),
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset('assets/image/sun set.png',
                            height: 50, width: 50),
                        SizedBox(width: 10),
                        Text('Sunset: ',
                            style:
                            TextStyle(fontSize: 22, color: Colors.white)),
                        SizedBox(width: 10),
                        Text(
                          _formatTime(_weatherData!['sys']['sunset']),
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // 🔮 Forecast
              if (_forecastData != null) ...[
                Container(
                  width: 370,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Column(
                        children: _getDailyForecast().map((day) {
                          final condition = day['weather'][0]['main'];
                          return Card(
                            color: Colors.grey[800],
                            child: ListTile(
                              leading: Image.asset(
                                _getWeatherImageFromCondition(condition),
                                height: 40,
                              ),
                              title: Text(
                                _formatDate(day['dt']),
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              subtitle: Text(
                                "${day['main']['temp_min']}°C / ${day['main']['temp_max']}°C",
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Text(
                                condition,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            SizedBox(height: 50),
            Row(
              children: [
                SizedBox(width: 10),
                Text("Bringing sunshine to \nyour screen ❤️",
                    style: TextStyle(
                        fontSize: 28,
                        color: Color(0xff9c9c9c),
                        fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
