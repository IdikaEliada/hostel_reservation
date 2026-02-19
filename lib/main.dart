import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:hostel_reservation/splash_screen.dart';
//import 'data_seeder.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/hostel_list_screen.dart';
import 'screens/hostel_detail_screen.dart';
import 'screens/room_selection_screen.dart';
import 'screens/complaint_page.dart';
import 'screens/review_page.dart';
import 'screens/feedback_screen.dart';
import 'screens/admin/manage_rooms_screen.dart';
import 'screens/admin/add_edit_room_screen.dart';
import 'screens/user_profile.dart';
import 'sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the seeding function immediately when the app starts
  // await seedHostelData();

  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/signin', builder: (context, state) => const SignInScreen()),

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
      path: '/complaints',
      builder: (context, state) => ComplaintPage(),
    ),

    GoRoute(
      path: '/reviews',
      builder: (context, state) => ReviewPage(),
    ),

    GoRoute(
      path: '/feedback',
      builder: (context, state) => FeedbackScreen(),
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
    //user profile route
    GoRoute(
      path: '/profile',
      builder: (context, state) => const UserProfileScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hostel Reservation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
