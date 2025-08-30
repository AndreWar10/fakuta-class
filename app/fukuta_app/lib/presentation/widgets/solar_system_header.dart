import 'package:flutter/material.dart';

class SolarSystemHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final Function(String) onFilterChanged;
  final String currentFilter;

  const SolarSystemHeader({
    super.key,
    required this.onBackPressed,
    required this.onFilterChanged,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top Row with Back Button and Title
          Row(
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onBackPressed,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sistema Solar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Explore os planetas do nosso sistema',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Settings Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implement settings
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Todos', Icons.all_inclusive),
                const SizedBox(width: 12),
                _buildFilterChip('terrestre', 'Terrestres', Icons.public),
                const SizedBox(width: 12),
                _buildFilterChip('gasoso', 'Gasosos', Icons.cloud),
                const SizedBox(width: 12),
                _buildFilterChip('anão', 'Anões', Icons.radio_button_unchecked),
                const SizedBox(width: 12),
                _buildFilterChip('estrela', 'Estrelas', Icons.wb_sunny),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label, IconData icon) {
    final isSelected = currentFilter == type;
    
    return GestureDetector(
      onTap: () => onFilterChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.white.withOpacity(0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
