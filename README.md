ios-gitsemver
=============

Automatic semantic versioning based on Git for iOS projects.

##How it works?
---

ios-gitsemver updates your number of version and build of your iOS Xcode project automatically by computing those values from the current Git repository. 

- **Version** number: last tag in the Git repository.
- **Build** number: number of commits from the last tag in the Git repository.

In order to be compatible with the AppStore guidelines, your tags must follow the structure XX.YY.ZZ where XX contains only numeric characters.

For more information about how to choose your version numbers, take a look into [SemVer](http://semver.org).

##What is the magic?
---

Because you are hosting your Xcode project into a Git repository, when changing any file (in particular, the *info-plist* file), the repository is marked as dirty. The scripts of ios-gitsemver do and undo every changes in order to do not modify your project and your repository. This way, when Xcode is compiling and preparing the bundles and packages to be deployed into the device (or into the AppStore), ios-gitsemver has previously setup the correct values for the version & build number, as well as extra parameters as current commit id or if the repository is dirty or not. Finally, after the build action has finished, ios-gitsemver reset those values to a default ones.

##Setup your project
---

ios-gitsemver has two scripts: one to be executed before a building action (*Preaction.sh*) and one to be executed after the building action (*Postaction.sh*).

In order to execute this scripts automatically you must edit all your compiling schemes and do:

*Product* > *Scheme* > *Edit Scheme*

Then unfold the option *Build* in your left column and add:

- *Pre-actions*: Tap "+" and add *New run script action*. Select your project in *Provide Build Settings From* optin and then copy-paste the following script:

		${PROJECT_DIR}/<YOUR_PATH>/ios-gitsemver/Preaction.sh "${PROJECT_DIR}/${INFOPLIST_FILE}"
		
- *Post-actions*: Tap "+" and add *New run script action*. Select your project in *Provide Build Settings From* optin and then copy-paste the following script:

		${PROJECT_DIR}/<YOUR_PATH>/ios-gitsemver/Postaction.sh "${PROJECT_DIR}/${INFOPLIST_FILE}"

Remebmer to do this for every scheme you have.

## Runing your project
---

Now, from your code you can get version & build numbers as well as commit id and if the repository is dirty or not very easily.

#####Version number

The last tag in the git repository.

	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	
#####Build number

The number of commits since the last tag in the git repository.

    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
#####Commit ID

The last commit when the build was done.
    
    NSString *commitID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GSVGitCommitID"];
    
#####Dirty Repository

A boolean value indicating if the repository was dirty (uncommited changes) when the build was done.
    
    BOOL dirtyRepo = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"GSVGitDirtyRepository"] boolValue];


##License
---
The MIT License (MIT)

Copyright (c) 2013 Joan Martin

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.




