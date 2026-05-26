import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soulfood_front/core/location/location_service.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/features/nearby/nearby_repository.dart';
import 'package:soulfood_front/features/nearby/restaurant_detail_page.dart';
import 'package:soulfood_front/l10n/app_localizations.dart';

class RestaurantMapPage extends StatefulWidget {
  const RestaurantMapPage({super.key});

  @override
  State<RestaurantMapPage> createState() => _RestaurantMapPageState();
}

class _RestaurantMapPageState extends State<RestaurantMapPage> {
  final _repo = NearbyRepository();
  final _mapController = MapController();

  List<RestaurantItem> _items = [];
  LatLng? _userLocation;
  bool _loading = true;
  RestaurantItem? _selected;

  static const _fallbackCenter = LatLng(31.2304, 121.4737);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final location = await LocationService.current();
      final items = await _repo.list(lat: location?.lat, lng: location?.lng);
      if (!mounted) return;

      final withCoords = items.where((e) => e.lat != null && e.lng != null).toList();
      final user = location == null ? null : LatLng(location.lat, location.lng);

      setState(() {
        _items = withCoords;
        _userLocation = user;
        _selected = withCoords.isNotEmpty ? withCoords.first : null;
      });

      if (user != null) {
        _mapController.move(user, 14);
      } else if (withCoords.isNotEmpty) {
        _mapController.move(LatLng(withCoords.first.lat!, withCoords.first.lng!), 14);
      }

      if (location == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.mapNoLocation)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _focusRestaurant(RestaurantItem item) {
    if (item.lat == null || item.lng == null) return;
    setState(() => _selected = item);
    _mapController.move(LatLng(item.lat!, item.lng!), 15);
  }

  void _openDetail(RestaurantItem item) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RestaurantDetailPage(restaurantId: item.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;
    final center = _userLocation ??
        (_items.isNotEmpty && _items.first.lat != null
            ? LatLng(_items.first.lat!, _items.first.lng!)
            : _fallbackCenter);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nearbyMap),
        actions: [
          IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.my_location_outlined)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 14,
                      onTap: (tapPosition, point) => setState(() => _selected = null),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.soulfood_front',
                      ),
                      if (_userLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _userLocation!,
                              width: 36,
                              height: 36,
                              child: Icon(Icons.my_location, color: colors.accent, size: 28),
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: _items.map((item) {
                          final selected = _selected?.id == item.id;
                          return Marker(
                            point: LatLng(item.lat!, item.lng!),
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () => _focusRestaurant(item),
                              child: Icon(
                                Icons.location_on,
                                size: selected ? 40 : 32,
                                color: selected ? colors.accent : colors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      border: Border(top: BorderSide(color: colors.cardBorder)),
                    ),
                    child: _items.isEmpty
                        ? Center(child: Text(l10n.mapNoRestaurants, style: TextStyle(color: colors.textSecondary)))
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _items.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              final active = _selected?.id == item.id;
                              return Material(
                                color: active ? colors.chipSelectedBackground : colors.cardBackground,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  onTap: () => _focusRestaurant(item),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: active ? colors.chipSelectedBorder : colors.cardBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: colors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${item.category} · ${item.distanceKm ?? '-'} km',
                                                style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _openDetail(item),
                                          icon: Icon(Icons.chevron_right, color: colors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
