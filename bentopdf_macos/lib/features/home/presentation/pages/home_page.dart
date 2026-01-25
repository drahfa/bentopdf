import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdfcow/shared/models/tool_info.dart';
import 'package:pdfcow/features/home/presentation/widgets/tool_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'app.tagline'.tr(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'app.subtitle'.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[400],
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: ToolsConfig.tools.length,
                itemBuilder: (context, index) {
                  final tool = ToolsConfig.tools[index];
                  return ToolCard(tool: tool);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
