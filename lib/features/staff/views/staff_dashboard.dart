import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premio/features/auth/providers/auth_provider.dart';

class StaffDashboard extends ConsumerWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Mock active and pending bookings for staff dashboard
    final mockBookings = [
      {
        'sauna': 'Финская Парная "Кедр"',
        'client': 'Иван Иванов',
        'time': '14:00 - 17:00 (Сегодня)',
        'status': 'Активно',
        'color': Colors.green,
      },
      {
        'sauna': 'Русская Баня "Таежная"',
        'client': 'Мария Смирнова',
        'time': '18:00 - 21:00 (Сегодня)',
        'status': 'Ожидает оплаты',
        'color': Colors.amber,
      },
      {
        'sauna': 'Финская Парная "Кедр"',
        'client': 'Алексей Петров',
        'time': '10:00 - 12:00 (Завтра)',
        'status': 'Подтверждено',
        'color': Colors.blue,
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель Администратора Сауны'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authState.user != null) ...[
              Text(
                'Приветствуем, ${authState.user!.name}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Text('Смена: Администратор филиала'),
              const SizedBox(height: 24),
            ],
            // Summary KPI cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 36),
                          const SizedBox(height: 8),
                          Text('1 сеанс', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green.shade900)),
                          const Text('активно сейчас', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.schedule, color: Colors.amber.shade900, size: 36),
                          const SizedBox(height: 8),
                          Text('2 брони', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.amber.shade900)),
                          const Text('на сегодня', style: TextStyle(color: Colors.amber)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Расписание сеансов',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockBookings.length,
              itemBuilder: (context, index) {
                final booking = mockBookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: booking['color'] as Color,
                      child: const Icon(Icons.hot_tub, color: Colors.white, size: 20),
                    ),
                    title: Text(booking['sauna'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${booking['client']} • ${booking['time']}'),
                    trailing: Chip(
                      backgroundColor: (booking['color'] as Color).withAlpha(30),
                      label: Text(
                        booking['status'] as String,
                        style: TextStyle(color: booking['color'] as Color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
