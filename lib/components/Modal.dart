import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Modal extends StatefulWidget {
  @override
  _Modal createState() => _Modal();
}

class _Modal extends State<Modal> {
  bool isOverlayVisible = false;

  void toggleOverlayVisibility() {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background content (e.g., your app's content)
        Center(
          child: ElevatedButton(
            onPressed: () {
              toggleOverlayVisibility();
            },
            child: Text('Show Full Overlay'),
          ),
        ),
        // Modal overlay (conditionally visible)
        if (isOverlayVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                toggleOverlayVisibility(); // Close the overlay on tap
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                // Semi-transparent background color
                child: Center(
                  child: Container(
                    width: Get.width * 0.8, // Adjust width as needed
                    height: Get.height * 0.8, // Adjust height as needed
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'This is a Full-Screen Overlay',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            toggleOverlayVisibility(); // Close the overlay
                          },
                          child: Text('Close Overlay'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
