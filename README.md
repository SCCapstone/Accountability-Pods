
# Accountability Pods


## Short Description
Accountability pods is an app implementation of a transformative justice community building tool to serve as an alternative to policing. The main function of the app is for users to digitally organize their support system as a tool to use during violent, harmful, and abusive situations whether they are a survivor, bystander, or the person causing harm.

In terms of features, the app has the following:

1. Two types of users: individuals and organizations
	* Individual users have their own profiles where they can list conflict solving skills or materials they have access to. For example, if you have a working car, you could add this to the profile so other people in your network can contact you if they need an emergency ride or a jump, etc.
	* Organizations can create their own profiles or profiles can be made directly by us using information available online. For example, the SC Harm Reduction Coalition provides free narcan to community members to treat overdoses. Their profile page would include information about how to contact the organization, as well as some blurbs about the kind of work the organization does.

2. The main functionality is connecting with other users and searching through 'pods.'
	* By establishing connections with other users and organizations, the user will form a social network of accountability pods

Our target platform for the application is an IOS app using Swift, Xcode, and Firebase. You can see more detailed information about the project on the [Architecture](https://github.com/SCCapstone/Accountability-Pods/wiki/Architecture-Milestone) page of the wiki.

## External Requirements
 
In order to build this project you will need to install:
 
* Xcode
On a mac download from the Apple App Store
Or to download older versions compatible with you computer head here:
 https://developer.apple.com/download/more/
 
*Firebase
No installation necessary just go to:
https://firebase.google.com
 
## Setup
After cloning repo, user will need to open the project file AccountablityPods/AccountabilityPods.xcworkspace (this project file is linked to the firebase account, opening the .xcodeproj file will not work with firebase!!). To access the firebase console, developer will need to go to https://firebase.google.com and sign in using the group gmail info. 

## Running
A developer must clone the repo by adding the link to Xcode, and enter their personal access token from GitHub to access all the files in the repo.

# Deployment 
Xcode is every helpful for deployment of iOS app. To upload to the Apple App Store you must have a developer account associated with Apple. To deploy the app open the project in Xcode. Select the project and open the targets tab and under General, increment the version and build. In the header tabs under Product change your view to Generic iOS Device by selecting from the destination drop down. Then build an image of the app by selecting Product from the main tabs then Archive. From here the Archive window will appear and the developer can user to upload the App to the App Store. From here one will use their developer account.

# Testing 

## Testing Technology

To perform unit and UI testing in xcode we are using the XCTests library

## Testing
*Unit Testing

1) Open Swift Workspace. 
2) To access the Unit testing code locate the files tab(image of a folder) from the left panel. Select the "AccountabilityPodsTests" folder within the project.
3) From the dropdown within the folder, select "AccountabilityPodsTests.swift" file. Here you will find the code for all current unit tests that can be implemented.
4) To run the test locate the schema option towards the top left of the screen. Click on the schema and be sure to select the "AccountabilityPodsTests" schema from the dropdown with associated target iPhone 11. 
5) Navigate to the tests icon in the left panel, it is shaped like a diamond. Available testing files will appear in the panel.
6) In the left panel, directly to the right of the file name, such as "AccountabilityPodsTests", click the arrow contained in a circle. To run a subset of the tests or an individual test simply click the arrrow adjacent to the desired target. 
7) Xcode will automatically build and the test the methods. Success of the tests will be indicated by the diamond next to the name in the left panel or to the left of the function in the Xcode swift file turning green. A red diamond indicates failure.


*UI Testing

1) Open Swift Workspace. current directory -> AccountabilityPods -> AccountabilityPods.xcworkspace 
2) To access the UI testing code locate the files tab(image of a folder) from the left panel. Select the "AccountabilityPodsUITests" folder within the project.
3) From the dropdown within the folder, select "AccountabilityPodsUITests.swift" file. Here you will find the code for all current UI tests that can be implemented.
4) To run the test locate the schema option towards the top left of the screen. Click on the schema and be sure to select the "AccountabilityPodsUITests" schema from the dropdown with associated target iPhone 11. 
5) Navigate to the tests icon in the left panel, it is shaped like a diamond. Available testing files will appear in the panel.
6) In the left panel, directly to the right of the file name, such as "AccountabilityPodsUITests", click the arrow contained in a circle. To run a subset of the tests or an individual test simply click the arrrow adjacent to the desired target. 
7) Xcode will automatically build and the test the methods. Success of the tests will be indicated by the diamond next to the name in the left panel or to the left of the function in the Xcode swift file turning green. A red diamond indicates failure.

## Authors
Vasco Madrid, vmadrid0426@gmail.com
Jhada Kahan-Thomas, jhada@email.sc.edu
Duncan Evans, dsevans@email.sc.edu
Jenny Scholz, jtscholz@email.sc.edu

# Style Guide
We are using the google swift style guide
https://google.github.io/swift/

