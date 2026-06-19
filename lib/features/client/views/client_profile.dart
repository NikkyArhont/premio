import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premio/core/models/user_profile.dart';
import 'package:premio/features/auth/providers/auth_provider.dart';
import 'package:premio/features/auth/providers/profile_provider.dart';

class ClientProfile extends ConsumerStatefulWidget {
  const ClientProfile({super.key});

  @override
  ConsumerState<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends ConsumerState<ClientProfile> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildMySaunaCard(context),
          const SizedBox(height: 24),
          const Text(
            'Подключённые устройства',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDevicesList(),
          const SizedBox(height: 32),
          _buildSupportCard(),
          const SizedBox(height: 16),
          _buildLogoutCard(context, ref),
          const SizedBox(height: 16),
          _buildWebAdminButton(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWebAdminButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Меняем роль на админа для обхода защиты роутера в тестовом режиме
        ref.read(authProvider.notifier).devLogin(UserRole.admin);
        context.go('/admin');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF189B5B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF189B5B)),
        ),
        child: Row(
          children: const [
            Icon(Icons.open_in_browser, color: Color(0xFF189B5B)),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Перейти в веб-админку',
                style: TextStyle(
                  color: Color(0xFF189B5B),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Настройки',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Устройство и профиль',
          style: TextStyle(
            color: Color(0xFF717171),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMySaunaCard(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final String saunaName = profileState.name.isNotEmpty ? profileState.name : 'Моя баня';
    final String saunaAddress = profileState.address.isNotEmpty ? profileState.address : 'Баня на даче';

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.hot_tub, color: Color(0xFF006A36)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    saunaName,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    saunaAddress,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: () => _showEditProfileBottomSheet(context, saunaName, saunaAddress),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFAF9F4)),
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
          _buildDeviceItem(
            name: 'Датчик температуры и влажности',
            description: 'Высокоточный цифровой сенсор SHT30',
            icon: Icons.thermostat,
            isConnected: true,
          ),
          const Divider(height: 1, color: Color(0xFFFAF9F4)),
          _buildDeviceItem(
            name: 'Релейный модуль печи',
            description: 'Релейный модуль Modbus-Rtu (12V)',
            icon: Icons.electrical_services,
            isConnected: false,
          ),
          const Divider(height: 1, color: Color(0xFFFAF9F4)),
          _buildDeviceItem(
            name: 'Освещение',
            description: 'Контроллер Modbus-Rtu RGBW',
            icon: Icons.lightbulb_outline,
            isConnected: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem({
    required String name,
    required String description,
    required IconData icon,
    required bool isConnected,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isConnected ? const Color(0xFFFAF9F4) : const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.grey[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF515151),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isConnected ? const Color(0x7FE3EFDC) : const Color(0x7FF2F2F2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Text(
                  isConnected ? 'Подключено' : 'Отключено',
                  style: TextStyle(
                    color: isConnected ? const Color(0xFF006A36) : const Color(0xFF666666),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isConnected ? const Color(0xFF006A36) : const Color(0xFF666666),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x19006A36),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.support_agent, color: Color(0xFF006A36)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Поддержка',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Задать вопрос',
                    style: TextStyle(
                      color: Color(0xFF515151),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        _showLogoutBottomSheet(context, ref);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        child: const Center(
          child: Text(
            'Выйти из аккаунта',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(
          top: 8,
          left: 16,
          right: 16,
          bottom: 32, // extra padding for safe area
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F4),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF515151),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Выйти из аккаунта?',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Вы будете выведены из системы на этом устройстве.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(authProvider.notifier).signOut();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF9F4),
                        border: Border.all(color: const Color(0x7F006A36)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Выйти',
                          style: TextStyle(
                            color: Color(0xFF006A36),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF189B5B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                            color: Color(0xFFFAF9F4),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet(BuildContext context, String currentName, String currentAddress) {
    final nameController = TextEditingController(text: currentName);
    final addressController = TextEditingController(text: currentAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // to allow keyboard to push it up
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
            bottom: 32, // extra padding for safe area
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF9F4),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF515151),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Редактировать данные',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFF1A1A1A)),
                decoration: InputDecoration(
                  hintText: 'Имя',
                  hintStyle: const TextStyle(color: Color(0xFF717171)),
                  filled: true,
                  fillColor: const Color(0x26CCC3BA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                style: const TextStyle(color: Color(0xFF1A1A1A)),
                decoration: InputDecoration(
                  hintText: 'Адрес',
                  hintStyle: const TextStyle(color: Color(0xFF717171)),
                  filled: true,
                  fillColor: const Color(0x26CCC3BA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    ref.read(profileProvider.notifier).saveProfile(nameController.text, addressController.text);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF189B5B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Сохранить',
                        style: TextStyle(
                          color: Color(0xFFFAF9F4),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
