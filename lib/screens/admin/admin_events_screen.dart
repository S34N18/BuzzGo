import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../models/event_model.dart';
import '../../utils/helpers.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    Provider.of<EventProvider>(context, listen: false).loadEvents(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        actions: [
          IconButton(
            onPressed: () => _showAddEventDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventProvider.events.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No events found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadEvents(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: eventProvider.events.length,
              itemBuilder: (context, index) {
                final event = eventProvider.events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: event.isActive ? Colors.green : Colors.red,
                      child: const Icon(
                        Icons.event,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.location),
                        Text(
                          Helpers.formatEventDate(event.startDate),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditEventDialog(event);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(event);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddEventDialog() {
    _showEventDialog();
  }

  void _showEditEventDialog(EventModel event) {
    _showEventDialog(event: event);
  }

  void _showEventDialog({EventModel? event}) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    DateTime selectedDate = event?.startDate ?? DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event == null ? 'Add Event' : 'Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Event Date'),
                subtitle: Text(Helpers.formatDateTime(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  if (mounted) {
                    final date = await showDatePicker(
                      context: this.context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(
                        context: this.context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null && mounted) {
                        selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  locationController.text.isNotEmpty) {
                
                final eventProvider = Provider.of<EventProvider>(context, listen: false);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                
                if (event == null) {
                  // Create new event
                  final newEvent = EventModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    imageUrl: '',
                    startDate: selectedDate,
                    endDate: selectedDate.add(const Duration(hours: 2)),
                    location: locationController.text.trim(),
                    latitude: 0.0,
                    longitude: 0.0,
                    categoryId: 'general',
                    organizerId: authProvider.user!.uid,
                    price: 0.0,
                    maxAttendees: 100,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  
                  await eventProvider.createEvent(newEvent);
                } else {
                  // Update existing event
                  final updatedEvent = event.copyWith(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    location: locationController.text.trim(),
                    startDate: selectedDate,
                    endDate: selectedDate.add(const Duration(hours: 2)),
                    updatedAt: DateTime.now(),
                  );
                  
                  await eventProvider.updateEvent(updatedEvent);
                }
                
                if (mounted) {
                  Navigator.of(this.context).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(event == null ? 'Event created!' : 'Event updated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: Text(event == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final eventProvider = Provider.of<EventProvider>(context, listen: false);
              await eventProvider.deleteEvent(event.id);
              
              if (mounted) {
                Navigator.of(this.context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Event deleted!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}