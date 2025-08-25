import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/category_chip.dart';
import '../utils/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.loadEvents();
    eventProvider.loadCategories();
    eventProvider.loadNearbyEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildSearchTab(),
          _buildFavoritesTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('BuzzGo'),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6750A4),
                        Color(0xFF7F39FB),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Icon(
                          Icons.event,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Discover Amazing Events',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoriesSection(eventProvider),
                    const SizedBox(height: 24),
                    _buildNearbyEventsSection(eventProvider),
                    const SizedBox(height: 24),
                    _buildUpcomingEventsSection(eventProvider),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              TextField(
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
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    eventProvider.searchEvents(query);
                  }
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: eventProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : eventProvider.events.isEmpty
                        ? const Center(
                            child: Text('No events found'),
                          )
                        : ListView.builder(
                            itemCount: eventProvider.events.length,
                            itemBuilder: (context, index) {
                              return EventCard(
                                event: eventProvider.events[index],
                                onTap: () {
                                  eventProvider.setSelectedEvent(
                                      eventProvider.events[index]);
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.eventDetail);
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer2<AuthProvider, EventProvider>(
      builder: (context, authProvider, eventProvider, child) {
        if (authProvider.userModel?.favoriteEvents.isEmpty ?? true) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No favorite events yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start exploring and add events to your favorites!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Your Favorite Events',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: eventProvider.favoriteEvents.length,
                  itemBuilder: (context, index) {
                    return EventCard(
                      event: eventProvider.favoriteEvents[index],
                      onTap: () {
                        eventProvider.setSelectedEvent(
                            eventProvider.favoriteEvents[index]);
                        Navigator.of(context).pushNamed(AppRoutes.eventDetail);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundImage: authProvider.userModel?.profileImage != null
                    ? NetworkImage(authProvider.userModel!.profileImage!)
                    : null,
                child: authProvider.userModel?.profileImage == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                authProvider.userModel?.name ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                authProvider.userModel?.email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.profile);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('My Events'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.myEvents);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.payment),
                      title: const Text('Payment History'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.paymentHistory);
                      },
                    ),
                    if (authProvider.isAdmin)
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: const Text('Admin Dashboard'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AppRoutes.adminDashboard);
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sign Out'),
                      onTap: () {
                        _showSignOutDialog(context, authProvider);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection(EventProvider eventProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: eventProvider.isLoadingCategories
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: eventProvider.categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CategoryChip(
                        category: eventProvider.categories[index],
                        isSelected: eventProvider.selectedCategory?.id ==
                            eventProvider.categories[index].id,
                        onTap: () {
                          eventProvider.filterByCategory(
                            eventProvider.selectedCategory?.id ==
                                    eventProvider.categories[index].id
                                ? null
                                : eventProvider.categories[index].id,
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNearbyEventsSection(EventProvider eventProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nearby Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all nearby events
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: eventProvider.isLoadingNearby
              ? const Center(child: CircularProgressIndicator())
              : eventProvider.nearbyEvents.isEmpty
                  ? const Center(child: Text('No nearby events found'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: eventProvider.nearbyEvents.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 300,
                          child: EventCard(
                            event: eventProvider.nearbyEvents[index],
                            onTap: () {
                              eventProvider.setSelectedEvent(
                                  eventProvider.nearbyEvents[index]);
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.eventDetail);
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection(EventProvider eventProvider) {
    final upcomingEvents = eventProvider.getUpcomingEvents(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.eventList);
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        eventProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : upcomingEvents.isEmpty
                ? const Center(child: Text('No upcoming events'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingEvents.length,
                    itemBuilder: (context, index) {
                      return EventCard(
                        event: upcomingEvents[index],
                        onTap: () {
                          eventProvider.setSelectedEvent(upcomingEvents[index]);
                          Navigator.of(context).pushNamed(AppRoutes.eventDetail);
                        },
                      );
                    },
                  ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}