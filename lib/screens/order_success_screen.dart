import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'orders_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderModel? order;

  const OrderSuccessScreen({super.key, this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  int _secondsLeft = 599; // 9 mins 59 secs
  Timer? _timer;
  int _currentStep = 2; // Starts at 'Rider Assigned' by default for express dispatch
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  final List<Map<String, String>> _deliveryStages = [
    {
      'title': 'Order Confirmed',
      'subtitle': 'Store received your order & generated invoice',
      'status': 'Order Confirmed',
      'riderText': 'Assigning nearest partner... • Dark Store',
    },
    {
      'title': 'Items Picked & Packed',
      'subtitle': 'Fresh dairy and grocery checked by store manager',
      'status': 'Items Picked & Packed',
      'riderText': 'Vikram Singh • Packing fresh items at dark store',
    },
    {
      'title': 'Rider Assigned',
      'subtitle': 'Vikram picked up items from local dark store',
      'status': 'Rider Assigned',
      'riderText': 'Delivery Partner • 0.8 km away',
    },
    {
      'title': 'Out for Express Delivery',
      'subtitle': 'On the way to your door (ETA 8 mins)',
      'status': 'Out for Express Delivery',
      'riderText': 'Delivery Partner • 0.3 km away (Approaching building)',
    },
    {
      'title': 'Delivered to Doorstep!',
      'subtitle': 'Enjoy your fresh order! Rated 5★ on time',
      'status': 'Delivered',
      'riderText': 'Delivery Partner • Handed over safely at door 🎉',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initInitialStep();
    _startTimer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initInitialStep() {
    final status = widget.order?.status ?? '';
    if (status.contains('Delivered')) {
      _currentStep = 4;
      _secondsLeft = 0;
    } else if (status.contains('Out for Express') || status.contains('Out for Delivery')) {
      _currentStep = 3;
      _secondsLeft = 320;
    } else if (status.contains('Rider Assigned')) {
      _currentStep = 2;
      _secondsLeft = 590;
    } else if (status.contains('Packed')) {
      _currentStep = 1;
      _secondsLeft = 595;
    } else {
      _currentStep = 2; // Default active step
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          // Automatically advance stages as timer progresses
          if (_secondsLeft == 300 && _currentStep < 3) {
            _advanceStep(isAuto: true, targetStep: 3);
          } else if (_secondsLeft == 0 && _currentStep < 4) {
            _advanceStep(isAuto: true, targetStep: 4);
          }
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _advanceStep({bool isAuto = false, int? targetStep}) {
    final newStep = targetStep ?? (_currentStep + 1) % _deliveryStages.length;
    setState(() {
      _currentStep = newStep;
      if (_currentStep == 4) {
        _secondsLeft = 0;
      }
    });

    final newStatus = _deliveryStages[_currentStep]['status'] ?? 'In Progress';
    _syncStatusToFirebase(newStatus);

    if (!isAuto && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.sync_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Updated to "${_deliveryStages[_currentStep]['title']}" (Synced to Firebase)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _syncStatusToFirebase(String newStatus) {
    final order = widget.order;
    if (order != null) {
      context.read<OrderProvider>().updateOrderStatus(
            order.orderId,
            order.userId,
            newStatus,
          );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final orderId = order?.orderId ?? 'ATB-998241';
    final deliveryAddress = order?.deliveryAddress ??
        'Flat 402, Green Park Heights, Cyber City';

    final isDelivered = _currentStep == 4;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: _goHome,
        ),
        title: const Text(
          'Live Delivery Tracking',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
            children: [
              // Success Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isDelivered ? Icons.celebration_rounded : Icons.check_circle_rounded,
                  color: AppColors.primaryGreen,
                  size: 56,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              // Order ID badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ORDER ID: #$orderId',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Saved in Firebase & Offline Storage Confirmation Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_done_rounded, color: AppColors.primaryGreen, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Details Saved to Firebase & Local Storage',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Countdown Delivery Timer Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDelivered
                        ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)]
                        : [const Color(0xFFFFFBEA), const Color(0xFFFFF3CD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDelivered ? AppColors.primaryGreen : AppColors.primaryYellow,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDelivered ? AppColors.primaryGreen : AppColors.primaryYellow)
                          .withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDelivered ? AppColors.primaryGreen : Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDelivered ? Icons.check_rounded : Icons.bolt_rounded,
                            color: isDelivered ? Colors.white : AppColors.primaryYellow,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDelivered
                              ? 'PACKAGE DELIVERED TO YOU'
                              : 'ARRIVING AT YOUR DOOR IN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: isDelivered ? AppColors.primaryGreen : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isDelivered ? '00:00' : _formatTime(_secondsLeft),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: isDelivered ? AppColors.primaryGreen : AppColors.primaryGreen,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Delivering to: $deliveryAddress',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Rider Assignment Card (dynamically updates with stage)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isDelivered ? AppColors.lightGreen : AppColors.primaryYellow,
                      child: Icon(
                        isDelivered ? Icons.thumb_up_rounded : Icons.two_wheeler_rounded,
                        color: isDelivered ? AppColors.primaryGreen : Colors.black,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vikram Singh',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _deliveryStages[_currentStep]['riderText'] ??
                                'Delivery Partner • 0.8 km away',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Calling delivery partner Vikram Singh (+91 98765 43210)...'),
                            backgroundColor: AppColors.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.lightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone_rounded,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Items Summary (if available)
              if (order != null && order.items.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Items (${order.items.length})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Paid: ₹${order.grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '₹${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Dynamic Phased Delivery Stepper Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Live Delivery Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Stage ${_currentStep + 1} of ${_deliveryStages.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(_deliveryStages.length, (index) {
                      final stage = _deliveryStages[index];
                      final isCompleted = index < _currentStep;
                      final isActive = index == _currentStep;
                      final isLast = index == _deliveryStages.length - 1;

                      return _buildDynamicStepRow(
                        title: stage['title'] ?? '',
                        subtitle: stage['subtitle'] ?? '',
                        isCompleted: isCompleted,
                        isActive: isActive,
                        isLast: isLast,
                      );
                    }),
                    const SizedBox(height: 8),
                    // Simulation trigger for live testing & interactive demo
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => _advanceStep(),
                        icon: const Icon(Icons.fast_forward_rounded, size: 16),
                        label: Text(
                          _currentStep < _deliveryStages.length - 1
                              ? 'Simulate Next Stage ⚡'
                              : 'Restart Delivery Simulation ↺',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded, size: 20),
                label: const Text(
                  'View in My Orders (Firebase)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _goHome,
                child: const Text(
                  'Back to Home Store',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildDynamicStepRow({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    Color indicatorColor;
    if (isCompleted) {
      indicatorColor = AppColors.primaryGreen;
    } else if (isActive) {
      indicatorColor = AppColors.primaryGreen;
    } else {
      indicatorColor = Colors.grey.shade300;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (isActive)
              ScaleTransition(
                scale: _pulseScale,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen,
                  ),
                  child: const Icon(
                    Icons.directions_bike_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indicatorColor,
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle,
                  size: 14,
                  color: isCompleted ? Colors.white : Colors.grey.shade400,
                ),
              ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isCompleted ? AppColors.primaryGreen : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: (isCompleted || isActive)
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: (isCompleted || isActive)
                      ? AppColors.textSecondary
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
