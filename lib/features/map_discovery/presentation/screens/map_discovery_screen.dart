import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wirasasa/app/app_router.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/core/utils/mock_data.dart';
import 'package:wirasasa/features/provider_profile/presentation/models/provider_profile_arguments.dart';
import 'package:wirasasa/features/service_request/presentation/providers/booking_flow_provider.dart';

const LatLng _clientLocation = LatLng(-1.2600, 36.8040);

class MapDiscoveryScreen extends ConsumerStatefulWidget {
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
  ConsumerState<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends ConsumerState<MapDiscoveryScreen> {
  late final TextEditingController _controller;
  GoogleMapController? _mapController;
  late String _query;
  ProviderPreview? _selectedProvider;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? widget.serviceType;
    _controller = TextEditingController(text: _query);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(bookingFlowProvider.notifier)
          .startFlow(
            serviceType: widget.serviceType,
            scheduledDateTime: widget.scheduledDateTime,
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = _visibleProviders;
    final selectedProvider = _resolveSelectedProvider(providers);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _supportsGoogleMaps
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: selectedProvider?.location ?? _clientLocation,
                      zoom: 13.8,
                    ),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    markers: _buildMarkers(providers, selectedProvider),
                    polylines: selectedProvider == null
                        ? const {}
                        : {
                            Polyline(
                              polylineId: const PolylineId('selected-route'),
                              points: [_clientLocation, selectedProvider.location],
                              width: 5,
                              color: AppColors.green,
                            ),
                          },
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _focusOnProviders(providers, selectedProvider);
                    },
                  )
                : const _UnsupportedMapFallback(),
          ),
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
                                  onChanged: (value) {
                                    setState(() => _query = value);
                                    _focusOnProviders(
                                      _visibleProviders,
                                      _selectedProvider,
                                    );
                                  },
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
                    if (selectedProvider != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Selected: ${selectedProvider.name}',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    ...providers.map(
                      (provider) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProviderListCard(
                          provider: provider,
                          isSelected: provider.name == selectedProvider?.name,
                          onTap: () {
                            _selectProvider(provider);
                            Navigator.pushNamed(
                              context,
                              AppRouter.providerProfile,
                              arguments: ProviderProfileArguments(
                                provider: provider,
                                serviceType: widget.serviceType,
                                scheduledDateTime: widget.scheduledDateTime,
                              ),
                            );
                          },
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

  List<ProviderPreview> get _visibleProviders {
    final providers = MockData.providers.where((provider) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) {
        return provider.service == widget.serviceType;
      }
      return provider.service.toLowerCase().contains(query) ||
          provider.name.toLowerCase().contains(query);
    }).toList();
    if (providers.isNotEmpty) {
      return providers;
    }
    return MockData.providers
        .where((provider) => provider.service == widget.serviceType)
        .toList();
  }

  ProviderPreview? _resolveSelectedProvider(List<ProviderPreview> providers) {
    final bookingFlow = ref.watch(bookingFlowProvider);
    final preserved = bookingFlow.selectedProvider;
    if (_selectedProvider != null &&
        providers.any((provider) => provider.name == _selectedProvider!.name)) {
      return _selectedProvider;
    }
    if (preserved != null &&
        providers.any((provider) => provider.name == preserved.name)) {
      _selectedProvider = preserved;
      return preserved;
    }
    if (providers.isEmpty) {
      _selectedProvider = null;
      return null;
    }
    _selectedProvider = providers.first;
    ref.read(bookingFlowProvider.notifier).selectProvider(_selectedProvider!);
    return _selectedProvider;
  }

  Set<Marker> _buildMarkers(
    List<ProviderPreview> providers,
    ProviderPreview? selectedProvider,
  ) {
    return {
      Marker(
        markerId: const MarkerId('client'),
        position: _clientLocation,
        infoWindow: const InfoWindow(title: 'Client'),
        icon: _markerIcon(isClient: true, isSelected: false),
      ),
      ...providers.map(
        (provider) => Marker(
          markerId: MarkerId(provider.name),
          position: provider.location,
          infoWindow: InfoWindow(
            title: provider.name,
            snippet: '${provider.service} • ${provider.eta}',
          ),
          icon: _markerIcon(
            isClient: false,
            isSelected: provider.name == selectedProvider?.name,
          ),
          onTap: () => _selectProvider(provider),
        ),
      ),
    };
  }

  Future<void> _focusOnProviders(
    List<ProviderPreview> providers,
    ProviderPreview? selectedProvider,
  ) async {
    final controller = _mapController;
    if (controller == null || !_supportsGoogleMaps || providers.isEmpty) {
      return;
    }

    if (selectedProvider != null) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(selectedProvider.location, 14.5),
      );
      return;
    }

    final points = [_clientLocation, ...providers.map((provider) => provider.location)];
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

  void _selectProvider(ProviderPreview provider) {
    ref.read(bookingFlowProvider.notifier).selectProvider(provider);
    setState(() => _selectedProvider = provider);
    _focusOnProviders(_visibleProviders, provider);
  }
}

class _UnsupportedMapFallback extends StatelessWidget {
  const _UnsupportedMapFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF5EE), Color(0xFFF7F7F8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Google Maps is enabled for Android and iOS builds. This platform keeps the booking overlays but skips the embedded map.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.slate,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderListCard extends StatelessWidget {
  const _ProviderListCard({
    required this.provider,
    required this.onTap,
    required this.isSelected,
  });

  final ProviderPreview provider;
  final VoidCallback onTap;
  final bool isSelected;

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
            border: Border.all(
              color: isSelected ? AppColors.green : AppColors.line,
              width: isSelected ? 1.5 : 1,
            ),
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
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppColors.green),
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

extension on ProviderPreview {
  LatLng get location => LatLng(latitude, longitude);
}

BitmapDescriptor _markerIcon({
  required bool isClient,
  required bool isSelected,
}) {
  if (kIsWeb) {
    return BitmapDescriptor.defaultMarker;
  }
  if (isClient) {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }
  return BitmapDescriptor.defaultMarkerWithHue(
    isSelected ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
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
