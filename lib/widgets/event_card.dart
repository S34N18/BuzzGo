import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/helpers.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool showFavoriteButton;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: event.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(event.imageUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Handle image loading error
                              },
                            )
                          : null,
                    ),
                    child: event.imageUrl.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.event,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                  ),
                  // Price Badge
                  if (event.price > 0)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'KES ${event.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Free Badge
                  if (event.price == 0)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'FREE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Favorite Button
                  if (showFavoriteButton)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: onFavorite,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Event Date and Time
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Helpers.formatEventDate(event.startDate),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Event Location
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
                          event.location,
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
                  const SizedBox(height: 8),
                  // Event Description
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Attendees Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.currentAttendees}/${event.maxAttendees} attending',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Availability Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getAvailabilityColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getAvailabilityText(),
                          style: TextStyle(
                            color: _getAvailabilityColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvailabilityColor() {
    if (event.currentAttendees >= event.maxAttendees) {
      return Colors.red;
    } else if (event.currentAttendees >= event.maxAttendees * 0.8) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getAvailabilityText() {
    if (event.currentAttendees >= event.maxAttendees) {
      return 'Full';
    } else if (event.currentAttendees >= event.maxAttendees * 0.8) {
      return 'Almost Full';
    } else {
      return 'Available';
    }
  }
}