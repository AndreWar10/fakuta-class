import 'package:flutter/material.dart';
import '../../domain/entities/planet.dart';

class PlanetDetailsModal extends StatelessWidget {
  final Planet planet;

  const PlanetDetailsModal({
    super.key,
    required this.planet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Planet Header
                  _buildPlanetHeader(),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  _buildDescription(),
                  
                  const SizedBox(height: 24),
                  
                  // Key Facts
                  _buildKeyFacts(),
                  
                  const SizedBox(height: 24),
                  
                  // Detailed Facts
                  _buildDetailedFacts(),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetHeader() {
    return Row(
      children: [
        // Planet Image
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              planet.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    _getPlanetIcon(),
                    color: Colors.white,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Planet Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planet.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getTypeColor().withOpacity(0.5),
                  ),
                ),
                child: Text(
                  planet.type.toUpperCase(),
                  style: TextStyle(
                    color: _getTypeColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          planet.description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações Principais',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFactCard(
                'Distância do Sol',
                '${planet.distanceFromSun.toStringAsFixed(1)} M km',
                Icons.wb_sunny,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFactCard(
                'Diâmetro',
                '${planet.diameter.toStringAsFixed(0)} km',
                Icons.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFactCard(
                'Luas',
                '${planet.moons}',
                Icons.satellite_alt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFactCard(
                'Tipo',
                planet.type,
                _getTypeIcon(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFactCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedFacts() {
    if (planet.facts.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Curiosidades',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...planet.facts.entries.map((entry) => _buildFactRow(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildFactRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement explore more
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Explorar Mais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement share
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getTypeColor(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Compartilhar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (planet.type) {
      case 'terrestre':
        return const Color(0xFF8D6E63);
      case 'gasoso':
        return const Color(0xFF5E35B1);
      case 'anão':
        return const Color(0xFF546E7A);
      case 'estrela':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF424242);
    }
  }

  IconData _getTypeIcon() {
    switch (planet.type) {
      case 'terrestre':
        return Icons.public;
      case 'gasoso':
        return Icons.cloud;
      case 'anão':
        return Icons.radio_button_unchecked;
      case 'estrela':
        return Icons.wb_sunny;
      default:
        return Icons.public;
    }
  }

  IconData _getPlanetIcon() {
    return _getTypeIcon();
  }
}
