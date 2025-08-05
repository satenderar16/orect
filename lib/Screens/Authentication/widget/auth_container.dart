
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../widgets/Constants/auth_constants.dart';
import '../../../widgets/animated_size.dart';
class AuthContainer extends StatefulWidget {
  final Widget child;
  final String title;
  const AuthContainer({super.key,required this.child,this.title ="Title"});

  @override
  State<AuthContainer> createState() => _AuthContainerState();
}

class _AuthContainerState extends State<AuthContainer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar:kIsWeb?null: AppBar(automaticallyImplyLeading: true,title: Text(widget.title),),
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 600;
              final cardWidth = isTablet ? 400.0 : constraints.maxWidth * 0.9 ;
              return SingleChildScrollView(
                child: Align(alignment: Alignment.center,
                  child: AnimatedSizeContainer(
                    curve: Curves.bounceInOut,
                    child: SizedBox(
                      width: cardWidth,
                      child: authContainer(context: context, child: widget.child)
                    ),
                  ),
                ),
              );
            },
          ),
        )
    );
  }

}

//main container in auth page

Container authContainer({required BuildContext context, required Widget child}){
  return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(
          width: 1,
          color:Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        borderRadius: BorderRadius.circular(kMainContainerBorderRadius),
      ),
      padding:const EdgeInsets.symmetric(horizontal: kMainContainerPaddingHorizontal,vertical: kMainContainerPaddingVertical),
      child: child
  );
}

