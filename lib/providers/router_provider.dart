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
import 'package:hostel_reservation/registration_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isAuth = authState.asData?.value != null;

      final isSplash = state.uri.toString() == '/';
      final isLogin = state.uri.toString() == '/signin';
      final isRegister = state.uri.toString() == '/register';

      if (isLoading || hasError) return null;

      if (isSplash) {
        return isAuth ? '/hostels' : '/signin';
      }

      if (isLogin || isRegister) {
        return isAuth ? '/hostels' : null;
      }

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
        path: '/admin/rooms',
        builder: (context, state) => const ManageRoomsScreen(),
      ),
      GoRoute(
        path: '/admin/rooms/add',
        builder: (context, state) => const AddEditRoomScreen(),
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
