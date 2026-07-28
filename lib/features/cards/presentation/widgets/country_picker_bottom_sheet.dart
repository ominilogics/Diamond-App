import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/country_code.dart';

class CountryPickerBottomSheet extends HookWidget {
  final CountryCode selectedCountry;

  const CountryPickerBottomSheet({
    super.key,
    required this.selectedCountry,
  });

  static Future<CountryCode?> show(
    BuildContext context, {
    required CountryCode selectedCountry,
  }) {
    return showModalBottomSheet<CountryCode>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => CountryPickerBottomSheet(
        selectedCountry: selectedCountry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text.trim().toLowerCase();
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final filteredCountries = useMemoized(() {
      if (searchQuery.value.isEmpty) return CountryCode.allCountries;
      return CountryCode.allCountries.where((c) {
        final nameMatch = c.name.toLowerCase().contains(searchQuery.value);
        final codeMatch = c.dialCode.toLowerCase().contains(searchQuery.value);
        final isoMatch = c.code.toLowerCase().contains(searchQuery.value);
        return nameMatch || codeMatch || isoMatch;
      }).toList();
    }, [searchQuery.value]);

    return SafeArea(
      child: Container(
        height: 480.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            // Top Drag Handle Pill
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Search Header
            Text(
              'Select Country',
              style: AppTextStyles.colitez400Italic20(),
            ),
            SizedBox(height: 16.h),

            // Search Input Field
            Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: AppTextStyles.roboto400Regular14(
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search country or code...',
                        hintStyle: AppTextStyles.roboto400Regular14(
                          color: const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () => searchController.clear(),
                      child: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Country List
            Expanded(
              child: ListView.separated(
                itemCount: filteredCountries.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Color(0xFFF1F5F9),
                ),
                itemBuilder: (context, index) {
                  final country = filteredCountries[index];
                  final isSelected = country == selectedCountry;

                  return InkWell(
                    borderRadius: BorderRadius.circular(10.r),
                    onTap: () => Navigator.pop(context, country),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 8.w,
                      ),
                      child: Row(
                        children: [
                          Text(
                            country.flag,
                            style: TextStyle(fontSize: 22.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              country.name,
                              style: AppTextStyles.roboto400Regular14(
                                color: isSelected
                                    ? const Color(0xFFFF5E60)
                                    : const Color(0xFF0F172A),
                              ).copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            country.dialCode,
                            style: AppTextStyles.roboto400Regular14(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          if (isSelected) ...[
                            SizedBox(width: 8.w),
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Color(0xFFFF5E60),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
