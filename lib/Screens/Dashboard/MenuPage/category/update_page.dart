import 'dart:io';

import 'package:amtnew/data/model/category_modal.dart';
import 'package:amtnew/widgets/Snackbars/dismissed_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/features/category/category_provider.dart';
import '../../../../core/utils/image_picker.dart';


class UpdatePage extends ConsumerStatefulWidget {
  const UpdatePage({super.key,required this.category});
  final CategoryModal category;

  @override
  ConsumerState<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends ConsumerState<UpdatePage> {

  @override
  void initState() {
    final category = ref.read(categoryNotifierProvider).value!.categoryMap[widget.category.id!]!;
    currentFilePath =category.imageUrl;
    _nameCtr = TextEditingController(text: category.name);
    super.initState();
  }
  @override
  dispose(){
    super.dispose();
  _nameCtr.dispose();

  }
 late String? currentFilePath;
  late final TextEditingController _nameCtr ;
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  bool isPhotoPicked = false;
  CategoryModal newCategory=CategoryModal(name: "title");
  void _handlePickImage() async {
    final File? image = await pickImageFile();

    if (image != null) {
      setState(() {
        currentFilePath = image.path;
        isPhotoPicked = true;
      });
    }
  }
  void _formCancel() {
    setState(() {
      currentFilePath = widget.category.imageUrl;
      isPhotoPicked = false;
      _nameCtr.text = widget.category.name;
    });
  }

  Future<void> _updateSave()async{
    //check photo update or not
    if(currentFilePath !=widget.category.imageUrl || currentFilePath !=null){
      newCategory = newCategory.copyWith(imageUrl: currentFilePath);
    }
    /// first form with detail like name(for now we have only one filled to update
    if(!_formKey.currentState!.validate()) {
      showSingleSnackBar(message: "Please check filled details");
      return;
    }

    try{


      if (currentFilePath == widget.category.imageUrl ||
          currentFilePath == null) {
        /// update only name(form related attributes only) , no image:
        await ref.read(categoryNotifierProvider.notifier).updateCategory(
            newCategory,CategoryMagicJson(name: true,id: true));
        showSingleSnackBar(message: "Category updated");
        return;
      }
      /// update with image as well
      await ref.read(categoryNotifierProvider.notifier).uploadImageAndUpdate(
          newCategory,CategoryMagicJson(name: newCategory.name != widget.category.name,imageUrl: currentFilePath != widget.category.imageUrl,id: true));
    }catch(e,st){
      debugPrint(e.toString());
      debugPrint(st.toString());

    }
    showSingleSnackBar(message: "Category updated");
  }
  void _formSave() async{

    //todo need to verify if any category already exist or not if yes return with scaffold or text field error:
    /// only try to copy those attributes which comes in the form in our case it is /name/:
    if(!_formKey.currentState!.validate())return;
    newCategory = newCategory.copyWith(name: _nameCtr.text.trim(),id: widget.category.id);

  }

  String? _nameValidator(String? name) {

    if (name == null || name.trim().isEmpty) {
      return "Name is required";
    }

    final trimmedName = name.trim().toLowerCase();
    // Check in local categories

    final tCategories = ref.read(categoryNotifierProvider).asData?.value.categories ?? [];
    ///todo we need to update this condition when we have unique value depends on deleted columns to give access the user to create new category with older category name that had been deleted by user, but they are available in table
    /// make sure to update this after applying changes in db constrains
    final dbCategories = tCategories.any((cat)=> cat.name.trim().toLowerCase()==trimmedName && widget.category.id !=cat.id );


      if ( dbCategories) {
        return "This category already exists";
      }



    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * 0.6;
    final colorScheme = Theme.of(context).colorScheme;
   final categoryAsyncState =  ref.watch(categoryNotifierProvider);
   final categoryData = categoryAsyncState.asData!.value.categoryMap[widget.category.id!]!;
    return Scaffold(
      appBar: AppBar(title: Text(categoryData.name),),
      body:  SingleChildScrollView(
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
               _buildForm(colorScheme, size)

                ,
              ),
            ),

          ],
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
                    ? isPhotoPicked?Image.file(File(currentFilePath!),fit: BoxFit.cover,):Image.network(
                 currentFilePath!,
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
