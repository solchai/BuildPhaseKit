# BuildPhaseKit

SwiftPackageManager does not allow the use of development dependenecies, which does not allow the use of executables built from packages during buld phase.
The goal of this package is to allow users to access the bult excutables within build phase for use.

In a lot of cases, these libraries are imported using CocoaPods and NPM, as they support development dependencies. However, mixing importing methods can be a maintenance nightmare, so optimally, the importing method should be unified. By using this package, it eliminates the need for using other importing methods for development dependencies, which can help unify the method.

## Problem (Hypothesis)
When a package is checked out into a project or an app, the source code is persisted inside of the project/app's derived data.
Derived data is not accessible to developers, therefore, the sourcecode cannot be built and any executable cannot be extracted out.

## Resolution
This approach is highly inspired by Tobeas Brennan, https://blog.apptekstudios.com/2019/12/spm-xcode-build-tools/.
Any library that creates developemnt dependency/executable will be imported within a separate target totally disconnected from the project. By importing the library into a target and not a project, the source files become available. The source code can be built and the executable can be used during the build phase.
