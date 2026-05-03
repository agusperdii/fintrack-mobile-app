import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savaio/core/theme/app_theme.dart';
import 'package:savaio/core/utils/service_locator.dart';
import 'package:savaio/views/components/atoms/app_heading.dart';
import 'package:savaio/views/components/atoms/app_button.dart';
import 'package:savaio/views/pages/add_transaction_page.dart';
import 'package:savaio/models/ocr_result.dart';

class OcrScanPage extends StatefulWidget {
  const OcrScanPage({super.key});

  @override
  State<OcrScanPage> createState() => _OcrScanPageState();
}

class _OcrScanPageState extends State<OcrScanPage> {
  @override
  void dispose() {
    sl.ocrController.clear();
    super.dispose();
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SavaioTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppHeading('Ambil Foto Struk', size: AppHeadingSize.h3),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: SavaioTheme.primary),
                title: const Text('Kamera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  sl.ocrController.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: SavaioTheme.primary),
                title: const Text('Galeri', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  sl.ocrController.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processScan() async {
    final success = await sl.ocrController.startScan();
    if (success && mounted) {
      final result = sl.ocrController.scanResult!;
      _showResultDialog(result);
    }
  }

  void _showResultDialog(OcrResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SavaioTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeading('Hasil Scan AI', size: AppHeadingSize.h3),
            const SizedBox(height: 24),
            _buildResultRow('Merchant', result.merchantName),
            _buildResultRow('Tanggal', result.transactionDate),
            _buildResultRow('Total', 'Rp ${result.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 24),
            const AppHeading('Line Items', size: AppHeadingSize.subtitle, isBold: true),
            const SizedBox(height: 12),
            ...result.lineItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.itemName, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                  Text('x${item.itemQuantity}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 12),
                  Text('Rp ${item.itemPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            const SizedBox(height: 32),
            AppButton(
              label: 'KONFIRMASI & LANJUT',
              onTap: () {
                Navigator.pop(context); // Close sheet
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionPage(
                      initialTitle: result.merchantName,
                      initialAmount: result.totalAmount,
                      initialType: 'Expense',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavaioTheme.background,
      appBar: AppBar(
        backgroundColor: SavaioTheme.background,
        elevation: 0,
        centerTitle: true,
        title: const AppHeading('Scan Struk AI', size: AppHeadingSize.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SavaioTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListenableBuilder(
        listenable: sl.ocrController,
        builder: (context, _) {
          final controller = sl.ocrController;
          
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: SavaioTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SavaioTheme.primary.withValues(alpha: 0.1)),
                    ),
                    child: controller.selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(controller.selectedImage!, fit: BoxFit.contain),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long, size: 80, color: SavaioTheme.primary.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum ada foto terpilih',
                                style: TextStyle(color: SavaioTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                if (controller.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(controller.error!, style: const TextStyle(color: SavaioTheme.error)),
                  ),
                if (controller.selectedImage == null)
                  AppButton(
                    label: 'AMBIL FOTO STRUK',
                    onTap: _showImagePickerOptions,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'GANTI FOTO',
                          variant: AppButtonVariant.secondary,
                          onTap: _showImagePickerOptions,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'MULAI SCAN',
                          isLoading: controller.isLoading,
                          onTap: _processScan,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
