
import 'dart:ui';

import 'package:amtnew/core/features/auth/auth_provider.dart';
import 'package:amtnew/core/config/connectivity/internet_provider.dart';
import 'package:amtnew/widgets/Snackbars/dismissed_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/router/app_router.dart';
import '../../../widgets/bottom_sheet/two_large_buttom.dart';
import '../../../widgets/forms/reset_password_form.dart';
import 'home_widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<HomePage> {
  bool _bottomSheetShown = false;

  bool retryBool = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final passState = ref.read(passwordResetCompletedProvider);
      if (passState && !_bottomSheetShown) {
        _bottomSheetShown = true;
        _showResetPopUp();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final authRepo = ref.watch(authNotifierProvider.notifier);
    final resetState = ref.watch(passwordResetCompletedProvider);
    final interNetState = ref.watch(internetProvider);
    final internetNotifier = ref.watch(internetProvider.notifier);
    retryConnection() async {
      if (!retryBool) {
        retryBool = true;
        internetNotifier.retryConnection();
        showSingleSnackBar(message: "checking....", isAction: false);
        await Future.delayed(Duration(seconds: 5));
        if (interNetState.hasInternet) {
          showSingleSnackBar(message: "Back online");
          return;
        }
        showSingleSnackBar(message: "No internet", isAction: false);
        retryBool = false;
      }
    }

    Widget noInternetScreen = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      Image.asset("assets/image_offline_login.png", fit: BoxFit.contain),

      Text(
        "No Internet Connection",
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        "Please check your network settings and try again.",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      OutlinedButton(onPressed: retryConnection, child: Text("Retry")),
    ],);

    Future<void> _refresh()async{
      debugPrint("hello");
      await Future.delayed(Duration(seconds: 3));
      return;
    }
    return PopScope(
      canPop: false, // prevent automatic pop
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        // extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons
                    .person, // Replace with SvgPicture.asset('...') if using flutter_svg
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          centerTitle: false,
          title: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: [
                const TextSpan(text: 'Welcome back,\n'),
                TextSpan(
                  text: 'Username',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            Chip(
              shape: const CircleBorder(),
              backgroundColor: Theme.of(context).colorScheme.surface,
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0,
              ),

              label: Icon(
                Icons.notifications,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child:!interNetState.hasInternet?noInternetScreen: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                _buildTopContainer(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text("Orders"),
                ),
                _buildOrderGrid(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text("Pending orders"),
                      Spacer(),
                      TextButton(onPressed: () {}, child: Text("see all")),
                    ],
                  ),
                ),
                _pendingOrders(context,6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text("category collection"),
                      Spacer(),
                      TextButton(onPressed: () {}, child: Text("see all")),
                    ],
                  ),
                ),
                _buildCategoryPercentage(context),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pendingOrders(BuildContext context,int orders) {
    final isEmpty = orders==0;
    if (isEmpty) {
      return Container(

        alignment: Alignment.center,
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
            Image.asset(
              'assets/empty_list_placeholder.png', // Path to your placeholder image
              fit: BoxFit.contain,
              height: 120,

            ),
            Text(
              "Well done! ",style: TextTheme.of(context).titleLarge,
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20,),
                child: Row(
                  children: [...List.generate(orders, (index) {
                    return Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // ← this allows dynamic height
                          children: [
                            // Order Details
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Order ID & Amount Row
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "#1DSHFSDFHS2${30 + index}".toUpperCase(),
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "₹245",
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "OrderName",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Divider and button row
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Cancel button
                                  Expanded(
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {},
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant,width: 0),
                                            right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant,width: 0),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child:  Text(
                                          "Cancel",
                                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Confirm button
                                  Expanded(
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {},
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color:  Theme.of(context).colorScheme.outlineVariant,width: 0),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: const Text(
                                          "Confirm",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                  }),
                    if(orders>=6)
                    CupertinoButton(color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: Text("see all"),onPressed: (){}, ),],
                ),

    );
  }

  SingleChildScrollView _buildCategoryPercentage(BuildContext context) {
    return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    spacing: 10,
                    children: [
                      ...List.generate(5, (index) {
                        return Container(
                          width: 100,
                          height: 150,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),

                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,
                          ),
                          child: Column(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularPercentage(
                                  collection: 698,
                                  cash: 276,
                                  stroke: 4,
                                  imageChild: Image.asset(
                                    "assets/image_circle.jpeg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                "${(130.0 / 500.0) * 100}%",
                                style: TextTheme.of(context).labelSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Category$index",
                                style: TextTheme.of(context).labelMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }),

                      CupertinoButton(
                        onPressed: (){

                        },
                        padding: EdgeInsets.zero,
                        sizeStyle: CupertinoButtonSize.small,
                        child: Container(
                          width: 100,
                          height: 150,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),

                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,
                          ),
                          child: Text(
                            "See all",
                            style: TextTheme.of(context).bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }

  Card _buildTopContainer(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        TextSpan(
                          //todo get data form the provider for total sell:
                          text: "₹458\n",
                          style: TextTheme.of(context).headlineMedium?.copyWith(
                           fontWeight: FontWeight.w400
                          ),
                        ),
                        TextSpan(
                          text: 'Today\'s collection',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),

                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 5,
                    children: [
                      Chip(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width:0 ,
                        ),
                        padding: EdgeInsets.all(4),
                        avatar: Icon(
                          Icons.currency_rupee_rounded,
                        ),
                        // todo filter the order by payment mode get sum: cash payments
                        label: Text("458"),
                      ),

                      Chip(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 0,
                        ),
                        padding: EdgeInsets.all(4),
                        avatar: Icon(
                          Icons.account_balance,
                        ),
                        // todo filter the order by payment mode get sum: cashless payment
                        label: Text("458"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: CircularPercentage(
                //todo get total and present them in cash vs cashless payment: where collected is cash:
                collection: 600,
                cash: 398,
                // imageChild: Image.asset("assets/just_image.jpeg",fit: BoxFit.cover,),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Padding _buildOrderGrid(BuildContext context){
    final List<DashboardCard> cards = [
      DashboardCard(
        title: "45",
        subtitle: "Orders",
        subSubtitle: "avg. order ₹1,24",
        icon: Icons.receipt_long,
        iconColor: Colors.blue,
      ),
      DashboardCard(
        title: "4",
        subtitle: "Pending",
        subSubtitle: "Awaiting confirmation",
        icon: Icons.pending_actions,
        iconColor: Colors.orange,
      ),
      DashboardCard(
        title: "34",
        subtitle: "Confirmed",
        subSubtitle: "₹1,24 cash •  ₹1,45 other",
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
      ),

      DashboardCard(
        title: "6",
        subtitle: "Cancelled",
        subSubtitle: "₹1,240 refund",
        icon: Icons.block,
        iconColor: Colors.red,
      ),


    ];
   return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: MasonryGridView.extent(
        maxCrossAxisExtent: 250, //
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        itemBuilder: (BuildContext context, int index) {
          return cards[index];
        },
      ),
    );
  }

  void _showResetPopUp() {
    twoLargeButtonBottomSheet(
      context: context,
      title: "Reset Password",
      subtitle: "Reset your password now?",
      fillButtonText: 'Reset Now',
      outlineButtonText: "Later",
      outlineOnPressed: () {
        context.pop();
        ref.read(passwordResetCompletedProvider.notifier).state = false;
      },
      fillOnPressed: () {
        context.pop(); // Close the prompt
        Future.delayed(const Duration(milliseconds: 250), () {
          _showResetFormSheet(); // Show the actual reset form
        });
      },
    );
  }

  void _showResetFormSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reset Password',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Optional helper text
                Text(
                  'Please enter a new password to continue using your account securely.',
                  style: TextTheme.of(context).bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                // Your form
                ResetPasswordForm(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

