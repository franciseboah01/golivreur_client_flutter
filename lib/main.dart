import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'providers/panier_provider.dart';
import 'utils/app_theme.dart';
import 'utils/app_colors.dart';
import 'utils/app_transitions.dart';
import 'widgets/offline_banner.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/client/home_client.dart';
import 'screens/client/boutiques_screen.dart';
import 'screens/client/panier_screen.dart';
import 'screens/client/colis_screen.dart';
import 'screens/client/profil_client_screen.dart';
import 'screens/client/chat_list_screen.dart';
import 'screens/client/recherche_screen.dart';
import 'widgets/notification_badge.dart';

void main() {
  runApp(const GoLivreurClientApp());
}

class GoLivreurClientApp extends StatelessWidget {
  const GoLivreurClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => PanierProvider()),
      ],
      child: MaterialApp(
        title: 'GoLivreur Client',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(redirectRole: 'client', redirectRoute: '/home'),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              final args = settings.arguments as Map<String, String>?;
              return AppTransitions.fadeScale(LoginScreen(
                redirectRole: args?['role'] ?? 'client',
                redirectRoute: args?['route'] ?? '/home',
              ));
            case '/register':
              return AppTransitions.slideUp(const RegisterScreen());
            case '/home':
              return AppTransitions.fadeScale(const MainClientScreen());
            default:
              return AppTransitions.slideRight(const MainClientScreen());
          }
        },
      ),
    );
  }
}

class MainClientScreen extends StatefulWidget {
  const MainClientScreen({super.key});

  @override
  State<MainClientScreen> createState() => _MainClientScreenState();
}

class _MainClientScreenState extends State<MainClientScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeClient(),
    const BoutiquesScreen(),
    const PanierScreen(),
    const ColisScreen(),
    const ProfilClientScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final totalArticles = panier.totalArticles;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'GOLIVREUR',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.white),
            onPressed: () => Navigator.push(
              context, AppTransitions.slideUp(const RechercheScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: AppColors.white),
            onPressed: () => Navigator.push(
              context, AppTransitions.slideRight(const ChatListScreen())),
          ),
          const NotificationBadge(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: AppColors.white),
                onPressed: () => setState(() => _currentIndex = 2),
              ),
              if (totalArticles > 0)
                Positioned(
                  right: 6, top: 6,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        totalArticles > 99 ? '99+' : '$totalArticles',
                        style: const TextStyle(
                          color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      // OfflineBanner enveloppe le contenu principal
      body: OfflineBanner(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Boutique'),
          BottomNavigationBarItem(
            label: 'Panier',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag),
                if (totalArticles > 0)
                  Positioned(
                    right: -6, top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$totalArticles',
                        style: const TextStyle(
                          color: AppColors.white, fontSize: 9, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Colis'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}