import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wirasasa/app/app_router.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/core/utils/mock_data.dart';
import 'package:wirasasa/features/service_request/presentation/providers/booking_flow_provider.dart';
import 'package:wirasasa/shared_widgets/primary_button.dart';

const LatLng _clientLocation = LatLng(-1.2600, 36.8040);

class ProviderProfileScreen extends ConsumerWidget {
  const ProviderProfileScreen({
    super.key,
    this.provider,
    this.serviceType,
    this.scheduledDateTime,
  });

  final ProviderPreview? provider;
  final String? serviceType;
  final DateTime? scheduledDateTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = provider ?? MockData.providers.first;
    final bookingFlow = ref.watch(bookingFlowProvider);
    final activeSchedule = scheduledDateTime ?? bookingFlow.scheduledDateTime;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _ProfileTrackingMap(provider: item)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topLeft,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.verified_user_outlined,
                                  color: AppColors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '⭐ ${item.rating} • ${item.jobs} jobs',
                              style: const TextStyle(
                                color: AppColors.slate,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _InfoColumn(
                                title: 'Service',
                                value: serviceType ?? item.service,
                              ),
                            ),
                            _InfoColumn(
                              title: 'Hourly Rate',
                              value: 'KES${item.pricePerHour}/hr',
                              valueColor: AppColors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${item.distance} • ${item.eta}',
                                style: const TextStyle(
                                  color: AppColors.slate,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.route_rounded,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Live route preview is locked to ${item.name}.',
                                style: const TextStyle(
                                  color: AppColors.slate,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (activeSchedule != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Scheduled for ${_formatSchedule(activeSchedule)}',
                                  style: const TextStyle(
                                    color: AppColors.slate,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Request Service',
                    onPressed: () {
                      ref.read(bookingFlowProvider.notifier).selectProvider(item);
                      if (activeSchedule != null) {
                        ref
                            .read(bookingFlowProvider.notifier)
                            .setSchedule(activeSchedule);
                      }
                      Navigator.pushNamed(context, AppRouter.serviceRequest);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                            side: const BorderSide(color: AppColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('Chat'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                            side: const BorderSide(color: AppColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.call_outlined),
                          label: const Text('Call'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Reviews',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  _ReviewTile(name: 'Emily P.', review: item.review),
                  const SizedBox(height: 12),
                  const _ReviewTile(
                    name: 'James K.',
                    review:
                        'Responsive, respectful, and did the work without delays.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTrackingMap extends StatefulWidget {
  const _ProfileTrackingMap({required this.provider});

  final ProviderPreview provider;

  @override
  State<_ProfileTrackingMap> createState() => _ProfileTrackingMapState();
}

class _ProfileTrackingMapState extends State<_ProfileTrackingMap> {
  GoogleMapController? _controller;
  Timer? _timer;
  late final List<LatLng> _trackingPath;
  int _trackingIndex = 0;

  @override
  void initState() {
    super.initState();
    _trackingPath = _buildTrackingPath(widget.provider);
    if (_supportsGoogleMaps) {
      _timer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _trackingIndex = (_trackingIndex + 1) % _trackingPath.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsGoogleMaps) {
      return _UnsupportedMapFallback(
        title: widget.provider.name,
        subtitle: 'Google Maps is enabled for Android and iOS builds.',
      );
    }

    final providerPosition = _trackingPath[_trackingIndex];
    final markers = {
      Marker(
        markerId: const MarkerId('client'),
        position: _clientLocation,
        infoWindow: const InfoWindow(title: 'Client'),
        icon: _markerIcon(isClient: true),
      ),
      Marker(
        markerId: const MarkerId('provider'),
        position: providerPosition,
        infoWindow: InfoWindow(title: widget.provider.name),
        icon: _markerIcon(isClient: false),
      ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          (_clientLocation.latitude + widget.provider.latitude) / 2,
          (_clientLocation.longitude + widget.provider.longitude) / 2,
        ),
        zoom: 13.8,
      ),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
        _fitBounds();
      },
      polylines: {
        Polyline(
          polylineId: const PolylineId('provider-route'),
          points: _trackingPath,
          width: 5,
          color: AppColors.green,
        ),
      },
      markers: markers,
    );
  }

  Future<void> _fitBounds() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final points = [_clientLocation, widget.provider.location];
    final south = points
        .map((point) => point.latitude)
        .reduce((value, element) => value < element ? value : element);
    final north = points
        .map((point) => point.latitude)
        .reduce((value, element) => value > element ? value : element);
    final west = points
        .map((point) => point.longitude)
        .reduce((value, element) => value < element ? value : element);
    final east = points
        .map((point) => point.longitude)
        .reduce((value, element) => value > element ? value : element);

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        64,
      ),
    );
  }
}

class _UnsupportedMapFallback extends StatelessWidget {
  const _UnsupportedMapFallback({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF5EE), Color(0xFFF7F7F8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 72, color: AppColors.green),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.slate, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.title,
    required this.value,
    this.valueColor = AppColors.ink,
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.name, required this.review});

  final String name;
  final String review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            const Text('⭐⭐⭐⭐⭐'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          review,
          style: const TextStyle(color: AppColors.slate, height: 1.4),
        ),
      ],
    );
  }
}

List<LatLng> _buildTrackingPath(ProviderPreview provider) {
  return [
    provider.location,
    LatLng(provider.latitude - 0.0012, provider.longitude - 0.0018),
    LatLng(provider.latitude - 0.0024, provider.longitude - 0.0034),
    LatLng(provider.latitude - 0.0030, provider.longitude - 0.0048),
    _clientLocation,
  ];
}

String _formatSchedule(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final period = value.hour < 12 ? 'AM' : 'PM';
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} • $hour:$minute $period';
}

extension on ProviderPreview {
  LatLng get location => LatLng(latitude, longitude);
}

BitmapDescriptor _markerIcon({required bool isClient}) {
  if (kIsWeb) {
    return BitmapDescriptor.defaultMarker;
  }
  return BitmapDescriptor.defaultMarkerWithHue(
    isClient ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueGreen,
  );
}

bool get _supportsGoogleMaps {
  if (kIsWeb) {
    return const bool.fromEnvironment('ENABLE_WEB_GOOGLE_MAPS');
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => true,
    TargetPlatform.iOS => true,
    _ => false,
  };
}
