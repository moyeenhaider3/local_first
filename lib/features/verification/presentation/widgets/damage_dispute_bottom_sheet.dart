import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_cubit.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_state.dart';

/// A bottom sheet for raising damage disputes and reporting issues on item return.
///
/// Features issue type radio selections, detailed descriptions, photo evidence upload,
/// and downloading verification packages.
class DamageDisputeBottomSheet extends StatefulWidget {
  /// The ID of the agreement under dispute.
  final String agreementId;

  /// Creates a [DamageDisputeBottomSheet].
  const DamageDisputeBottomSheet({
    super.key,
    required this.agreementId,
  });

  /// Displays the damage dispute bottom sheet.
  static Future<void> show(BuildContext context, {required String agreementId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DamageDisputeBottomSheet(agreementId: agreementId),
    );
  }

  @override
  State<DamageDisputeBottomSheet> createState() => _DamageDisputeBottomSheetState();
}

class _DamageDisputeBottomSheetState extends State<DamageDisputeBottomSheet> {
  /// Dispute types / categories.
  final List<String> _disputeTypes = const [
    'Item returned damaged / not working',
    'Renter did not return the item',
    'Unpaid rental balances or outstanding dues',
  ];

  /// The currently selected dispute type.
  String? _selectedDisputeType;

  /// Text controller for the detailed dispute description.
  final TextEditingController _descriptionController = TextEditingController();

  /// Image files picked for the dispute (max 3 slots).
  final List<File?> _images = List.filled(3, null);

  /// Tracks whether a dispute has been successfully submitted during this sheet's lifetime.
  bool _isSubmitted = false;

  /// Tracks whether evidence package download is currently in progress.
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Whether the input fields satisfy submission criteria (type selected and desc >= 15 chars).
  bool get _canSubmit =>
      _selectedDisputeType != null &&
      _descriptionController.text.trim().length >= 15;

  /// Picks a photograph using the device's camera for the specified [index].
  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _images[index] = File(picked.path);
      });
    }
  }

  /// Removes the uploaded photograph at the specified [index].
  void _removeImage(int index) {
    setState(() {
      _images[index] = null;
    });
  }

  /// Initiates downloading of the evidence package (calling generateEvidencePackage Cloud Function).
  Future<void> _downloadEvidence() async {
    setState(() {
      _isDownloading = true;
    });
    try {
      final functions = sl<FirebaseFunctions>();
      final result = await functions
          .httpsCallable('generateEvidencePackage')
          .call({'agreementId': widget.agreementId});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Contract downloaded successfully. Package URL: ${result.data}',
          ),
          backgroundColor: DesignTokens.colorSuccess,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: DesignTokens.colorDanger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nonNullImages = _images.whereType<File>().toList();

    return BlocProvider<VerificationCubit>(
      create: (context) => sl<VerificationCubit>(),
      child: Container(
        decoration: const BoxDecoration(
          color: DesignTokens.colorSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        padding: EdgeInsets.only(
          left: DesignTokens.kEdgeMargin,
          right: DesignTokens.kEdgeMargin,
          top: DesignTokens.kSpace8,
          bottom: MediaQuery.of(context).viewInsets.bottom + DesignTokens.kSpace24,
        ),
        child: BlocListener<VerificationCubit, VerificationState>(
          listener: (context, state) {
            if (state is DisputeSuccess) {
              setState(() {
                _isSubmitted = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dispute submitted successfully.'),
                  backgroundColor: DesignTokens.colorSuccess,
                ),
              );
            } else if (state is VerificationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: DesignTokens.colorDanger,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace8),
                Text(
                  'Report Return Damage / Issues',
                  style: DesignTokens.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignTokens.kSpace16),

                // Radio options for dispute types
                ..._disputeTypes.map((type) {
                  return Container(
                    constraints:
                        const BoxConstraints(minHeight: DesignTokens.kTouchMin),
                    // ignore: deprecated_member_use
                    child: RadioListTile<String>(
                      value: type,
                      // ignore: deprecated_member_use
                      groupValue: _selectedDisputeType,
                      title: Text(
                        type,
                        style: DesignTokens.bodyLarge,
                      ),
                      activeColor: DesignTokens.colorPrimary,
                      contentPadding: EdgeInsets.zero,
                      // ignore: deprecated_member_use
                      onChanged: _isSubmitted
                          ? null
                          : (value) {
                              setState(() {
                                _selectedDisputeType = value;
                              });
                            },
                    ),
                  );
                }),

                const SizedBox(height: DesignTokens.kSpace16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isSubmitted,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe damage details...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: DesignTokens.colorPrimary,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12.0),
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace16),

                // Photo upload row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) {
                    final file = _images[index];
                    return GestureDetector(
                      onTap: _isSubmitted ? null : () => _pickImage(index),
                      child: Container(
                        width: 72.0,
                        height: 72.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: file != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                      width: 72.0,
                                      height: 72.0,
                                    ),
                                  ),
                                  if (!_isSubmitted)
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(2.0),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : const Center(
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Color(0xFF64748B),
                                  size: 24.0,
                                ),
                              ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: DesignTokens.kSpace24),

                // Submit dispute button
                Builder(
                  builder: (context) {
                    final state = context.watch<VerificationCubit>().state;
                    final isLoading = state is DisputeSubmitting;

                    return SizedBox(
                      height: 52.0,
                      child: ElevatedButton(
                        onPressed: _canSubmit && !isLoading && !_isSubmitted
                            ? () {
                                context.read<VerificationCubit>().submitDispute(
                                      agreementId: widget.agreementId,
                                      disputeType: _selectedDisputeType!,
                                      description:
                                          _descriptionController.text.trim(),
                                      imageFiles: nonNullImages,
                                    );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.colorDanger,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24.0,
                                height: 24.0,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text(
                                'SUBMIT DISPUTE & REPORT ISSUE',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: DesignTokens.kSpace16),

                // Download contract button
                SizedBox(
                  height: 52.0,
                  child: OutlinedButton(
                    onPressed: _isSubmitted && !_isDownloading
                        ? _downloadEvidence
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      disabledForegroundColor: Colors.grey[400],
                      side: BorderSide(
                        color: _isSubmitted ? Colors.black : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isDownloading
                        ? const SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text(
                            'DOWNLOAD CONTRACT & RENTER ID',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
