import 'package:flutter/material.dart';
import '../../data/admin_service.dart';
import '../widgets/dashboard/security_tab_view.dart';
import '../widgets/dashboard/users_tab_view.dart';
import 'admin_settings_screen.dart';
import 'users_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  int _failedLoginSelectedIndex = -1;
  int _registrationsSelectedIndex = -1;
  bool _isLoading = true;
  bool _isLoadingUsers = false;
  bool _isFailedLoginsLoading = false;
  bool _isRegistrationsLoading = false;
  Map<String, dynamic>? _stats;
  List<dynamic> _users = [];
  bool _serverDown = false;
  int _failedLoginsWeekOffset = 0;
  int _registrationsWeekOffset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });
    final result = await AdminService.getUsers();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _users = result['data']['items'] ?? [];
          _isLoadingUsers = false;
        });
      } else {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _loadStats({String chartToLoad = 'both'}) async {
    setState(() {
      if (chartToLoad == 'both' || chartToLoad == 'failedLogins') {
        _isFailedLoginsLoading = true;
      }
      if (chartToLoad == 'both' || chartToLoad == 'registrations') {
        _isRegistrationsLoading = true;
      }
      _serverDown = false;
    });

    if (_stats == null) {
      setState(() {
        _isLoading = true;
      });
    }

    final now = DateTime.now();

    // Failed logins range
    final fMonday = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _failedLoginsWeekOffset * 7));
    final fSunday = fMonday.add(const Duration(days: 6));
    final fStart =
        "${fMonday.year}-${fMonday.month.toString().padLeft(2, '0')}-${fMonday.day.toString().padLeft(2, '0')}";
    final fEnd =
        "${fSunday.year}-${fSunday.month.toString().padLeft(2, '0')}-${fSunday.day.toString().padLeft(2, '0')}";

    // Registrations range
    final rMonday = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _registrationsWeekOffset * 7));
    final rSunday = rMonday.add(const Duration(days: 6));
    final rStart =
        "${rMonday.year}-${rMonday.month.toString().padLeft(2, '0')}-${rMonday.day.toString().padLeft(2, '0')}";
    final rEnd =
        "${rSunday.year}-${rSunday.month.toString().padLeft(2, '0')}-${rSunday.day.toString().padLeft(2, '0')}";

    final result = await AdminService.getStatistics(
      fStart: fStart,
      fEnd: fEnd,
      rStart: rStart,
      rEnd: rEnd,
    );

    if (mounted) {
      if (result['success']) {
        setState(() {
          _stats = result['data'];
          _serverDown = false;
          _isLoading = false;
          _isFailedLoginsLoading = false;
          _isRegistrationsLoading = false;
        });
      } else {
        setState(() {
          _stats = {};
          _serverDown = true;
          _isLoading = false;
          _isFailedLoginsLoading = false;
          _isRegistrationsLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('No se pudo conectar al servidor: ${result["message"]}'),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getDynamicDateRange(int offset) {
    final now = DateTime.now();
    final monday = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: offset * 7));
    final sunday = monday.add(const Duration(days: 6));

    final months = [
      "Ene",
      "Feb",
      "Mar",
      "Abr",
      "May",
      "Jun",
      "Jul",
      "Ago",
      "Sep",
      "Oct",
      "Nov",
      "Dic"
    ];
    return "${months[monday.month - 1]} ${monday.day} - ${months[sunday.month - 1]} ${sunday.day}";
  }

  @override
  Widget build(BuildContext context) {
    // The screen should render immediately, skeleton loaders/spinners 
    // are handled individually by the cards and tabs based on _isLoading variables.

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'OHTUIE',
          style:
              TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminSettingsScreen()),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu, color: Colors.black, size: 24),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Gestión de Seguridad'),
            Tab(text: 'Gestión de Usuarios'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_serverDown)
            Material(
              color: Colors.orange[700],
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Servidor no disponible — mostrando datos en cero',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _loadStats();
                        _loadUsers();
                      },
                      child: const Text('Reintentar',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SecurityTabView(
                  stats: _stats,
                  isFailedLoginsLoading: _isFailedLoginsLoading,
                  isRegistrationsLoading: _isRegistrationsLoading,
                  failedLoginsWeekOffset: _failedLoginsWeekOffset,
                  registrationsWeekOffset: _registrationsWeekOffset,
                  failedLoginSelectedIndex: _failedLoginSelectedIndex,
                  registrationsSelectedIndex: _registrationsSelectedIndex,
                  dateRangeFormatter: _getDynamicDateRange,
                  onFailedLoginTap: (idx) => setState(() =>
                      _failedLoginSelectedIndex =
                          _failedLoginSelectedIndex == idx ? -1 : idx),
                  onRegistrationTap: (idx) => setState(() =>
                      _registrationsSelectedIndex =
                          _registrationsSelectedIndex == idx ? -1 : idx),
                  onFailedLoginPrev: () {
                    setState(() {
                      _failedLoginsWeekOffset--;
                    });
                    _loadStats(chartToLoad: 'failedLogins');
                  },
                  onFailedLoginNext: () {
                    setState(() {
                      _failedLoginsWeekOffset++;
                    });
                    _loadStats(chartToLoad: 'failedLogins');
                  },
                  onRegistrationPrev: () {
                    setState(() {
                      _registrationsWeekOffset--;
                    });
                    _loadStats(chartToLoad: 'registrations');
                  },
                  onRegistrationNext: () {
                    setState(() {
                      _registrationsWeekOffset++;
                    });
                    _loadStats(chartToLoad: 'registrations');
                  },
                  onRefreshFailedLogins: () => _loadStats(chartToLoad: 'failedLogins'),
                  onRefreshRegistrations: () => _loadStats(chartToLoad: 'registrations'),
                ),
                UsersTabView(
                  users: _users,
                  isLoadingUsers: _isLoadingUsers,
                  usersError: null,
                  stats: _stats,
                  isStatsLoading: _isFailedLoginsLoading || _isRegistrationsLoading,
                  onRefreshUsers: _loadUsers,
                  onRefreshStats: () => _loadStats(chartToLoad: 'both'),
                  onViewAllUsers: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UsersListScreen()),
                    ).then((_) => _loadUsers());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
