import 'package:flutter/material.dart';

class LeafInfoWidget extends StatelessWidget {
  final Map<String, dynamic> leafData;
  
  const LeafInfoWidget({Key? key, required this.leafData}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên gọi khác
        if (leafData['otherNames'] != null)
          _buildInfoRow(
            icon: Icons.label_outline,
            label: 'Tên gọi khác:',
            value: leafData['otherNames'].toString().isEmpty 
                ? 'Không có' 
                : leafData['otherNames'],
          ),
          
        // Tên khoa học
        if (leafData['scientificName'] != null)
          _buildInfoRow(
            icon: Icons.science,
            label: 'Tên khoa học:',
            value: leafData['scientificName'],
          ),
        
        // Phân bố
        if (leafData['distribution'] != null)
          _buildInfoRow(
            icon: Icons.map,
            label: 'Phân bố:',
            value: leafData['distribution'],
          ),
        
        // Tính chất
        if (leafData['natureProperties'] != null)
          _buildInfoRow(
            icon: Icons.spa,
            label: 'Tính chất:',
            value: leafData['natureProperties'],
          ),
        
        // Bộ phận sử dụng
        if (leafData['usedParts'] != null && 
            (leafData['usedParts'] as List).isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.medical_services, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text(
                'Bộ phận sử dụng:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  (leafData['usedParts'] as List).join(', '),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
        
        // Mô tả
        if (leafData['description'] != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Mô tả:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            leafData['description'],
            style: const TextStyle(fontSize: 14),
          ),
        ],
        
        // Công dụng chính
        if (leafData['mainBenefits'] != null && 
            (leafData['mainBenefits'] as List).isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Công dụng chính:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...(leafData['mainBenefits'] as List).map((benefit) => 
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      benefit.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
        
        // Cảnh báo đầy đủ
        if (leafData['warnings'] != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Cảnh báo:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          
          // Độc tính
          if (leafData['warnings']['toxicity'] != null)
            _buildWarningBox(leafData['warnings']['toxicity']),
          
          // Tác dụng phụ
          if (leafData['warnings']['sideEffects'] != null &&
              (leafData['warnings']['sideEffects'] as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Tác dụng phụ:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            ...(leafData['warnings']['sideEffects'] as List).map((effect) =>
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        effect.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ],
          
          // Chống chỉ định
          if (leafData['warnings']['contraindications'] != null &&
              (leafData['warnings']['contraindications'] as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Chống chỉ định:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            ...(leafData['warnings']['contraindications'] as List).map((item) =>
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ],
          
          // Lời khuyên bác sĩ
          if (leafData['warnings']['doctorAdvice'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_information, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      leafData['warnings']['doctorAdvice'],
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
        
        // Cách sử dụng
        if (leafData['usage'] != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Cách sử dụng:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          
          // Liều lượng tiêu chuẩn
          if (leafData['usage']['standardDose'] != null)
            _buildInfoRow(
              icon: Icons.medication,
              label: 'Liều lượng:',
              value: leafData['usage']['standardDose'],
            ),
          
          // Cách sử dụng cụ thể
          if (leafData['usage']['specificUsage'] != null &&
              (leafData['usage']['specificUsage'] as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Cách dùng cụ thể:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            ...(leafData['usage']['specificUsage'] as List).map((usage) => 
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ${usage['purpose']}:',
                      style: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        usage['recipe'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ).toList(),
          ],
        ],
        
        // Ghi chú
        if (leafData['notes'] != null && 
            (leafData['notes'] as List).isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Ghi chú:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (leafData['notes'] as List).map((note) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          note.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWarningBox(String toxicity) {
    final isNonToxic = toxicity == 'KHÔNG ĐỘC';
    final isLowToxic = toxicity == 'ÍT ĐỘC';
    final color = isNonToxic 
        ? Colors.green 
        : isLowToxic 
            ? Colors.yellow[700]! 
            : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Độc tính: $toxicity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}