import 'package:flutter/material.dart';

class ServiceCategory {
  const ServiceCategory({
    required this.name,
    required this.icon,
    required this.group,
    required this.description,
    required this.color,
  });

  final String name;
  final IconData icon;
  final String group;
  final String description;
  final Color color;
}

class ProviderPreview {
  const ProviderPreview({
    required this.name,
    required this.rating,
    required this.jobs,
    required this.distance,
    required this.eta,
    required this.pricePerHour,
    required this.service,
    required this.review,
  });

  final String name;
  final double rating;
  final int jobs;
  final String distance;
  final String eta;
  final int pricePerHour;
  final String service;
  final String review;

  String get initials {
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class ActivityPreview {
  const ActivityPreview({
    required this.provider,
    required this.date,
    required this.time,
    required this.amount,
    required this.service,
    required this.icon,
  });

  final String provider;
  final String date;
  final String time;
  final String amount;
  final String service;
  final IconData icon;
}

class ProviderRequestPreview {
  const ProviderRequestPreview({
    required this.clientName,
    required this.service,
    required this.location,
    required this.time,
    required this.budget,
  });

  final String clientName;
  final String service;
  final String location;
  final String time;
  final String budget;
}

class MockData {
  static const recentServices = ['Electrician', 'Plumber'];

  static const categories = [
    ServiceCategory(
      name: 'Electrician',
      icon: Icons.bolt_rounded,
      group: 'Home Services',
      description: 'Tap to find providers',
      color: Color(0xFF07B53B),
    ),
    ServiceCategory(
      name: 'Plumber',
      icon: Icons.plumbing_rounded,
      group: 'Home Services',
      description: 'Tap to find providers',
      color: Color(0xFF2962F2),
    ),
    ServiceCategory(
      name: 'Mechanic',
      icon: Icons.directions_car_filled_rounded,
      group: 'Auto Services',
      description: 'Tap to find providers',
      color: Color(0xFF253045),
    ),
    ServiceCategory(
      name: 'Gardener',
      icon: Icons.eco_outlined,
      group: 'Outdoor Services',
      description: 'Tap to find providers',
      color: Color(0xFF0B8B39),
    ),
  ];

  static const providers = [
    ProviderPreview(
      name: 'John Smith',
      rating: 4.9,
      jobs: 127,
      distance: '2.3 mi away',
      eta: '10 min ETA',
      pricePerHour: 8500,
      service: 'Electrician',
      review: 'Arrived quickly and fixed the power issue cleanly.',
    ),
    ProviderPreview(
      name: 'Sarah Johnson',
      rating: 4.8,
      jobs: 95,
      distance: '3.0 mi away',
      eta: '15 min ETA',
      pricePerHour: 8000,
      service: 'Plumber',
      review: 'Clear communication and reliable work from start to finish.',
    ),
    ProviderPreview(
      name: 'Mike Davis',
      rating: 4.7,
      jobs: 82,
      distance: '4.1 mi away',
      eta: '18 min ETA',
      pricePerHour: 7500,
      service: 'Mechanic',
      review: 'Diagnosed the problem fast and explained each repair step.',
    ),
    ProviderPreview(
      name: 'Amina Njeri',
      rating: 4.9,
      jobs: 141,
      distance: '2.0 mi away',
      eta: '9 min ETA',
      pricePerHour: 6800,
      service: 'Gardener',
      review: 'Very organized, punctual, and detail oriented.',
    ),
  ];

  static const activities = [
    ActivityPreview(
      provider: 'John Smith',
      date: '3 Feb',
      time: '11:27',
      amount: 'KES460.00',
      service: 'Electrical Repair',
      icon: Icons.eco_outlined,
    ),
    ActivityPreview(
      provider: 'Sarah Johnson',
      date: '3 Feb',
      time: '08:08',
      amount: 'KES1,280.00',
      service: 'Pipe Repair',
      icon: Icons.local_shipping_outlined,
    ),
    ActivityPreview(
      provider: 'Mike Davis',
      date: '31 Jan',
      time: '14:26',
      amount: 'KES80.00',
      service: 'Battery Jumpstart',
      icon: Icons.eco_outlined,
    ),
  ];

  static const incomingRequests = [
    ProviderRequestPreview(
      clientName: 'Dennis Njoroge',
      service: 'Garden cleanup',
      location: 'Karen',
      time: 'Today • 2:00 PM',
      budget: 'KES 6,500',
    ),
    ProviderRequestPreview(
      clientName: 'Lucy Akinyi',
      service: 'Socket repair',
      location: 'Westlands',
      time: 'Today • 4:30 PM',
      budget: 'KES 4,200',
    ),
  ];

  static ServiceCategory? findCategoryByName(String name) {
    for (final category in categories) {
      if (category.name.toLowerCase() == name.toLowerCase()) {
        return category;
      }
    }
    return null;
  }

  static List<ServiceCategory> searchCategories(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return categories;
    }
    return categories.where((category) {
      return category.name.toLowerCase().contains(normalized) ||
          category.group.toLowerCase().contains(normalized);
    }).toList();
  }
}
