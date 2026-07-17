import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/app/shell/app_shell.dart';
import 'package:local_first/app/shell/placeholder_page.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_kyc_cubit.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_users_cubit.dart';
import 'package:local_first/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:local_first/features/admin/presentation/pages/admin_kyc_review_page.dart';
import 'package:local_first/features/admin/presentation/pages/admin_user_management_page.dart';
import 'package:local_first/features/auth/presentation/pages/kyc_upload_page.dart';
import 'package:local_first/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:local_first/features/auth/presentation/pages/phone_login_page.dart';
import 'package:local_first/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:local_first/features/listings/presentation/cubits/listing_form_cubit.dart';
import 'package:local_first/features/listings/presentation/pages/create_listing_page.dart';
import 'package:local_first/features/listings/presentation/pages/item_detail_page.dart';
import 'package:local_first/features/listings/presentation/pages/marketplace_home_page.dart';
import 'package:local_first/features/listings/presentation/widgets/map_preview_overlay.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn = state.matchedLocation == '/' || state.matchedLocation == '/otp';

      if (user == null) {
        // Force login if trying to access protected screens
        if (!loggingIn) {
          return '/';
        }
      } else {
        // Redirect to home if logged in and trying to access login page
        if (loggingIn) {
          return '/home';
        }
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouteNames.phoneLogin,
        builder: (BuildContext context, GoRouterState state) {
          return const PhoneLoginPage();
        },
      ),
      GoRoute(
        path: '/otp',
        name: RouteNames.otp,
        builder: (BuildContext context, GoRouterState state) {
          final phone = state.extra as String? ?? '';
          return OtpVerificationPage(phone: phone);
        },
      ),
      GoRoute(
        path: '/profile_setup',
        name: RouteNames.profileSetup,
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileSetupPage();
        },
      ),
      GoRoute(
        path: '/kyc_upload',
        name: RouteNames.kycUpload,
        builder: (BuildContext context, GoRouterState state) {
          return const KycUploadPage();
        },
      ),
      GoRoute(
        path: '/booking_request/:id',
        name: RouteNames.bookingRequest,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return PlaceholderPage(tabName: 'Booking Request for Item: $id');
        },
      ),
      GoRoute(
        path: '/admin-panel',
        name: RouteNames.adminPanel,
        builder: (BuildContext context, GoRouterState state) {
          return const AdminDashboardPage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'kyc-review',
            name: RouteNames.adminKycReview,
            builder: (BuildContext context, GoRouterState state) {
              return BlocProvider<AdminKycCubit>(
                create: (_) => sl<AdminKycCubit>(),
                child: const AdminKycReviewPage(),
              );
            },
          ),
          GoRoute(
            path: 'user-management',
            name: RouteNames.adminUserManagement,
            builder: (BuildContext context, GoRouterState state) {
              return BlocProvider<AdminUsersCubit>(
                create: (_) => sl<AdminUsersCubit>(),
                child: const AdminUserManagementPage(),
              );
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'homeBranchKey'),
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                name: RouteNames.home,
                builder: (BuildContext context, GoRouterState state) {
                  return const MarketplaceHomePage();
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'item/:id',
                    name: RouteNames.itemDetail,
                    builder: (BuildContext context, GoRouterState state) {
                      final id = state.pathParameters['id'] ?? '';
                      return ItemDetailPage(listingId: id);
                    },
                  ),
                  GoRoute(
                    path: 'map',
                    name: RouteNames.mapPreview,
                    builder: (BuildContext context, GoRouterState state) {
                      return const MapPreviewOverlay();
                    },
                  ),
                  GoRoute(
                    path: 'create-listing',
                    name: RouteNames.createListing,
                    builder: (BuildContext context, GoRouterState state) {
                      return BlocProvider<ListingFormCubit>(
                        create: (_) => sl<ListingFormCubit>(),
                        child: const CreateListingPage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'servicesBranchKey'),
            routes: <RouteBase>[
              GoRoute(
                path: '/home/services',
                name: RouteNames.services,
                builder: (BuildContext context, GoRouterState state) {
                  return const PlaceholderPage(tabName: 'Services');
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'activityBranchKey'),
            routes: <RouteBase>[
              GoRoute(
                path: '/home/activity',
                name: RouteNames.activity,
                builder: (BuildContext context, GoRouterState state) {
                  return const PlaceholderPage(tabName: 'Activity');
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'profileBranchKey'),
            routes: <RouteBase>[
              GoRoute(
                path: '/home/profile',
                name: RouteNames.profile,
                builder: (BuildContext context, GoRouterState state) {
                  return const PlaceholderPage(tabName: 'Profile');
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
