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
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';
import 'package:local_first/features/agreements/presentation/cubits/booking_cubit.dart';
import 'package:local_first/features/agreements/presentation/pages/legal_consent_contract_page.dart';
import 'package:local_first/features/agreements/presentation/pages/owner_request_review_page.dart';
import 'package:local_first/features/agreements/presentation/widgets/booking_schedule_bottom_sheet.dart';
import 'package:local_first/features/agreements/presentation/widgets/whatsapp_redirect_bottom_sheet.dart';
import 'package:local_first/features/agreements/presentation/cubits/agreement_timeline_cubit.dart';
import 'package:local_first/features/agreements/presentation/cubits/transactions_cubit.dart';
import 'package:local_first/features/agreements/presentation/pages/active_agreement_console_page.dart';
import 'package:local_first/features/agreements/presentation/pages/transactions_history_page.dart';
import 'package:local_first/features/services/presentation/cubits/services_cubit.dart';
import 'package:local_first/features/services/presentation/pages/worker_dashboard_page.dart';
import 'package:local_first/features/services/presentation/pages/worker_profile_page.dart';
import 'package:local_first/features/profile/presentation/cubits/profile_hub_cubit.dart';
import 'package:local_first/features/profile/presentation/pages/settings_hub_page.dart';
import 'package:local_first/features/profile/presentation/pages/trust_score_profile_page.dart';


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
                  GoRoute(
                    path: 'booking-schedule',
                    name: RouteNames.bookingSchedule,
                    builder: (BuildContext context, GoRouterState state) {
                      final listing = state.extra as ListingEntity;
                      return BlocProvider<BookingCubit>(
                        create: (_) => sl<BookingCubit>(),
                        child: BookingScheduleBottomSheet(listing: listing),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'legal-consent/:agreementId',
                    name: RouteNames.legalConsent,
                    builder: (BuildContext context, GoRouterState state) {
                      final agreementId = state.pathParameters['agreementId'] ?? '';
                      return BlocProvider<BookingCubit>(
                        create: (_) => sl<BookingCubit>(),
                        child: LegalConsentContractPage(agreementId: agreementId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'request-review/:requestId',
                    name: RouteNames.ownerRequestReview,
                    builder: (BuildContext context, GoRouterState state) {
                      final requestId = state.pathParameters['requestId'] ?? '';
                      final request = state.extra as RequestEntity?;
                      return BlocProvider<BookingCubit>(
                        create: (_) => sl<BookingCubit>(),
                        child: OwnerRequestReviewPage(
                          requestId: requestId,
                          request: request,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'whatsapp-redirect/:requestId',
                    name: RouteNames.whatsappRedirect,
                    builder: (BuildContext context, GoRouterState state) {
                      final requestId = state.pathParameters['requestId'] ?? '';
                      return WhatsAppRedirectBottomSheet(requestId: requestId);
                    },
                  ),
                  GoRoute(
                    path: 'agreement/:id',
                    name: RouteNames.agreementConsole,
                    builder: (BuildContext context, GoRouterState state) {
                      final agreementId = state.pathParameters['id'] ?? '';
                      return BlocProvider<AgreementTimelineCubit>(
                        create: (_) => sl<AgreementTimelineCubit>()..listenAgreement(agreementId),
                        child: ActiveAgreementConsolePage(agreementId: agreementId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'worker/:id',
                    name: RouteNames.workerProfile,
                    builder: (BuildContext context, GoRouterState state) {
                      final id = state.pathParameters['id'] ?? '';
                      return BlocProvider<ServicesCubit>(
                        create: (_) => sl<ServicesCubit>(),
                        child: WorkerProfilePage(workerId: id),
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
                  return BlocProvider<ServicesCubit>(
                    create: (_) => sl<ServicesCubit>(),
                    child: const WorkerDashboardPage(),
                  );
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
                  return BlocProvider<TransactionsCubit>(
                    create: (_) => sl<TransactionsCubit>()..loadAgreements(),
                    child: const TransactionsHistoryPage(),
                  );
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
                  return BlocProvider<ProfileHubCubit>(
                    create: (_) => sl<ProfileHubCubit>(),
                    child: const SettingsHubPage(),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'trust',
                    name: RouteNames.trustProfile,
                    builder: (BuildContext context, GoRouterState state) {
                      return BlocProvider<ProfileHubCubit>(
                        create: (_) => sl<ProfileHubCubit>(),
                        child: const TrustScoreProfilePage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

