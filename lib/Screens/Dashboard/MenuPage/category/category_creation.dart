import 'dart:async';
import 'dart:io';

import 'package:amtnew/core/features/category/category_notifier.dart';
import 'package:amtnew/core/features/category/category_provider.dart';
import 'package:amtnew/core/utils/base_color_list.dart';
import 'package:amtnew/data/model/category_modal.dart';
import 'package:amtnew/widgets/bottom_sheet/two_large_buttom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_initializer.dart';
import '../../../../core/utils/image_picker.dart';
Future<void> showProgressNotification({
  required String title,
  required String body,
  int? progress,
  int? max,
}) async {
  final androidDetails = AndroidNotificationDetails(
    'progress_channel',
    'Progress Notifications',
    channelDescription: 'Shows progress during save operation',
    importance: Importance.high,
    priority: Priority.high,
    showProgress: progress != null && max != null,
    maxProgress: max ?? 0,
    progress: progress ?? 0,
    onlyAlertOnce: true,
  );

  final notificationDetails = NotificationDetails(android: androidDetails);

  await notificationsPlugin.show(
    0, // Persistent notification ID
    title,
    body,
    notificationDetails,
  );
}
Future<void> cancelNotification() async {
  await notificationsPlugin.cancel(0); // 0 is the notification ID you used in show()
}




class CategoryCreatePage extends ConsumerStatefulWidget {
  const CategoryCreatePage({super.key});

  @override
  ConsumerState<CategoryCreatePage> createState() => _CategoryCreatePageState();
}

class _CategoryCreatePageState extends ConsumerState<CategoryCreatePage> {

  String? currentFilePath;
  bool showForm = false;
  final TextEditingController _nameCtr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  List<CategoryModal> categories = [];

  @override
  void dispose() {
    _nameCtr.dispose();
    super.dispose();
  }


  void _handlePickImage() async {
    final File? image = await pickImageFile();

    if (image != null) {
      setState(() {
        currentFilePath = image.path;
      });
    }
  }

  void _formCancel() {
    setState(() {
      showForm = !showForm;
      currentFilePath = null;
    });
  }

  void _formSave() {

    //todo need to verify if any category already exist or not if yes return with scaffold or text field error:
    if(!_formKey.currentState!.validate())return;
    setState(() {
      categories.add(
        CategoryModal(
          name: _nameCtr.text.trim().toString(),
          imageUrl: currentFilePath,
        ),
      );
      showForm = !showForm;
      currentFilePath = null;
    });
    _nameCtr.clear();
  }
  String? _nameValidator(String? name) {

    if (name == null || name.trim().isEmpty) {
      return "Name is required";
    }

    final trimmedName = name.trim().toLowerCase();

    // Check in local categories
    final alreadyExistsLocally = categories.any(
          (cat) => cat.name.trim().toLowerCase() == trimmedName,
    );
    final tCategories = ref.read(categoryNotifierProvider).asData?.value.categories ?? [];
    final dbCategories = tCategories.any((cat)=> cat.name.trim().toLowerCase()==trimmedName);
    if(dbCategories){

    if (alreadyExistsLocally || dbCategories) {
      return "This category already exists";
    }

}


    return null;
  }


  Future<void> saveToDb(List<CategoryModal> categories) async {
    if(categories.isEmpty)return;
    final categoryNotifier = ref.read(categoryNotifierProvider.notifier);

    try {
      // Step 1: Insert categories

      List<CategoryModal> inserted = await _categoryInsert(categories, categoryNotifier);

      //step:2 uploading & compression

      List<CategoryModal> uploadedCategory = [];


      for (int i = 0; i < inserted.length; i++) {
        final category = inserted[i];

        if (category.imageUrl == null) {
          uploadedCategory.add(category);
        } else {
          final path = await categoryNotifier.uploadImage(category);
          uploadedCategory.add(category.copyWith(imageUrl: path));
        }

        await showProgressNotification(
          title: "Uploading Images",
          body: "Uploading ${i + 1} of ${inserted.length}",
          progress: i + 1,
          max: inserted.length,
        );


      }

      debugPrint("Step 3 complete");
      // Step 3: Update DB with url

      await showProgressNotification(
        title: "Updating ",
        body: "Finalizing... ",
      );

      await categoryNotifier.updateCategories(uploadedCategory,CategoryMagicJson(id: true,imageUrl: true,));
      // Step 4: Done

      await showProgressNotification(
        title: "Completed",
        body: "All categories saved successfully!",
      );

      setState(() {
        categories.clear();
      });

    } catch (e, st) {
      debugPrint('Unexpected error in saveToDb: $e\n$st');
      await showProgressNotification(
        title: "Failed",
        body: e.toString(),
      );
    }
  }

