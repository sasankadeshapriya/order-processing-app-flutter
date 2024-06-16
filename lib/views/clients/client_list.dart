import 'package:flutter/material.dart';

import '../../models/clients_modle.dart';
import '../../services/client_api_service.dart';
import '../../utils/app_colors.dart';
import 'client_card.dart';
import 'client_form.dart'; // Import your ClientCard widget

class ClientList extends StatefulWidget {
  const ClientList({super.key});

  @override
  _ClientListState createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  late Future<List<Client>> futureClients;
  bool _isAscending = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  final List<Client> _searchSuggestions = [];

  @override
  void initState() {
    super.initState();
    futureClients = ClientService.getClients();
  }

  void _onSortOrderChanged() {
    setState(() {
      _isAscending = !_isAscending;
      _filteredClients = List.from(_filteredClients.reversed);
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchSuggestions.clear();
      _filterClients('');
    });
  }

  void _updateSearch(String value) {
    setState(() {
      _filterClients(value);
    });
  }

  void _filterClients(String value) {
    _filteredClients = _clients.where((client) {
      return client.name!.toLowerCase().contains(value.toLowerCase()) ||
          client.organizationName!
              .toLowerCase()
              .contains(value.toLowerCase()) ||
          (client.phoneNo != null && client.phoneNo!.contains(value));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColor.primaryTextColor,
              size: 15,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search clients...',
                  border: InputBorder.none,
                ),
                onChanged: _updateSearch,
              )
            : const Text(
                'Client List',
                style: TextStyle(
                  color: Color(0xFF464949),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'SF Pro Text',
                ),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 24,
                color: AppColor.primaryTextColor,
              ),
              onPressed: _onSortOrderChanged,
            ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              size: 24,
              color: AppColor.primaryTextColor,
            ),
            onPressed: () {
              if (_isSearching) {
                _stopSearch();
              } else {
                _startSearch();
              }
            },
          ),
        ],
      ),
      body: _filteredClients.isEmpty && _isSearching
          ? const Center(child: Text('No clients found'))
          : FutureBuilder<List<Client>>(
              future: futureClients,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColor.accentColor),
                  ));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load clients'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No clients available'));
                }

                _clients = snapshot.data!;
                _filterClients(_searchController.text);

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ListView.builder(
                    itemCount: _filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = _filteredClients[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                        ),
                        child: ClientCard(
                          client: client,
                          onPressed: () {
                            // Handle the card press action
                            // For example, navigate to client details page
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => ClientDetailsPage(client: client), // Assuming you have a ClientDetailsPage
                            //   ),
                            // );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.accentColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ClientForm(), // Assuming you have a ClientDetailsPage
            ),
          );
        },
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
    );
  }
}
