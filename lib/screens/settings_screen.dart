import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/product_provider.dart';
import '../services/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          Consumer<SettingsProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  SwitchListTile(
                    title: const Text('Stok Uyarı Bildirimleri'),
                    secondary: const Icon(Icons.notifications_active),
                    value: provider.isStockWarningEnabled,
                    onChanged: (value) {
                      provider.setStockWarningEnabled(value);
                    },
                  ),
                  ListTile(
                    enabled: provider.isStockWarningEnabled,
                    title: const Text('Minimum Stok Uyarısı'),
                    trailing: DropdownButton<int>(
                      value: provider.minStockLimit,
                      items: [5, 10, 20, 50].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: provider.isStockWarningEnabled
                          ? (val) {
                              if (val != null) {
                                provider.setMinStockLimit(val);
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Veritabanını Yedekle / Paylaş'),
            leading: const Icon(Icons.share),
            onTap: () async {
              await DatabaseHelper().exportDatabase();
            },
          ),
          ListTile(
            title: const Text('Yedeği İçe Aktar'),
            leading: const Icon(Icons.download),
            onTap: () async {
              bool success = await DatabaseHelper().importDatabase();
              if (success && context.mounted) {
                await context.read<ProductProvider>().fetchProducts();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Başarıyla içe aktarıldı')),
                  );
                }
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('İçe aktarma işleminde hata oluştu'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