  Future<List<CategoryModal>> _categoryInsert(List<CategoryModal> categories, CategoryNotifier categoryNotifier) async {
    try{
      await showProgressNotification(
        title: "Saving",
        body: "Inserting categories...",
      );


      final sortedCategories = [...categories]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      final inserted = await categoryNotifier.addCategories(sortedCategories);
      debugPrint("Step 1 complete");

      final nameToImageUrl = {
        for (var item in sortedCategories)
          if (item.imageUrl != null) item.name: item.imageUrl!
      };

      final insertImage = inserted.map((item) {
        final imageUrl = nameToImageUrl[item.name];
        return imageUrl != null ? item.copyWith(imageUrl: imageUrl) : item;
      }).toList();
      return insertImage;
    }catch(e){
      throw "Error while inserting";
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * 0.6;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        // If the form is currently open, close it instead of navigating away

        if (showForm) {
          setState(() {
            showForm = false;
          });
          return;
        }
        if(categories.isEmpty){
          context.pop();
          return;
        }
        // Prompt the user for confirmation before leaving the page
        final shouldExit = await twoLargeButtonBottomSheet(
          context: context,
          title: "Discard changes?",
          subtitle: "You have unsaved data. Leaving now will lose your changes.",
          fillButtonText: "Stay",
          outlineButtonText: "Leave",
          outlineOnPressed: () {
            context.pop(true);  // User chooses to leave
          },
          fillOnPressed: () {
            context.pop(false); // User chooses to stay
          },
        );
        await Future.delayed(Duration(milliseconds: 200));

        if (shouldExit == true) {
         context.pop(); // Exit the page
        }
      },
      child: Hero(
        tag: 'fabToPage',

        child: Scaffold(
          appBar: AppBar(title: Text("Add"),actions: [
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(onPressed: ()async{await saveToDb(categories);}, child: Text("save")),
          )],),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                SizedBox(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),

                    curve: Curves.easeInOut,
                    child:
                        showForm?_buildForm(colorScheme, size)
                            : _buildContainer(colorScheme)
                            ,
                  ),
                ),

                if (categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text("Added"),
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: ListView.separated(
                            separatorBuilder:
                                (context, index) =>
                                    Divider(height: 0, thickness: 0),
                            shrinkWrap: true,
                            itemCount: categories.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return CategoryListItem(
                                key: ValueKey(category.id ?? category.name),
                                category: category,
                                index: index,
                                onDelete: () {
                                  setState(() {
                                    categories.removeAt(index);
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Center _buildContainer(ColorScheme colorScheme) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: 300,
          minWidth: 150,
          maxHeight: 300,
          minHeight: 150,
        ),

        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant, width: 0.0),
          ),

          child: Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showForm = !showForm;
                });
              },
              child: Text("Add"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ColorScheme colorScheme, double size) {
    bool hasValidFilePath =
        currentFilePath != null && currentFilePath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //todo we can refactor this widget for more screens. where image is required:
        //Image section
        Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          constraints: BoxConstraints(
            maxWidth: 300,
            minWidth: 150,
            maxHeight: 300,
            minHeight: 150,
          ),

          child: Stack(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.bottomRight,
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 0.0,
                  ),
                ),
                width: size,
                height: size,
                child:
                    hasValidFilePath
                        ? Image.file(
                          File(currentFilePath!),
                          fit: BoxFit.cover,
                          isAntiAlias: true,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  Center(child: Text("Invalid image")),
                        )
                        : Center(
                          child: ElevatedButton(
                            onPressed: _handlePickImage,
                            child: Text("Add image"),
                          ),
                        ),
              ),
              if (hasValidFilePath)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CircleAvatar(
                    child: IconButton(
                      onPressed: _handlePickImage,
                      icon: Icon(Icons.add_photo_alternate),
                    ),
                  ),
                ),
            ],
          ),
        ),

        ///we can add more section like this one when required field are more in category
        //todo  implementing same ui for the item and options to get consistency in ui and refactoring the code
        ///we are implementing save per section like details, so user get info to change data we fallback with error in each section:
        //detail section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: Text("details")),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorScheme.surfaceContainerLowest,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 8,
                    children: [
                      //todo we can refactor for multiple field requirement in future
                      ///multiple field with it title can be use via refactoring this section:
                      ///implementing save button for each section
                      ///below widget is just one text field so we are directly use it for more textfield we'll refactor the code
                      Consumer(
                        builder: (context,ref,child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text("Name"),
                              TextFormField(
                                key: _nameKey,
                                onTapOutside: (_) {
                                  FocusScope.of(context).unfocus();
                                },
                                onTap: (){
                                  if(_nameKey.currentState!.hasError){
                                    final text = _nameCtr.text.trim().toString();
                                    _nameKey.currentState?.reset();
                                    _nameCtr.text = text;
                                  }

                                },

                                validator: _nameValidator,
                                maxLines: null, // allows multiline
                                maxLength: 60, // character limit
                                controller: _nameCtr,
                                decoration: InputDecoration(
                                  hintText: 'E.g. Electronics',
                                  counterText: '',
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: 20),
                      Row(
                        spacing: 12,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: TextButton(
                              onPressed: _formCancel,
                              child: Text("cancel"),
                            ),
                          ),

                          Flexible(
                            child: ElevatedButton(
                              onPressed: _formSave,
                              child: Text("Save"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        //save and add more category section
      ],
    );
  }
}

















class CategoryListItem extends StatefulWidget {
  final int index;
  final CategoryModal category;
  final VoidCallback onDelete;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onDelete,
    required this.index,
  });

  @override
  State<CategoryListItem> createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<CategoryListItem>
    with TickerProviderStateMixin {
  bool isDeleted = false;
  List<Color> colors = colorList;

  Widget _buildCategoryLeading(String? path) {
    Color color = colors[widget.index % colors.length];
    bool hasValidFilePath = path != null && path.trim().isNotEmpty;
    const double size = 56;
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withAlpha(30),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            hasValidFilePath
                ? Image.file(File(path), fit: BoxFit.cover)
                : Center(
                  child: Text(
                    widget.category.name.toString().toUpperCase()[0],
                    style: TextTheme.of(
                      context,
                    ).bodyMedium?.copyWith(color: color.withAlpha(240)),
                  ),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child:
          isDeleted
              ? const SizedBox.shrink()
              : ListTile(
                contentPadding: const EdgeInsets.all(12.0),
                leading: _buildCategoryLeading(widget.category.imageUrl),
                title: Text(widget.category.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_outlined),
                  onPressed: () async {
                    setState(() => isDeleted = true);
                  },
                ),
              ),
    );
  }
}
