# Custom ImagePickerController

The built in Swift ImagePickerController allows users to select only one image at a time, which is an inconvenient limitation for developers that want to provide users with the ability to send, share, or perform actions on multiple images at once.

This custom imagePickerController enables retrieval of multiple images.

## Setup

1. Add the photoLibraryController.swift, seeImageController.swift, and assetCell files to your Xcode Project.

2. Open the sample Xcode project. copy the view controllers in Main.storyboard into your project. Hook the IBOutlets in each class. The next update will include a viewController class that can be added to your project programmatically.

3. Build a segue to the PhotoLibraryController from the ViewController that you want to trigger its presentation.

4. Conform the class you want to send the selected photos to to the `PhotoFetcher` protocol. Set this class as the PhotoLibraryController's delegate.

5.  Implement `getSelectedLibrary(images: [UIImage])`


`class ViewController: UIViewController, KhajaPhotoLibraryDelegate`

```
func getSelectedLibrary(images:

[UIImage]) {

    // do stuff with images here

}

```

## Preview

1. Segue to the controller

2. click on any image to segue to a detail view that allows you to zoom in on the picture.

3. Press the `select` button in the navigation bar to enable multi-select

4. Select the images you wish you return to the parentViewController (the controller from your project that presents customImagePickerController)

5. Hit the "submit" button to dismiss this controller and trigger `getSelectedLibrary(images:

[UIImage])` in the parentViewController

![Alt text](CustomImagePickerPreview.gif "Preview")
