import 'package:anihub/config/styles.dart';
import 'package:anihub/providers/searchprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        return BottomSheet(
          backgroundColor: Colors.grey.shade900,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          onClosing: () {},
          builder: (context) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Filters",
                          style: TextStyles.primaryTitle,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            provider.clearFilters();
                          },
                          child: const Text(
                            "Clear All",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Format",
                      style: TextStyles.secondaryTitle2,
                    ),
                    Wrap(
                      spacing: 8,
                      children: provider.formats.map((format) {
                        final isSelected = provider.selectedFormats.contains(format);
                        return FilterChip(
                          label: Text(format),
                          selected: isSelected,
                          onSelected: (_) => provider.toggleFormat(format),
                          selectedColor: Colors.red.withOpacity(0.2),
                          checkmarkColor: Colors.red,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.red : Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Season",
                      style: TextStyles.secondaryTitle2,
                    ),
                    Wrap(
                      spacing: 8,
                      children: provider.seasons.map((season) {
                        final isSelected = provider.selectedSeasons.contains(season);
                        return FilterChip(
                          label: Text(season),
                          selected: isSelected,
                          onSelected: (_) => provider.toggleSeason(season),
                          selectedColor: Colors.red.withOpacity(0.2),
                          checkmarkColor: Colors.red,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.red : Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Year",
                      style: TextStyles.secondaryTitle2,
                    ),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 30, // Show last 30 years
                        itemBuilder: (context, index) {
                          final year = DateTime.now().year - index;
                          final isSelected = provider.selectedYear == year;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(year.toString()),
                              selected: isSelected,
                              onSelected: (_) => provider.setYear(isSelected ? null : year),
                              selectedColor: Colors.red.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.red : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // Refresh search with new filters
                          // if (provider.currentQuery.isNotEmpty) {
                          //   provider.searchAnime(provider.currentQuery, refresh: true);
                          // }
                        },
                        child: const Text("Apply Filters"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
