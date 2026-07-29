import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premio/features/client/views/client_profile.dart';
import 'package:premio/features/device/views/device_control_view.dart';
import 'package:premio/features/device/providers/device_provider.dart';

class ClientHome extends ConsumerStatefulWidget {
  const ClientHome({super.key});

  @override
  ConsumerState<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends ConsumerState<ClientHome> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    ClientDashboard(),
    ClientProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF006A36),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFFFFCF8),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/main.png', width: 56, height: 32),
            activeIcon: Image.asset('assets/mainOn.png', width: 56, height: 32),
            label: 'Моя баня',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/profile.png', width: 56, height: 32),
            activeIcon: Image.asset('assets/profileOn.png', width: 56, height: 32),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard> {
  double _targetTemp = 90.0;

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceStatusProvider);
    final isConnected = deviceState.isConnected;
    final status = deviceState.status;
    final tempStr = status?.temperature?.toInt().toString() ?? '--';
    final humidity = status?.humidity ?? 0.0;
    final lighting = deviceState.localBrightness.toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isConnected),
          const SizedBox(height: 16),
          const DeviceControlView(),
          const SizedBox(height: 24),
          _buildStatusRow(isConnected),
          const SizedBox(height: 16),
          _buildTemperatureCard(tempStr),
          const SizedBox(height: 16),
          _buildClimateCard(humidity, lighting),
          const SizedBox(height: 16),
          _buildTimerCard(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isConnected) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: ShapeDecoration(
              color: const Color(0xFFE6E6E6),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFF1A1A1A),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isConnected ? 'Включена' : 'Выключена',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Image.asset('assets/Notification.png', width: 28, height: 28),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width: 115, height: 32),
            const Text('v1.0.9', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusRow(bool isConnected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusCard('СЕАНС', '00:27:47', Icons.timer_outlined),
        _buildStatusCard('ГОТОВНОСТЬ', '100%', Icons.water_drop_outlined),
        _buildStatusCard('ПИТАНИЕ', isConnected ? 'Вкл.' : 'Выкл.', Icons.power_settings_new),
      ],
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureCard(String tempStr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E1), // Это чистый FFDAB4 с прозрачностью 40% наложенный на белый
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDAB4).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset('assets/thermometer.png', width: 24, height: 24),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Температура в парной',
                        style: TextStyle(
                          color: Color(0xFF9D9D9D),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$tempStr°',
                    style: const TextStyle(
                      color: Color(0xFFFF5D40),
                      fontSize: 64,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Цель',
                    style: TextStyle(
                      color: Color(0xFF515151),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${_targetTemp.toInt()}°',
                    style: const TextStyle(
                      color: Color(0xFF311A0B),
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Целевая температура',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '50° - 120°',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFFF5D40),
              inactiveTrackColor: const Color(0xFFEFEFEF),
              thumbColor: const Color(0xFFCD350A),
              trackHeight: 6,
            ),
            child: Slider(
              value: _targetTemp,
              min: 50,
              max: 120,
              onChanged: (val) {
                setState(() {
                  _targetTemp = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateCard(double humidity, double lighting) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          _buildClimateControl(
            title: 'Влажность',
            subtitle: 'Уровень влажности',
            assetPath: 'assets/Humidity.png',
            value: humidity,
            unit: '%',
            min: 0,
            max: 100,
            activeTrackColor: const Color(0xFF02B3FF),
            thumbColor: const Color(0xFF10B6FD),
            isReadOnly: true,
            onChanged: (val) {},
          ),
          const SizedBox(height: 16),
          _buildClimateControl(
            title: 'Освещение',
            subtitle: 'Уровень освещения',
            assetPath: 'assets/Light.png',
            value: lighting,
            unit: '%',
            min: 0,
            max: 100,
            activeTrackColor: const Color(0xFFFFAE3E),
            thumbColor: const Color(0xFFFFB142),
            onChanged: (val) {
              ref.read(deviceStatusProvider.notifier).updateBrightness(val.toInt());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClimateControl({
    required String title,
    required String subtitle,
    required String assetPath,
    required double value,
    required String unit,
    required double min,
    required double max,
    required Color activeTrackColor,
    required Color thumbColor,
    required ValueChanged<double> onChanged,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(assetPath, width: 40, height: 40, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '${value.toInt()}$unit',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing: isReadOnly,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeTrackColor,
              inactiveTrackColor: const Color(0xFFEFEFEF),
              thumbColor: isReadOnly ? Colors.transparent : thumbColor,
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFFFFDF9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x42000000),
            blurRadius: 0.63,
            offset: Offset(0.44, 0.44),
            spreadRadius: -0.75,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: 0.7, // пример прогресса
              strokeWidth: 3,
              color: Color(0xFF4C8F5B), // зеленый
              backgroundColor: Color(0xFFE6E2D6), // бежево-серый фон кольца
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                '22:30',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 22,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Осталось до конца программы',
                style: TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 10,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
