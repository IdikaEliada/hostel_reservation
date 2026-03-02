import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hostel_reservation/providers/auth_provider.dart';
import 'package:hostel_reservation/screens/home_screen.dart';
import 'package:hostel_reservation/screens/hostel_detail_screen.dart';
import 'package:hostel_reservation/screens/hostel_list_screen.dart';
import 'package:hostel_reservation/screens/room_selection_screen.dart';
import 'package:hostel_reservation/screens/user_profile.dart';
import 'package:hostel_reservation/sign_in_screen.dart';
import 'package:hostel_reservation/splash_screen.dart';
import 'package:hostel_reservation/screens/admin/manage_rooms_screen.dart';
import 'package:hostel_reservation/screens/admin/add_edit_room_screen.dart';
import 'package:hostel_reservation/screens/admin/manage_hostels_screen.dart';
import 'package:hostel_reservation/screens/admin/add_edit_hostel_screen.dart';
import 'package:hostel_reservation/registration_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isAdminAuth = ref.watch(adminAuthProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isAuth = authState.asData?.value != null;
      final path = state.uri.toString();

      final isSplash = path == '/';
      final isLogin = path == '/signin';
      final isRegister = path == '/register';
      final isAdmin = path.startsWith('/admin');

      if (isLoading || hasError) return null;

      // Admin is authenticated via unique key — let them through /admin/* freely
      if (isAdminAuth && isAdmin) return null;
      // Admin trying to access other pages → push to admin dashboard
      if (isAdminAuth && (isSplash || isLogin || isRegister)) {
        return '/admin/hostels';
      }

      if (isSplash) {
        return isAuth ? '/hostels' : '/signin';
      }

      if (isLogin || isRegister) {
        return isAuth ? '/hostels' : null;
      }

      // Block unauthenticated users from admin and other protected routes
      if (!isAuth) {
        return '/signin';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/hostels',
        builder: (context, state) => const HostelListScreen(),
      ),
      GoRoute(
        path: '/hostel/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final data = state.extra as Map<String, dynamic>?;
          return HostelDetailScreen(hostelId: id, hostelData: data);
        },
      ),
      GoRoute(
        path: '/hostel/:id/rooms',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RoomSelectionScreen(hostelId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/admin/hostels',
        builder: (context, state) => const ManageHostelsScreen(),
      ),
      GoRoute(
        path: '/admin/hostels/add',
        builder: (context, state) => const AddEditHostelScreen(),
      ),
      GoRoute(
        path: '/admin/hostels/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final data = state.extra as Map<String, dynamic>?;
          return AddEditHostelScreen(hostelId: id, initialData: data);
        },
      ),
      GoRoute(
        path: '/admin/rooms',
        builder: (context, state) {
          final hostelId = state.uri.queryParameters['hostelId'];
          return ManageRoomsScreen(hostelId: hostelId);
        },
      ),
      GoRoute(
        path: '/admin/rooms/add',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return AddEditRoomScreen(initialData: data);
        },
      ),
      GoRoute(
        path: '/admin/rooms/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final data = state.extra as Map<String, dynamic>?;
          return AddEditRoomScreen(roomId: id, initialData: data);
        },
      ),
    ],
  );
});
