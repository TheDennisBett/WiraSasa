import 'package:flutter/material.dart';
import 'package:wirasasa/app/app_router.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/core/utils/mock_data.dart';
import 'package:wirasasa/features/provider_profile/presentation/models/provider_profile_arguments.dart';

class MapDiscoveryScreen extends StatefulWidget {
  const MapDiscoveryScreen({
    super.key,
    required this.serviceType,
    this.scheduledDateTime,
    this.initialQuery,
  });

  final String serviceType;
  final DateTime? scheduledDateTime;
  final String? initialQuery;

  @override
  State<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends State<MapDiscoveryScreen> {
  late final TextEditingController _controller;
  late String _query;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? widget.serviceType;
    _controller = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = MockData.providers.where((provider) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) {
        return provider.service == widget.serviceType;
      }
      return provider.service.toLowerCase().contains(query) ||
          provider.name.toLowerCase().contains(query);
    }).toList();
    final visibleProviders = providers.isEmpty
        ? MockData.providers
              .where((provider) => provider.service == widget.serviceType)
              .toList()
        : providers;

    return Scaffold(
      body: Stack(
        children: [
          const _MapBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: AppColors.green,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  onChanged: (value) =>
                                      setState(() => _query = value),
                                  decoration: const InputDecoration(
                                    hintText: 'Which service do you need?',
                                    border: InputBorder.none,
                                    filled: false,
                                    isCollapsed: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          _MarkerLayer(providers: visibleProviders),
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.36,
            maxChildSize: 0.78,
            builder: (context, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Available Providers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.scheduledDateTime == null
                          ? 'Instant booking'
                          : 'Scheduled • ${_formatBookingDateTime(widget.scheduledDateTime!)}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...visibleProviders.map(
                      (provider) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProviderListCard(
                          provider: provider,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.providerProfile,
                            arguments: ProviderProfileArguments(
                              provider: provider,
                              serviceType: widget.serviceType,
                              scheduledDateTime: widget.scheduledDateTime,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MapBackdrop extends StatelessWidget {
  const _MapBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FB),
      child: Stack(
        children: [
          for (final label in const [
            ('Sarit Centre', 80.0, 110.0),
            ('Westgate Mall', 180.0, 135.0),
            ('Village Market', 330.0, 145.0),
            ('Muthaiga', 390.0, 165.0),
            ('Westlands', 150.0, 260.0),
            ('Mugo Rd', 255.0, 375.0),
          ])
            Positioned(
              left: label.$2,
              top: label.$3,
              child: Text(
                label.$1,
                style: const TextStyle(
                  color: Color(0xFF4D73C3),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Positioned.fill(child: CustomPaint(painter: _StreetPainter())),
        ],
      ),
    );
  }
}

class _StreetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFE7E8ED)
      ..strokeWidth = 6;
    final buildingsPaint = Paint()..color = const Color(0xFFF0F0F2);

    for (double x = 40; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
    for (double y = 80; y < size.height; y += 70) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    for (double x = 30; x < size.width; x += 80) {
      for (double y = 40; y < size.height; y += 90) {
        canvas.drawRect(Rect.fromLTWH(x, y, 34, 38), buildingsPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MarkerLayer extends StatelessWidget {
  const _MarkerLayer({required this.providers});

  final List<ProviderPreview> providers;

  @override
  Widget build(BuildContext context) {
    final positions = [
      const Offset(240, 250),
      const Offset(200, 300),
      const Offset(160, 340),
      const Offset(275, 220),
    ];
    return Stack(
      children: [
        for (
          int index = 0;
          index < providers.length && index < positions.length;
          index++
        )
          Positioned(
            left: positions[index].dx,
            top: positions[index].dy,
            child: _MapMarker(initials: providers[index].initials),
          ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.green,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProviderListCard extends StatelessWidget {
  const _ProviderListCard({required this.provider, required this.onTap});

  final ProviderPreview provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  provider.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⭐ ${provider.rating} • ${provider.jobs} jobs • ${provider.eta.replaceAll(' ETA', '')} • KES${provider.pricePerHour}/hr',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatBookingDateTime(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final period = value.hour < 12 ? 'AM' : 'PM';
  final minute = value.minute.toString().padLeft(2, '0');
  return '${months[value.month - 1]} ${value.day}, ${value.year} • $hour:$minute $period';
}
