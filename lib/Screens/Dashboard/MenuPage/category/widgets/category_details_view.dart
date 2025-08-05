import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../data/model/category_modal.dart';


//detailed widget
class CategoryDetailsContent extends StatelessWidget {
  final CategoryModal category;
  final bool isMobile;
  final Color? color;

  const CategoryDetailsContent({
    super.key,
    required this.category,
    required this.isMobile,
    this.color,
  });
// todo this will be replace by the category details
  final List<Map<String, dynamic>> infoTiles = const [
    {
      'title': 'Subcategories',
      'count': 4, // Replace with your dynamic value
      'icon': Icons.category,
    },
    {
      'title': 'Items',
      'count': 12, // Replace with your dynamic value
      'icon': Icons.inventory_2,
    },
  ];

  String timeFormater(DateTime? at) {
    if (at == null) return "-";
    return DateFormat('dd MMM yyyy, h:mm a').format(at.toLocal());
  }



  @override
  Widget build(BuildContext context) {
    final photoSection = Stack(
      children: [
        // Full-width image
        Container(
          constraints: BoxConstraints(maxHeight: 500, minHeight: 300),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),

          child:
          category.imageUrl != null && category.imageUrl!.isNotEmpty
              ? Image.network(
            category.imageUrl!,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: double.infinity,
                height: 200, // Adjust based on your layout
                child: Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    size: 60,
                    color: Theme.of(context).colorScheme.onError, // icon color
                  ),
                ),
              ); // Custom fallback widget
            },
          )
              : SizedBox(
            width: double.infinity,
            height: 200, // Adjust based on your layout

            child: Center(
             child: Icon(Icons.image_not_supported,size: 60,color: color ?? Theme.of(context).iconTheme.color,),
            ),
          ),
        ),

        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha(150),
              radius: 16,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                    Theme.of(
                      context,
                    ).colorScheme.outlineVariant, // Border color
                    width: 0, // Border width
                  ),
                  color: Colors.transparent,

                  // color: Colors.blue
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    Container categoryDetailedSection = Container(
      margin: const EdgeInsets.all(16.0),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 0,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(category.name, style: Theme.of(context).textTheme.headlineSmall),

          Text(
            "Created • ${timeFormater(category.createdAt)}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            "Updated • ${timeFormater(category.updatedAt)}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          // Image with floating close button
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [photoSection, categoryDetailedSection],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text("information"),
                Card(

                  elevation: 0,

                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),

                  ),
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: infoTiles.length,
                    itemBuilder: (context, index) {
                      final tile = infoTiles[index];
                      return ListTile(
                        onTap: () {},
                        leading: Icon(
                          tile['icon'],
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(tile['title']),
                        trailing: Text(
                          '${tile['count']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    },
                    separatorBuilder:
                        (context, index) => const Divider(height: 0, thickness: 0.0),
                  ),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }

  Widget _fallbackImage(BuildContext context,{String? path}) {
  
    return SizedBox(
      width: double.infinity,
      height: 200, // Adjust based on your layout

      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          size: 60,
          color: Theme.of(context).colorScheme.outline, // icon color
        ),
      ),
    );
  }
}