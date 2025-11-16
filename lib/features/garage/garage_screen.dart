import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/controllers/app_controller.dart';
import '../../core/controllers/vehicle_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/vehicle.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({
    super.key,
    required this.vehicleController,
    required this.appController,
  });

  final VehicleController vehicleController;
  final AppController appController;

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  void _openVehicleSheet({Vehicle? vehicle}) {
    final locale = AppLocalizations.of(context);
    final nameController = TextEditingController(text: vehicle?.name ?? '');
    final imageController =
        TextEditingController(text: vehicle?.image ?? '');
    final rangeController =
        TextEditingController(text: '${vehicle?.range ?? 480}');
    final powerController =
        TextEditingController(text: '${vehicle?.power ?? 520}');
    final odometerController =
        TextEditingController(text: '${vehicle?.odometer ?? 12000}');
    final efficiencyController =
        TextEditingController(text: '${vehicle?.efficiency ?? 18}');
    final drivetrainController =
        TextEditingController(text: vehicle?.drivetrain ?? 'AWD');
    final batteryTypeController =
        TextEditingController(text: vehicle?.batteryType ?? 'Li-ion');
    double batteryLevel = vehicle?.batteryLevel ?? 0.6;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle == null
                          ? locale.translate('addVehicle')
                          : locale.translate('editVehicle'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _GarageTextField(
                      controller: nameController,
                      label: locale.translate('vehicles'),
                    ),
                    _GarageTextField(
                      controller: imageController,
                      label: 'Image URL',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _GarageTextField(
                            controller: rangeController,
                            label: locale.translate('range'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GarageTextField(
                            controller: powerController,
                            label: locale.translate('power'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _GarageTextField(
                            controller: odometerController,
                            label: locale.translate('odometer'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GarageTextField(
                            controller: efficiencyController,
                            label: locale.translate('efficiency'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    _GarageTextField(
                      controller: drivetrainController,
                      label: locale.translate('drivetrain'),
                    ),
                    _GarageTextField(
                      controller: batteryTypeController,
                      label: locale.translate('battery'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      locale.translate('battery'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Slider(
                      value: batteryLevel,
                      onChanged: (value) => setModalState(() {
                        batteryLevel = value;
                      }),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: locale.translate('save'),
                      onPressed: () {
                        final name = nameController.text.trim().isEmpty
                            ? 'Custom EV'
                            : nameController.text.trim();
                        final image = imageController.text.trim().isEmpty
                            ? 'https://images.unsplash.com/photo-1511396275277-dc5640f4a2d4?auto=format&fit=crop&w=1200&q=60'
                            : imageController.text.trim();
                        final range =
                            int.tryParse(rangeController.text) ?? 480;
                        final power =
                            int.tryParse(powerController.text) ?? 520;
                        final odometer =
                            int.tryParse(odometerController.text) ?? 12000;
                        final efficiency =
                            int.tryParse(efficiencyController.text) ?? 18;
                        final drivetrain =
                            drivetrainController.text.trim().isEmpty
                                ? 'AWD'
                                : drivetrainController.text.trim();
                        final batteryType =
                            batteryTypeController.text.trim().isEmpty
                                ? 'Li-ion'
                                : batteryTypeController.text.trim();
                        if (vehicle == null) {
                          widget.vehicleController.addVehicle(
                            Vehicle(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              name: name,
                              image: image,
                              range: range,
                              power: power,
                              speed: 210,
                              batteryLevel: batteryLevel,
                              odometer: odometer,
                              efficiency: efficiency,
                              drivetrain: drivetrain,
                              batteryType: batteryType,
                              lastService:
                                  DateTime.now().subtract(const Duration(days: 30)),
                            ),
                          );
                        } else {
                          widget.vehicleController.updateVehicle(
                            vehicle.id,
                            range: range,
                            power: power,
                            odometer: odometer,
                            efficiency: efficiency,
                            batteryLevel: batteryLevel,
                            drivetrain: drivetrain,
                            batteryType: batteryType,
                          );
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(locale.translate('save')),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.vehicleController,
      builder: (context, _) {
        if (widget.vehicleController.loading) {
          return Scaffold(
            appBar: AppBar(title: Text(locale.translate('garage'))),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final current = widget.vehicleController.currentVehicle;
        final favorites = widget.vehicleController.favoriteVehicles;
        final vehicles = widget.vehicleController.vehicles;
        return Scaffold(
          appBar: AppBar(
            title: Text(locale.translate('garage')),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _openVehicleSheet(),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                locale.translate('garageSubtitle'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(locale.translate('primaryVehicle').toUpperCase()),
                              const SizedBox(height: 8),
                              Text(
                                current.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.appController
                                    .formatDistance(current.range),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            current.image,
                            width: 120,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SpecTile(
                            label: locale.translate('vehicleHealth'),
                            value: '${current.healthScore}%',
                          ),
                        ),
                        Expanded(
                          child: _SpecTile(
                            label: locale.translate('odometer'),
                            value:
                                '${widget.appController.formatDistance(current.odometer, includeUnit: true)}',
                          ),
                        ),
                        Expanded(
                          child: _SpecTile(
                            label: locale.translate('efficiency'),
                            value: '${current.efficiency} kWh/100km',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(current.drivetrain),
                        ),
                        Chip(
                          label: Text(current.batteryType),
                        ),
                        Chip(
                          label: Text(
                            '${locale.translate('lastService')}: ${current.lastService.month}/${current.lastService.day}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: locale.translate('editVehicle'),
                      onPressed: () => _openVehicleSheet(vehicle: current),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).moveY(begin: 12),
              const SizedBox(height: 24),
              SectionHeader(
                title: locale.translate('favoriteVehicles'),
                action: TextButton(
                  onPressed: () => _openVehicleSheet(),
                  child: Text(locale.translate('addVehicle')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 170,
                child: favorites.isEmpty
                    ? Center(
                        child: Text(locale.translate('noFavoritesYet')),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final vehicle = favorites[index];
                          return SizedBox(
                            width: 220,
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vehicle.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded),
                                        onPressed: () => widget.vehicleController
                                            .toggleFavorite(vehicle.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.appController
                                        .formatDistance(vehicle.range),
                                  ),
                                  const Spacer(),
                                  FilledButton.tonal(
                                    onPressed: () => widget.vehicleController
                                        .markPrimary(vehicle.id),
                                    child: Text(locale.translate('setPrimary')),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemCount: favorites.length,
                      ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: locale.translate('allVehicles'),
                action: TextButton(
                  onPressed: () => _openVehicleSheet(),
                  child: Text(locale.translate('addVehicle')),
                ),
              ),
              const SizedBox(height: 12),
              ...vehicles.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final vehicle = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: RadioListTile<int>(
                        contentPadding: EdgeInsets.zero,
                        value: index,
                        groupValue: widget.vehicleController.selectedIndex,
                        onChanged: (value) {
                          if (value != null) {
                            widget.vehicleController.selectVehicle(value);
                          }
                        },
                        title: Text(vehicle.name),
                        subtitle: Text(
                          '${widget.appController.formatDistance(vehicle.range)} · ${vehicle.drivetrain}',
                        ),
                        secondary: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => widget.vehicleController
                                  .removeVehicle(vehicle.id),
                            ),
                            IconButton(
                              icon: Icon(
                                vehicle.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              onPressed: () => widget.vehicleController
                                  .toggleFavorite(vehicle.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _openVehicleSheet(vehicle: vehicle),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GarageTextField extends StatelessWidget {
  const _GarageTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
