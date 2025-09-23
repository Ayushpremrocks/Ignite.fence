// ================= widgets/custom_button.dart =================
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  // final String text;
  // final VoidCallback onPressed;
  // final Color? backgroundColor;

  // const CustomButton({ 
  //   super.key,
  //   required this.text,
  //   required this.onPressed,
  //   this.backgroundColor,  
  // }); 

  final String text;
  final VoidCallback onPressed;
  final Color? color; // optional background color
  final bool shadow; // optional shadow effect

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 45),
        backgroundColor: color ?? Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
        foregroundColor: Colors.white, // Default text color
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}