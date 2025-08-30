import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';
import '../utils/app_routes.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.loadEvents(refresh: true);
    eventProvider.loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          return RefreshIndicator(
            onRefresh: () => eventProvider.loadEvents(refresh: true),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surface,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                eventProvider.clearSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (query) {
                      if (query.isNotEmpty) {
                        eventProvider.searchEvents(query);
                      }
                    },
                  ),
                ),
                
                // Categories Filter
                if (eventProvider.categories.isNotEmpty)
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: eventProvider.categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              category: eventProvider.categories.first.copyWith(
                                name: 'All',
                                id: '',
                              ),
                              isSelected: eventProvider.selectedCategory == null,
                              onTap: () {
                                eventProvider.filterByCategory(null);
                              },
                            ),
                          );
                        }
                        
                        final category = eventProvider.categories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            category: category,
                            isSelected: eventProvider.selectedCategory?.id == category.id,
                            onTap: () {
                              eventProvider.filterByCategory(category.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                
                // Events List
                Expanded(
                  child: _buildEventsList(eventProvider),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.createEvent);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsList(EventProvider eventProvider) {
    if (eventProvider.isLoading && eventProvider.events.isEmpty) {
      return const Center(
        child: CircularLoading(message: 'Loading events...'),
      );
    }

    if (eventProvider.errorMessage != null) {
      return CustomErrorWidget(
        message: eventProvider.errorMessage!,
        onRetry: () => eventProvider.loadEvents(refresh: true),
      );
    }

    if (eventProvider.events.isEmpty) {
      return const NotFoundErrorWidget(
        title: 'No Events Found',
        message: 'Try adjusting your search or filters to find events.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: eventProvider.events.length,
      itemBuilder: (context, index) {
        final event = eventProvider.events[index];
        return EventCard(
          event: event,
          onTap: () {
            eventProvider.setSelectedEvent(event);
            Navigator.of(context).pushNamed(AppRoutes.eventDetail);
          },
          onFavorite: () => _toggleFavorite(event.id),
          isFavorite: Provider.of<AuthProvider>(context, listen: false)
              .isEventFavorite(event.id),
        );
      },
    );
  }

  Future<void> _toggleFavorite(String eventId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isFavorite = authProvider.isEventFavorite(eventId);
    
    final success = isFavorite
        ? await authProvider.removeFromFavorites(eventId)
        : await authProvider.addToFavorites(eventId);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'Removed from favorites' : 'Added to favorites',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'Filter Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Filter Options
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Date Filter
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date Range'),
                        subtitle: const Text('Filter by event date'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showDateFilter(),
                      ),
                      
                      // Price Filter
                      ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: const Text('Price Range'),
                        subtitle: const Text('Filter by ticket price'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showPriceFilter(),
                      ),
                      
                      // Distance Filter
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Distance'),
                        subtitle: const Text('Filter by distance from you'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showDistanceFilter(),
                      ),
                      
                      const Divider(),
                      
                      // Clear Filters
                      ListTile(
                        leading: const Icon(Icons.clear_all),
                        title: const Text('Clear All Filters'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Provider.of<EventProvider>(context, listen: false)
                              .loadEvents(refresh: true);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDateFilter() {
    // Implement date range picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Date filter will be implemented')),
    );
  }

  void _showPriceFilter() {
    // Implement price range slider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Price filter will be implemented')),
    );
  }

  void _showDistanceFilter() {
    // Implement distance slider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Distance filter will be implemented')),
    );
  }
}