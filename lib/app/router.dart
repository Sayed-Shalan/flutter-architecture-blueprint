import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/bookings/presentation/booking_detail_page.dart';
import '../features/bookings/presentation/booking_list_page.dart';
import '../features/bookings/presentation/create_booking_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/bookings',
    routes: [
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const BookingListPage(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CreateBookingPage(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BookingDetailPage(id: id);
            },
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
