import 'package:flutter/material.dart';
import 'package:wirasasa/shared_widgets/info_chip.dart';
import 'package:wirasasa/shared_widgets/primary_button.dart';
import 'package:wirasasa/shared_widgets/section_header.dart';
import 'package:wirasasa/shared_widgets/surface_card.dart';

class ServiceRequestScreen extends StatelessWidget {
  const ServiceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Service')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeader(title: 'Choose day'),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              InfoChip(label: 'Today'),
              InfoChip(label: 'Tomorrow'),
              InfoChip(label: 'Pick date'),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Choose time'),
          const SizedBox(height: 12),
          const SurfaceCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                InfoChip(label: '09:00 AM'),
                InfoChip(label: '11:00 AM'),
                InfoChip(label: '01:00 PM'),
                InfoChip(label: '04:00 PM'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request Summary'),
                SizedBox(height: 12),
                Text('Electrician • John Smith'),
                SizedBox(height: 4),
                Text('Estimated arrival: 10 min after acceptance'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Confirm Request',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mock request submitted.')),
            ),
          ),
        ],
      ),
    );
  }
}
