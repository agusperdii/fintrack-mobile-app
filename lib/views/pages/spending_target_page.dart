import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/service_locator.dart';
import '../components/atoms/glass_card.dart';
import '../components/atoms/app_button.dart';

class SpendingTargetPage extends StatefulWidget {
  const SpendingTargetPage({super.key});

  @override
  State<SpendingTargetPage> createState() => _SpendingTargetPageState();
}

class _SpendingTargetPageState extends State<SpendingTargetPage> {
  final _amountController = TextEditingController();
  late String _selectedPeriod;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Ambil initial value dari Provider (SSOT)
    final target = sl.financeController.spendingTarget;
    _amountController.text = target?['amount']?.toStringAsFixed(0) ?? '';
    _selectedPeriod = target?['period'] ?? 'Bulanan';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveTarget() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal target pengeluaran')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    // Update ke Provider
    await sl.financeController.updateSpendingTarget(amount, _selectedPeriod);
    
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
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 48),
                const GlassCard(
                  padding: EdgeInsets.all(24),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: KineticVaultTheme.primary, size: 20),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Target membantu Anda membatasi pengeluaran berlebih.',
                          style: TextStyle(fontSize: 12, color: KineticVaultTheme.onSurfaceVariant),
                        ),
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
            child: AppButton(
              label: 'SIMPAN TARGET',
              isLoading: _isSaving,
              onTap: _saveTarget,
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
