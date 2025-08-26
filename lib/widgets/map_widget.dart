import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/event_model.dart';

class MapWidget extends StatefulWidget {
  final List<EventModel> events;
  final EventModel? selectedEvent;
  final Function(EventModel)? onEventSelected;
  final double? initialLatitude;
  final double? initialLongitude;
  final double initialZoom;

  const MapWidget({
    super.key,
    required this.events,
    this.selectedEvent,
    this.onEventSelected,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom = 12.0,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events ||
        oldWidget.selectedEvent != widget.selectedEvent) {
      _createMarkers();
    }
  }

  void _createMarkers() {
    _markers = widget.events.map((event) {
      return Marker(
        markerId: MarkerId(event.id),
        position: LatLng(event.latitude, event.longitude),
        infoWindow: InfoWindow(
          title: event.title,
          snippet: event.location,
          onTap: () {
            if (widget.onEventSelected != null) {
              widget.onEventSelected!(event);
            }
          },
        ),
        icon: widget.selectedEvent?.id == event.id
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          if (widget.onEventSelected != null) {
            widget.onEventSelected!(event);
          }
        },
      );
    }).toSet();

    if (mounted) {
      setState(() {});
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _animateToEvent(EventModel event) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(event.latitude, event.longitude),
          15.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default location (Nairobi, Kenya)
    final LatLng initialPosition = LatLng(
      widget.initialLatitude ?? -1.2921,
      widget.initialLongitude ?? 36.8219,
    );

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: widget.initialZoom,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          compassEnabled: true,
          trafficEnabled: false,
          buildingsEnabled: true,
          indoorViewEnabled: true,
          mapType: MapType.normal,
        ),
        // Event Info Card
        if (widget.selectedEvent != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.selectedEvent!.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            if (widget.onEventSelected != null) {
                              widget.onEventSelected!(widget.selectedEvent!);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.selectedEvent!.location,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(widget.selectedEvent!.startDate),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.selectedEvent!.price > 0
                              ? 'KES ${widget.selectedEvent!.price.toStringAsFixed(0)}'
                              : 'FREE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.selectedEvent!.price > 0
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _animateToEvent(widget.selectedEvent!);
                          },
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Map Type Toggle
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              // Toggle map type or show map options
              _showMapOptions();
            },
            child: const Icon(Icons.layers),
          ),
        ),
      ],
    );
  }

  void _showMapOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Map Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Normal'),
                onTap: () {
                  _changeMapType(MapType.normal);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.satellite),
                title: const Text('Satellite'),
                onTap: () {
                  _changeMapType(MapType.satellite);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.terrain),
                title: const Text('Terrain'),
                onTap: () {
                  _changeMapType(MapType.terrain);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.traffic),
                title: const Text('Hybrid'),
                onTap: () {
                  _changeMapType(MapType.hybrid);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeMapType(MapType mapType) {
    // This would require rebuilding the GoogleMap widget with the new map type
    // For now, we'll just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Map type changed to ${mapType.toString().split('.').last}'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}