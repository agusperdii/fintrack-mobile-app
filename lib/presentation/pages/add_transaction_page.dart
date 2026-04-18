import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../atoms/glass_card.dart';
import '../atoms/ambient_glow.dart';
import 'transaction_success_page.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String _type = 'Expense'; 
  final _titleController = TextEditingController(); 
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Coffee', 'icon': Icons.coffee},
    {'name': 'Transport', 'icon': Icons.directions_car},
    {'name': 'Tools', 'icon': Icons.edit_note},
    {'name': 'Web', 'icon': Icons.wifi},
    {'name': 'Fun', 'icon': Icons.theater_comedy},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tolong masukkan nominal yang valid')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await sl.financeRepository.addTransaction(
        title: _titleController.text.isEmpty ? 'Transaksi $_selectedCategory' : _titleController.text,
        amount: double.parse(_amountController.text) * (_type == 'Expense' ? -1 : 1),
        category: _selectedCategory,
        type: _type,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TransactionSuccessPage()),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: AppBar(
        backgroundColor: KineticVaultTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: KineticVaultTheme.primary),
          onPressed: () => Navigator.pop(context), 
        ),
        title: Text(
          'Tambah Transaksi',
          style: GoogleFonts.plusJakartaSans(
            color: KineticVaultTheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Text(
                'NEON',
                style: GoogleFonts.plusJakartaSans(
                  color: KineticVaultTheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned(
            top: 50,
            left: -150,
            child: AmbientGlow(size: 600, color: KineticVaultTheme.primary, opacity: 0.03),
          ),
          const Positioned(
            bottom: 150,
            right: -150,
            child: AmbientGlow(size: 600, color: KineticVaultTheme.secondary, opacity: 0.03),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'JUMLAH NOMINAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: KineticVaultTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Rp',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: KineticVaultTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: KineticVaultTheme.onSurface,
                          letterSpacing: -1,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: KineticVaultTheme.onSurface.withValues(alpha: 0.2)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      _buildTypeToggleItem(
                        label: 'Pengeluaran',
                        icon: Icons.arrow_outward,
                        isActive: _type == 'Expense',
                        activeColor: KineticVaultTheme.errorContainer,
                        onTap: () => setState(() => _type = 'Expense'),
                      ),
                      _buildTypeToggleItem(
                        label: 'Pemasukan',
                        icon: Icons.south_west,
                        isActive: _type == 'Income',
                        activeColor: KineticVaultTheme.surfaceContainerHighest,
                        onTap: () => setState(() => _type = 'Income'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Kategori',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: KineticVaultTheme.onSurface,
                      ),
                    ),
                    Text(
                      'Lihat Semua',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KineticVaultTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['name']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: KineticVaultTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? KineticVaultTheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected 
                                  ? KineticVaultTheme.primary.withValues(alpha: 0.2)
                                  : KineticVaultTheme.surfaceContainerHigh,
                              ),
                              child: Icon(
                                cat['icon'],
                                color: isSelected ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat['name'].toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: isSelected ? KineticVaultTheme.primary : KineticVaultTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: KineticVaultTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: KineticVaultTheme.secondary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Waktu & Tanggal',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildBentoValueItem(label: 'Hari Ini, 24 Mei 2024', icon: Icons.expand_more),
                          const SizedBox(height: 8),
                          _buildBentoValueItem(label: '14:30 WIB', icon: Icons.schedule),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: KineticVaultTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.description, color: KineticVaultTheme.tertiary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Catatan',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _titleController,
                            maxLines: 3,
                            style: GoogleFonts.inter(fontSize: 12, color: KineticVaultTheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Makan siang bareng temen...',
                              hintStyle: TextStyle(color: KineticVaultTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              border: InputBorder.none,
                              fillColor: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              filled: true,
                              contentPadding: const EdgeInsets.all(12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: KineticVaultTheme.primary.withValues(alpha: 0.3)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 16,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress Tabungan',
                                style: GoogleFonts.plusJakartaSans(
                                  color: KineticVaultTheme.tertiary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Sisa budget makan kamu masih aman!',
                                style: GoogleFonts.inter(
                                  color: KineticVaultTheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '82%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: KineticVaultTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.82,
                          minHeight: 6,
                          backgroundColor: KineticVaultTheme.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(KineticVaultTheme.tertiary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120), 
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [KineticVaultTheme.background.withValues(alpha: 0), KineticVaultTheme.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KineticVaultTheme.primary,
                  foregroundColor: KineticVaultTheme.onPrimaryFixed,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 20,
                  shadowColor: KineticVaultTheme.primary.withValues(alpha: 0.4),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        'SIMPAN TRANSAKSI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggleItem({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : KineticVaultTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : KineticVaultTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoValueItem({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KineticVaultTheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: KineticVaultTheme.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icon, color: KineticVaultTheme.onSurfaceVariant, size: 14),
        ],
      ),
    );
  }
}
