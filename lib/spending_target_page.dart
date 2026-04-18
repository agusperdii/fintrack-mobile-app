import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/kinetic_vault_theme.dart';
import 'widgets/ambient_glow.dart';
import 'widgets/glass_card.dart';
import 'services/api_service.dart';

class SpendingTargetPage extends StatefulWidget {
  const SpendingTargetPage({super.key});

  @override
  State<SpendingTargetPage> createState() => _SpendingTargetPageState();
}

class _SpendingTargetPageState extends State<SpendingTargetPage> {
  final _amountController = TextEditingController();
  String _selectedPeriod = 'Bulanan';
  bool _isSaving = false;
  bool _isLoading = true;

  final List<double> _quickAmounts = [1000000, 2000000, 5000000, 10000000];

  @override
  void initState() {
    super.initState();
    _loadCurrentTarget();
  }

  Future<void> _loadCurrentTarget() async {
    try {
      final data = await ApiService.getSpendingTarget();
      if (mounted) {
        setState(() {
          double amount = data['amount'];
          _amountController.text = amount > 0 ? amount.toStringAsFixed(0) : '';
          _selectedPeriod = data['period'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveTarget() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal target pengeluaran')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Target pengeluaran berhasil disimpan'),
            backgroundColor: KineticVaultTheme.tertiary,
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: KineticVaultTheme.background,
        body: Center(child: CircularProgressIndicator(color: KineticVaultTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: KineticVaultTheme.background,
      appBar: AppBar(
        backgroundColor: KineticVaultTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: KineticVaultTheme.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Target Pengeluaran',
          style: GoogleFonts.plusJakartaSans(
            color: KineticVaultTheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned(
            top: 50,
            right: -100,
            child: AmbientGlow(size: 400, color: KineticVaultTheme.secondary, opacity: 0.05),
          ),
          const Positioned(
            bottom: 50,
            left: -100,
            child: AmbientGlow(size: 400, color: KineticVaultTheme.primary, opacity: 0.05),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'TARGET $_selectedPeriod'.toUpperCase(),
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
                const SizedBox(height: 24),
                // Quick Amounts
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickAmounts.map((amt) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(
                            KineticVaultTheme.formatCurrency(amt),
                            style: GoogleFonts.inter(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold,
                              color: KineticVaultTheme.onSurface,
                            ),
                          ),
                          backgroundColor: KineticVaultTheme.surfaceContainerHighest,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          onPressed: () {
                            setState(() {
                              _amountController.text = amt.toStringAsFixed(0);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 48),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 16,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: KineticVaultTheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.info_outline, color: KineticVaultTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kenapa Atur Target?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: KineticVaultTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Target membantu Anda mencapai tujuan finansial lebih cepat dengan membatasi pengeluaran berlebih.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: KineticVaultTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: KineticVaultTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: KineticVaultTheme.outlineVariant.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Periode',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: KineticVaultTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPeriodItem('Harian'),
                      _buildPeriodItem('Mingguan'),
                      _buildPeriodItem('Bulanan'),
                      _buildPeriodItem('Tahunan'),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveTarget,
              style: ElevatedButton.styleFrom(
                backgroundColor: KineticVaultTheme.primary,
                foregroundColor: KineticVaultTheme.onPrimaryFixed,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 20,
                shadowColor: KineticVaultTheme.primary.withValues(alpha: 0.4),
              ),
              child: _isSaving
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: KineticVaultTheme.onPrimaryFixed))
                  : Text(
                      'SIMPAN TARGET',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodItem(String label) {
    bool isSelected = _selectedPeriod == label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => setState(() => _selectedPeriod = label),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? KineticVaultTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? KineticVaultTheme.primary.withValues(alpha: 0.3) : KineticVaultTheme.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? KineticVaultTheme.primary : KineticVaultTheme.onSurface,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: KineticVaultTheme.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
