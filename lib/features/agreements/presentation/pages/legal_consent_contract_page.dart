import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/contracts/standard_rental_contract_template.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';
import 'package:local_first/features/agreements/domain/entities/signature_metadata_entity.dart';
import 'package:local_first/features/agreements/domain/repositories/agreement_repository.dart';
import 'package:local_first/features/agreements/presentation/cubits/booking_cubit.dart';
import 'package:local_first/features/agreements/presentation/cubits/booking_state.dart';

/// BKG-02 Legal Consent Contract signing/submission page.
class LegalConsentContractPage extends StatefulWidget {
  final String agreementId;

  const LegalConsentContractPage({
    super.key,
    required this.agreementId,
  });

  @override
  State<LegalConsentContractPage> createState() => _LegalConsentContractPageState();
}

class _LegalConsentContractPageState extends State<LegalConsentContractPage> {
  late Future<Map<String, dynamic>> _loadFuture;

  // Checkbox states
  bool _checkbox1 = false;
  bool _checkbox2 = false;
  bool _checkbox3 = false;

  final TextEditingController _nameController = TextEditingController();
  bool _isSignatureValid = false;
  String _expectedName = '';

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadDetails();
    _initExpectedName();
    _nameController.addListener(_validateSignature);
  }

  void _initExpectedName() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      _expectedName = authState.userEntity?.displayName ?? '';
    }
  }

  void _validateSignature() {
    setState(() {
      _isSignatureValid = _nameController.text.trim().toLowerCase() == _expectedName.trim().toLowerCase();
    });
  }

  Future<Map<String, dynamic>> _loadDetails() async {
    if (widget.agreementId == 'new') {
      return {};
    }

    final agreementResult = await sl<AgreementRepository>().getAgreement(widget.agreementId);
    final agreement = agreementResult.fold(
      (failure) => throw Exception(failure.message),
      (ag) => ag,
    );

    final renterResult = await sl<AuthRepository>().getUser(agreement.initiatorId);
    final renterName = renterResult.fold(
      (_) => 'Renter',
      (user) => user?.displayName ?? 'Renter',
    );

    final ownerResult = await sl<AuthRepository>().getUser(agreement.counterpartyId);
    final ownerName = ownerResult.fold(
      (_) => 'Owner',
      (user) => user?.displayName ?? 'Owner',
    );

    return {
      'agreement': agreement,
      'renterName': renterName,
      'ownerName': ownerName,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit(
    BuildContext context, {
    required bool isNew,
    Map<String, dynamic>? extraData,
    AgreementEntity? agreement,
    String? renterName,
    String? ownerName,
  }) {
    if (isNew) {
      // Renter submitting request
      final listing = extraData!['listing'] as ListingEntity;
      final startDate = extraData['startDate'] as DateTime;
      final endDate = extraData['endDate'] as DateTime;
      final depositAmount = extraData['depositAmount'] as double;
      final durationDays = extraData['durationDays'] as int;
      final totalAmount = extraData['totalAmount'] as double;

      final authState = context.read<AuthCubit>().state as AuthSuccess;

      final request = RequestEntity(
        id: '', // Cloud function will generate
        listingId: listing.id,
        listingTitle: listing.title,
        requesterId: authState.uid,
        receiverId: listing.ownerId,
        requestType: RequestType.rental,
        status: RequestStatus.sent,
        proposedStartDate: startDate,
        proposedEndDate: endDate,
        proposedDurationDays: durationDays,
        estimatedTotal: totalAmount,
        estimatedDeposit: depositAmount,
        message: '',
        expiresAt: DateTime.now().add(const Duration(hours: 48)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<BookingCubit>().sendBookingRequest(request);
    } else {
      // Signing formal draft agreement
      final authState = context.read<AuthCubit>().state as AuthSuccess;
      final signature = SignatureMetadataEntity(
        fullName: _nameController.text.trim(),
        phone: authState.userEntity?.phone ?? '',
        timestamp: DateTime.now(),
        kycSnapshotRef: authState.userEntity?.kycDocumentUrl,
        deviceInfo: 'Flutter Device',
        appVersion: '1.0.0',
      );

      context.read<BookingCubit>().signBookingAgreement(widget.agreementId, signature);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final isNew = widget.agreementId == 'new';

    // Extract extra navigation parameters if in request preview mode
    Map<String, dynamic>? extraData;
    if (isNew) {
      final state = GoRouterState.of(context);
      extraData = state.extra as Map<String, dynamic>?;
    }

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else if (state is RequestSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rental request submitted successfully!'),
              backgroundColor: DesignTokens.colorSuccess,
            ),
          );
          // Navigate to home / activity list
          context.goNamed(RouteNames.home);
        } else if (state is ContractSignedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contract signed and recorded successfully!'),
              backgroundColor: DesignTokens.colorSuccess,
            ),
          );
          // Navigate to activity tab
          context.goNamed(RouteNames.activity);
        }
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (!isNew && snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!isNew && snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text('Error loading contract: ${snapshot.error}'),
              ),
            );
          }

          // Variables for rendering
          String itemName = '';
          String ownerName = '';
          String renterName = '';
          double dailyRate = 0.0;
          double depositAmount = 0.0;
          int durationDays = 0;
          DateTime startDate = DateTime.now();

          if (isNew) {
            if (extraData == null) {
              return Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: Text('Error: missing booking data.'),
                ),
              );
            }
            final listing = extraData['listing'] as ListingEntity;
            itemName = listing.title;
            ownerName = listing.ownerDisplayName;
            renterName = _expectedName;
            dailyRate = extraData['dailyRate'] as double;
            depositAmount = extraData['depositAmount'] as double;
            durationDays = extraData['durationDays'] as int;
            startDate = extraData['startDate'] as DateTime;
          } else {
            final data = snapshot.data!;
            final agreement = data['agreement'] as AgreementEntity;
            itemName = agreement.listingTitle;
            ownerName = data['ownerName'] as String;
            renterName = data['renterName'] as String;
            dailyRate = agreement.dailyRate;
            depositAmount = agreement.depositAmount;
            durationDays = agreement.durationDays;
            startDate = agreement.startDate;
          }

          final String legalText = StandardRentalContractTemplate.generateLegalText(
            ownerName: ownerName,
            renterName: renterName,
            itemName: itemName,
            dailyRate: dailyRate,
            securityDeposit: depositAmount,
            durationDays: durationDays,
            startDate: startDate,
          );

          final bool isButtonEnabled = _checkbox1 && _checkbox2 && _checkbox3 && _isSignatureValid;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Rental Agreement Consent',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                final bool isLoading = state is RequestSending || state is SigningInProgress || state is BookingLoading;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(spacing.edgeMargin),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Contract version subtitle
                            Text(
                              'Agreement Version: ${StandardRentalContractTemplate.contractVersion}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: spacing.space16),

                            // Scrollable contract box
                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    legalText,
                                    style: const TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 12,
                                      color: Color(0xFF1E293B),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.space24),

                            // Checkboxes list (48dp height rows)
                            // Checkbox 1
                            SizedBox(
                              height: 48,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _checkbox1,
                                    onChanged: isLoading
                                        ? null
                                        : (val) {
                                            setState(() {
                                              _checkbox1 = val ?? false;
                                            });
                                          },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'I have read and agree to the rental terms.',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Checkbox 2
                            SizedBox(
                              height: 48,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _checkbox2,
                                    onChanged: isLoading
                                        ? null
                                        : (val) {
                                            setState(() {
                                              _checkbox2 = val ?? false;
                                            });
                                          },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'I understand I am legally responsible for any damage caused during this rental.',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Checkbox 3
                            SizedBox(
                              height: 48,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _checkbox3,
                                    onChanged: isLoading
                                        ? null
                                        : (val) {
                                            setState(() {
                                              _checkbox3 = val ?? false;
                                            });
                                          },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'I authorize the platform to release my verified identity details to the owner if damages are disputed.',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.space24),

                            // Legal name signature field
                            TextFormField(
                              controller: _nameController,
                              enabled: !isLoading,
                              decoration: InputDecoration(
                                labelText: 'Type your full legal name to sign',
                                hintText: _expectedName,
                                border: const OutlineInputBorder(),
                                helperText: 'Must exactly match: $_expectedName',
                                helperStyle: TextStyle(
                                  color: _isSignatureValid ? DesignTokens.colorSuccess : const Color(0xFF64748B),
                                ),
                              ),
                              style: theme.textTheme.bodyLarge,
                            ),
                            SizedBox(height: spacing.space16),
                          ],
                        ),
                      ),
                    ),

                    // Sticky Button Panel
                    Container(
                      color: theme.colorScheme.surface,
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.edgeMargin,
                        vertical: spacing.space16,
                      ),
                      child: SafeArea(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          onPressed: isButtonEnabled && !isLoading
                              ? () => _handleSubmit(
                                    context,
                                    isNew: isNew,
                                    extraData: extraData,
                                    agreement: snapshot.data?['agreement'],
                                    renterName: renterName,
                                    ownerName: ownerName,
                                  )
                              : null,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(isNew ? 'SUBMIT RENTAL REQUEST' : 'SIGN & SUBMIT CONSOLIDATED TERMS'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
