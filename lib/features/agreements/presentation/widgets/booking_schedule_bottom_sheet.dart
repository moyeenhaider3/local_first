import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/agreements/presentation/cubits/booking_cubit.dart';

/// BKG-01 Booking Schedule Selection & Cost Breakdown page/sheet.
class BookingScheduleBottomSheet extends StatefulWidget {
  final ListingEntity listing;

  const BookingScheduleBottomSheet({
    super.key,
    required this.listing,
  });

  @override
  State<BookingScheduleBottomSheet> createState() => _BookingScheduleBottomSheetState();
}

class _BookingScheduleBottomSheetState extends State<BookingScheduleBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _startDate ?? now;
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: DesignTokens.colorPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // If end date is before or equal to start date, clear it
        if (_endDate != null && !_endDate!.isAfter(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date first.'),
          backgroundColor: DesignTokens.colorWarning,
        ),
      );
      return;
    }

    final DateTime initialDate = _endDate ?? _startDate!.add(const Duration(days: 1));
    final DateTime firstDate = _startDate!.add(const Duration(days: 1));
    final DateTime lastDate = _startDate!.add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: DesignTokens.colorPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final double pricePerDay = widget.listing.pricePerDay ?? widget.listing.startingRate ?? 0.0;
    final double securityDeposit = widget.listing.securityDeposit ?? 0.0;

    int durationDays = 0;
    double rentalCharge = 0.0;
    double totalAmount = 0.0;

    if (_startDate != null && _endDate != null) {
      final diff = _endDate!.difference(_startDate!).inDays;
      durationDays = diff <= 0 ? 1 : diff;
      rentalCharge = pricePerDay * durationDays;
      totalAmount = rentalCharge + securityDeposit;
    }

    final bool isSelectionValid = _startDate != null && _endDate != null && _endDate!.isAfter(_startDate!);

    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.secondary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Setup Booking Dates',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Drag handle look-alike at the top of sheet content
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: spacing.edgeMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + daily price label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking Period',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${pricePerDay.toStringAsFixed(0)}/day',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.space16),

                  // Start/End date pickers in two InkWell boxes
                  Row(
                    children: [
                      // Start Date Box
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartDate(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _startDate != null ? dateFormat.format(_startDate!) : 'Start Date',
                                    style: _startDate != null
                                        ? theme.textTheme.bodyLarge
                                        : theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.calendar_month, size: 18, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // End Date Box
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndDate(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _endDate != null ? dateFormat.format(_endDate!) : 'End Date',
                                    style: _endDate != null
                                        ? theme.textTheme.bodyLarge
                                        : theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.calendar_month, size: 18, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.space24),

                  // Damage liability warning card (non-dismissible)
                  Container(
                    decoration: BoxDecoration(
                      color: DesignTokens.colorWarning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'IMPORTANT: You are contractually liable for any damage to this item. Entering handover codes confirms you received it in working condition.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.space24),

                  // Pricing Summary Card (only visible when dates selected)
                  if (isSelectionValid) ...[
                    Text(
                      'Cost Breakdown',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing.space8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Daily rate', style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF64748B))),
                              Text('₹${pricePerDay.toStringAsFixed(2)}', style: theme.textTheme.bodyLarge),
                            ],
                          ),
                          SizedBox(height: spacing.space8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Duration', style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF64748B))),
                              Text('$durationDays days', style: theme.textTheme.bodyLarge),
                            ],
                          ),
                          SizedBox(height: spacing.space8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rental charge', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                              Text('₹${rentalCharge.toStringAsFixed(2)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          SizedBox(height: spacing.space8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Security deposit', style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF64748B))),
                              Text('₹${securityDeposit.toStringAsFixed(2)}', style: theme.textTheme.bodyLarge),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Color(0xFFE2E8F0)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${totalAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.space24),
                  ],
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
                onPressed: isSelectionValid
                    ? () {
                        context.read<BookingCubit>().calculateRates(
                              pricePerDay: pricePerDay,
                              securityDeposit: securityDeposit,
                              startDate: _startDate!,
                              endDate: _endDate!,
                            );
                        
                        final extraData = {
                          'listing': widget.listing,
                          'startDate': _startDate,
                          'endDate': _endDate,
                          'dailyRate': pricePerDay,
                          'depositAmount': securityDeposit,
                          'durationDays': durationDays,
                          'totalAmount': rentalCharge,
                        };

                        context.pushNamed(
                          RouteNames.legalConsent,
                          pathParameters: {'agreementId': 'new'},
                          extra: extraData,
                        );
                      }
                    : null,
                child: const Text('GO TO AGREEMENT SIGNING'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
