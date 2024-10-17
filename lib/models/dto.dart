class LoginRequestDTO {
  String username;
  String password;

  LoginRequestDTO({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

class LoginResponseDTO {
  String status;
  String? token; // token을 nullable로 변경

  LoginResponseDTO({required this.status, this.token}); // token에 기본값 할당

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      status: json['status'] ?? '', // status가 null일 경우 빈 문자열로 대체
      token: json['token'], // token이 null일 수 있으므로 처리
    );
  }
}

class UserResponseDTO {
  final int id;
  final String username;
  final String nickname;
  final String car;
  final String carnumber;
  final String business;
  final String password;

  UserResponseDTO(
      {required this.id,
      required this.username,
      required this.nickname,
      required this.car,
      required this.carnumber,
      required this.business,
      required this.password});

  factory UserResponseDTO.fromJson(Map<String, dynamic> json) {
    return UserResponseDTO(
        id: json['id'],
        username: json['username'],
        nickname: json['nickname'],
        car: json['car'],
        carnumber: json['carnumber'],
        business: json['business'],
        password: json['password']);
  }
}

class WeatherDTO {
  final List<WeatherDay> forecastDays;

  WeatherDTO({required this.forecastDays});

  factory WeatherDTO.fromJson(Map<String, dynamic> json) {
    var forecastList = json['forecastday'] as List;
    List<WeatherDay> forecastDays =
        forecastList.map((day) => WeatherDay.fromJson(day)).toList();

    return WeatherDTO(forecastDays: forecastDays);
  }
}

class WeatherDay {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String conditionIcon;

  WeatherDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.conditionIcon,
  });

  factory WeatherDay.fromJson(Map<String, dynamic> json) {
    return WeatherDay(
      date: json['date'],
      minTemp: json['day']['mintemp_c'],
      maxTemp: json['day']['maxtemp_c'],
      conditionIcon: json['day']['condition']['icon'],
    );
  }
}

class NewsDTO {
  final String title;
  final String link;
  final String description;
  final String pubDate;

  NewsDTO(
      {required this.title,
      required this.link,
      required this.description,
      required this.pubDate});

  factory NewsDTO.fromJson(Map<String, dynamic> json) {
    return NewsDTO(
      title: json['title'],
      link: json['link'],
      description: json['description'],
      pubDate: json['pubDate'],
    );
  }
}
