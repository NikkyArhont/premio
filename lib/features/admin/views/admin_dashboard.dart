import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premio/features/auth/providers/auth_provider.dart';
import 'package:premio/features/admin/views/widgets/logout_modal.dart';
import 'package:premio/features/admin/views/widgets/change_password_modal.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 1; // Default to "Оборудование"
  bool _isProfileMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      body: Row(
        children: [
          _buildSidebar(context, authState),
          Expanded(
            child: _buildMainContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AuthState authState) {
    return Container(
      width: 233,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF9),
        border: Border(
          right: BorderSide(color: Color(0xFFF4F1EC)),
        ),
      ),
      child: Column(
        children: [
          // Logo section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Image.asset('assets/logo.png', height: 32),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Nav items
          _buildNavItem(0, 'Пользователи', 'assets/webUserOn.png', 'assets/webUser.png'),
          _buildNavItem(1, 'Оборудование', 'assets/webTechOn.png', 'assets/webTech.png'),
          const Spacer(),
          // Profile section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F1EC),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isProfileMenuOpen = !_isProfileMenuOpen;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          authState.user?.email ?? 'Администратор',
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.unfold_more,
                        size: 20,
                        color: const Color(0xFF006A36),
                      ),
                    ],
                  ),
                ),
                if (_isProfileMenuOpen) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE5E5E5), height: 1),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ChangePasswordModal(),
                      );
                    },
                    child: const Text(
                      'Сменить пароль',
                      style: TextStyle(
                        color: Color(0xFF93959E),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const LogoutModal(),
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.logout, size: 18, color: Color(0xFF93959E)),
                        SizedBox(width: 8),
                        Text(
                          'Выйти',
                          style: TextStyle(
                            color: Color(0xFF93959E),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, String activeIconAsset, String inactiveIconAsset) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006A36) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Image.asset(
              isSelected ? activeIconAsset : inactiveIconAsset,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF717171),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (_selectedIndex == 0) {
      return _buildUsersContent(context);
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'База данных оборудования',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF199C5B),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Пакетная генерация QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F1EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Table Header
                  Row(
                    children: [
                      const SizedBox(width: 48, child: Text('№', style: TextStyle(color: Color(0xFF93959E), fontWeight: FontWeight.bold))),
                      const Expanded(flex: 2, child: Text('ID номер', style: TextStyle(color: Color(0xFF93959E), fontWeight: FontWeight.bold))),
                      const Expanded(flex: 2, child: Text('Статус', style: TextStyle(color: Color(0xFF93959E), fontWeight: FontWeight.bold))),
                      const SizedBox(width: 80),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Table Rows
                  for (int i = 1; i <= 10; i++)
                    _buildTableRow(
                      i,
                      i == 2 || i == 4 || i == 6 ? 'ESP32-001246' : 'ESP32-001245',
                      i == 2 || i == 4 || i == 6 ? 'Новый' : 'Активен',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(int index, String idString, String status) {
    final isActive = status == 'Активен';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              index.toString(),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              idString,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF189B5B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isActive ? null : Border.all(color: const Color(0xFF1A1A1A)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.qr_code, size: 16, color: Colors.black),
                SizedBox(width: 4),
                Text('QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'База данных пользователей',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          // Поле поиска
          Container(
            width: double.infinity,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1A1A1A)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Color(0xFF717171)),
                SizedBox(width: 8),
                Text(
                  'Поиск по имени / ID',
                  style: TextStyle(
                    color: Color(0xFF717171),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Таблица пользователей
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F1EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Table Header
                  Row(
                    children: const [
                      SizedBox(width: 48, child: Text('№', style: TextStyle(color: Color(0xFF93959E), fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Имя', style: TextStyle(color: Color(0xFF93959E), fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Дата активации', style: TextStyle(color: Color(0xFF93959E), fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('ID номер', style: TextStyle(color: Color(0xFF93959E), fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('Статус', style: TextStyle(color: Color(0xFF93959E), fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Table Rows
                  for (int i = 1; i <= 10; i++)
                    _buildUserRow(
                      i,
                      'Иван Петров',
                      '12.03.2026',
                      i == 2 || i == 4 || i == 5 ? 'ESP32-001246' : (i == 3 ? 'ESP32-001244' : 'ESP32-001242'),
                      i == 2 || i == 4 || i == 5 ? 'Новый' : 'Активен',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(int index, String name, String date, String idString, String status) {
    final isActive = status == 'Активен';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              index.toString(),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              idString,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF189B5B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isActive ? null : Border.all(color: const Color(0xFF1A1A1A)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
