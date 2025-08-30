import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../models/event_model.dart';
import '../utils/helpers.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/map_widget.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _showMap = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventProvider, AuthProvider>(
      builder: (context, eventProvider, authProvider, child) {
        final event = eventProvider.selectedEvent;
        
        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Event Details')),
            body: const Center(
              child: Text('No event selected'),
            ),
          );
        }

        final isFavorite = authProvider.isEventFavorite(event.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Event Image
                      event.imageUrl.isNotEmpty
                          ? Image.network(
                              event.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.event,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.event,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // Favorite Button
                  IconButton(
                    onPressed: () => _toggleFavorite(authProvider, event.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                  ),
                  // Share Button
                  IconButton(
                    onPressed: () => _shareEvent(event),
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ],
              ),
              
              // Event Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Event Info Cards
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Date & Time',
                        content: Helpers.formatEventDate(
                          event.startDate,
                          endDate: event.endDate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildInfoCard(
                        icon: Icons.location_on,
                        title: 'Location',
                        content: event.location,
                        onTap: () {
                          setState(() {
                            _showMap = !_showMap;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      _buildInfoCard(
                        icon: Icons.attach_money,
                        title: 'Price',
                        content: Helpers.formatPrice(event.price),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildInfoCard(
                        icon: Icons.people,
                        title: 'Attendees',
                        content: '${event.currentAttendees} / ${event.maxAttendees}',
                      ),
                      
                      // Map Section
                      if (_showMap) ...[
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: MapWidget(
                              events: [event],
                              selectedEvent: event,
                              initialLatitude: event.latitude,
                              initialLongitude: event.longitude,
                              initialZoom: 15.0,
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Description Section
                      const Text(
                        'About This Event',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlineButton(
                              text: 'Get Directions',
                              icon: Icons.directions,
                              onPressed: () => _getDirections(event),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              text: event.price > 0 ? 'Buy Ticket' : 'Register',
                              icon: event.price > 0 ? Icons.payment : Icons.event_available,
                              onPressed: () => _handleRegistration(event),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Additional Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow('Event ID', event.id),
                              _buildDetailRow('Created', Helpers.formatDate(event.createdAt)),
                              _buildDetailRow('Last Updated', Helpers.formatDate(event.updatedAt)),
                              _buildDetailRow(
                                'Availability',
                                event.currentAttendees >= event.maxAttendees
                                    ? 'Sold Out'
                                    : 'Available',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6750A4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6750A4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  _showMap ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(AuthProvider authProvider, String eventId) async {
    final isFavorite = authProvider.isEventFavorite(eventId);
    
    final success = isFavorite
        ? await authProvider.removeFromFavorites(eventId)
        : await authProvider.addToFavorites(eventId);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Removed from favorites'
                : 'Added to favorites',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareEvent(EventModel event) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will be implemented'),
      ),
    );
  }

  void _getDirections(EventModel event) {
    final url = 'https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}';
    Helpers.launchURL(url);
  }

  void _handleRegistration(EventModel event) {
    if (event.currentAttendees >= event.maxAttendees) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This event is sold out'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (event.price > 0) {
      // Navigate to payment screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment functionality will be implemented'),
        ),
      );
    } else {
      // Free event registration
      _showRegistrationDialog(event);
    }
  }

  void _showRegistrationDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Registration'),
        content: Text('Register for "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration successful!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}