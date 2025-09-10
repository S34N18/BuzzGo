import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/event_model.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/location_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load categories when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.loadCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _maxAttendeesController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        elevation: 0,
      ),
      body: Consumer2<EventProvider, AuthProvider>(
        builder: (context, eventProvider, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title *',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: Validators.validateEventTitle,
                  ),
                  const SizedBox(height: 16),

                  // Event Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Event Description *',
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    validator: Validators.validateEventDescription,
                  ),
                  const SizedBox(height: 16),

                  // Category Selection
                  if (eventProvider.categories.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('No categories available. Loading...'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => eventProvider.loadCategories(),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: eventProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location *',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: Validators.validateLocation,
                  ),
                  const SizedBox(height: 16),

                  // Date and Time Selection
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartDate(),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date *',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _startDate != null
                                  ? Helpers.formatDateTime(_startDate!)
                                  : 'Select start date',
                              style: TextStyle(
                                color: _startDate != null
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndDate(),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date *',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _endDate != null
                                  ? Helpers.formatDateTime(_endDate!)
                                  : 'Select end date',
                              style: TextStyle(
                                color: _endDate != null
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price and Max Attendees
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price (KES)',
                            prefixIcon: Icon(Icons.attach_money),
                            hintText: '0 for free',
                          ),
                          validator: Validators.validatePrice,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxAttendeesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max Attendees *',
                            prefixIcon: Icon(Icons.people),
                          ),
                          validator: Validators.validateMaxAttendees,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Event Image URL
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Event Image URL',
                      prefixIcon: Icon(Icons.image),
                      hintText: 'https://example.com/image.jpg',
                    ),
                    validator: Validators.validateImageUrl,
                  ),
                  const SizedBox(height: 32),

                  // Create Button
                  PrimaryButton(
                    text: 'Create Event',
                    width: double.infinity,
                    isLoading: eventProvider.isLoading,
                    onPressed: () => _handleCreateEvent(eventProvider, authProvider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _startDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final initialDate = _startDate?.add(const Duration(hours: 2)) ?? 
                       DateTime.now().add(const Duration(days: 1, hours: 2));
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        setState(() {
          _endDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleCreateEvent(
    EventProvider eventProvider,
    AuthProvider authProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get coordinates from location
    double latitude = 0.0;
    double longitude = 0.0;
    final locationService = LocationService();
    try {
      final position = await locationService.getCoordinatesFromAddress(
        _locationController.text.trim(),
      );
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not find coordinates for the location. Using default values.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location coordinates: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    final event = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      location: _locationController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      categoryId: _selectedCategoryId!,
      organizerId: authProvider.user!.uid,
      price: double.tryParse(_priceController.text) ?? 0.0,
      maxAttendees: int.parse(_maxAttendeesController.text),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await eventProvider.createEvent(event);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventProvider.errorMessage ?? 'Failed to create event'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}