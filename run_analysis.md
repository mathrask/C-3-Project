
run_analysis
============
Last updated 2015-01-25 14:10:20 using R version 3.1.2 (2014-10-31).


Instructions for project
------------------------

> The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  
> 
> One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
> 
> http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
> 
> Here are the data for the project: 
> 
> https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
> 
> You should create one R script called run_analysis.R that does the following. 
> 
> 1. **DONE** Merges the training and the test sets to create one data set.
> 2. **DONE** Extracts only the measurements on the mean and standard deviation for each measurement.
> 3. **DONE** Uses descriptive activity names to name the activities in the data set.
> 4. **DONE** Appropriately labels the data set with descriptive activity names.
> 5. **DONE** Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
> 
> Good luck!

**The codebook is at the end of this document.**


Preliminaries
-------------

Load packages.


```r
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
```

```
## data.table   reshape2 
##       TRUE       TRUE
```

Set path.


```r
path <- getwd()
path
```

```
## [1] "C:/Users/username/Desktop/Suresh/Coursera/C-3"
```


Get the data
------------

Download the file. Put it in the `Data` folder. **This was already done; save time and don't evaluate again.**


```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- "Dataset.zip"
if (!file.exists(path)) {dir.create(path)}
download.file(url, file.path(path, f))
```

Unzip the file. **This was already done; save time and don't evaluate again.**


```r
unzip(file.path(path,f), overwrite=TRUE)
```

The archive put the files in a folder named `UCI HAR Dataset`. Set this folder as the input path. List the files here.


```r
pathIn <- file.path(path, "UCI HAR Dataset")
list.files(pathIn, recursive=TRUE)
```

```
## character(0)
```

**See the `README.txt` file in C:/Users/username/Desktop/Suresh/Coursera/C-3 for detailed information on the dataset.**



Read the files
--------------

Read the subject files.


```r
dtSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
```

```
## Warning: running command 'C:\WINDOWS\system32\cmd.exe /c
## (C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/train/subject_train.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec41b1cea6' had
## status 1
```

```
## Warning in shell(paste("(", input, ") > ", tt, sep = "")):
## '(C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/train/subject_train.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec41b1cea6' execution
## failed with error code 1
```

```
## Error in fread(file.path(pathIn, "train", "subject_train.txt")): File is empty: C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec41b1cea6
```

```r
dtSubjectTest  <- fread(file.path(pathIn, "test" , "subject_test.txt" ))
```

```
## Warning: running command 'C:\WINDOWS\system32\cmd.exe /c
## (C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/test/subject_test.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec4460d3815' had
## status 1
```

```
## Warning in shell(paste("(", input, ") > ", tt, sep = "")):
## '(C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/test/subject_test.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec4460d3815'
## execution failed with error code 1
```

```
## Error in fread(file.path(pathIn, "test", "subject_test.txt")): File is empty: C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec4460d3815
```

Read the activity/label files. 


```r
dtActivityTrain <- fread(file.path(pathIn, "train", "Y_train.txt"))
```

```
## Warning: running command 'C:\WINDOWS\system32\cmd.exe /c
## (C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/train/Y_train.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec44d512f38' had
## status 1
```

```
## Warning in shell(paste("(", input, ") > ", tt, sep = "")):
## '(C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/train/Y_train.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec44d512f38'
## execution failed with error code 1
```

```
## Error in fread(file.path(pathIn, "train", "Y_train.txt")): File is empty: C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec44d512f38
```

```r
dtActivityTest  <- fread(file.path(pathIn, "test" , "Y_test.txt" ))
```

```
## Warning: running command 'C:\WINDOWS\system32\cmd.exe /c
## (C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/test/Y_test.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec451f1691a' had
## status 1
```

```
## Warning in shell(paste("(", input, ") > ", tt, sep = "")):
## '(C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/test/Y_test.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec451f1691a'
## execution failed with error code 1
```

```
## Error in fread(file.path(pathIn, "test", "Y_test.txt")): File is empty: C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec451f1691a
```

Read the data files. 


```r
fileToDataTable <- function (f) {
        df <- read.table(f)
	dt <- data.table(df)
}
dtTrain <- fileToDataTable(file.path(pathIn, "train", "X_train.txt"))
```

```
## Warning in file(file, "rt"): cannot open file
## 'C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/train/X_train.txt': No such file or directory
```

```
## Error in file(file, "rt"): cannot open the connection
```

```r
dtTest  <- fileToDataTable(file.path(pathIn, "test" , "X_test.txt" ))
```

```
## Warning in file(file, "rt"): cannot open file
## 'C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/test/X_test.txt': No such file or directory
```

```
## Error in file(file, "rt"): cannot open the connection
```


Merge training and  test sets
------------------------------------

Concatenate  data tables.


```r
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)
```

Merge columns.


```r
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)
```

Set key.


```r
setkey(dt, subject, activityNum)
```


Extract only the mean and standard deviation
--------------------------------------------

Read the `features.txt` file. This tells which variables in `dt` are measurements for the mean and standard deviation.


```r
dtFeatures <- fread(file.path(pathIn, "features.txt"))
```

```
## Warning: running command 'C:\WINDOWS\system32\cmd.exe /c
## (C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/features.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec4289b6e9a' had
## status 1
```

```
## Warning in shell(paste("(", input, ") > ", tt, sep = "")):
## '(C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/features.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec4289b6e9a'
## execution failed with error code 1
```

```
## Error in fread(file.path(pathIn, "features.txt")): File is empty: C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec4289b6e9a
```

```r
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))
```

```
## Error in setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName")): 'old' is length 3 but 'new' is length 2
```

Subset only measurements for the mean and standard deviation.


```r
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
```

Convert the column numbers to a vector of variable names matching columns in `dt`.


```r
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]
head(dtFeatures)
```

```
##    featureNum       featureName featureCode
## 1:          1 tBodyAcc-mean()-X          V1
## 2:          2 tBodyAcc-mean()-Y          V2
## 3:          3 tBodyAcc-mean()-Z          V3
## 4:          4  tBodyAcc-std()-X          V4
## 5:          5  tBodyAcc-std()-Y          V5
## 6:          6  tBodyAcc-std()-Z          V6
```

```r
dtFeatures$featureCode
```

```
##  [1] "V1"   "V2"   "V3"   "V4"   "V5"   "V6"   "V41"  "V42"  "V43"  "V44" 
## [11] "V45"  "V46"  "V81"  "V82"  "V83"  "V84"  "V85"  "V86"  "V121" "V122"
## [21] "V123" "V124" "V125" "V126" "V161" "V162" "V163" "V164" "V165" "V166"
## [31] "V201" "V202" "V214" "V215" "V227" "V228" "V240" "V241" "V253" "V254"
## [41] "V266" "V267" "V268" "V269" "V270" "V271" "V345" "V346" "V347" "V348"
## [51] "V349" "V350" "V424" "V425" "V426" "V427" "V428" "V429" "V503" "V504"
## [61] "V516" "V517" "V529" "V530" "V542" "V543"
```

Subset these variables using variable names.


```r
select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with=FALSE]
```


Use descriptive activity names
------------------------------

Read `activity_labels.txt` file. This will  add descriptive names to the activities.


```r
dtActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))
```

```
## Warning: running command 'C:\WINDOWS\system32\cmd.exe /c
## (C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/activity_labels.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec4495942c3' had
## status 1
```

```
## Warning in shell(paste("(", input, ") > ", tt, sep = "")):
## '(C:/Users/username/Desktop/Suresh/Coursera/C-3/UCI HAR
## Dataset/activity_labels.txt) >
## C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec4495942c3'
## execution failed with error code 1
```

```
## Error in fread(file.path(pathIn, "activity_labels.txt")): File is empty: C:\Users\username\AppData\Local\Temp\RtmpAXpsEE\file1ec4495942c3
```

```r
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))
```


Label with descriptive activity names
-----------------------------------------------------------------

Merge activity labels.


```r
dt <- merge(dt, dtActivityNames, by="activityNum", all.x=TRUE)
```

Add `activityName` as a key.


```r
setkey(dt, subject, activityNum, activityName)
```

Melt the data table to reshape it from a short and wide format to a tall and narrow format.


```r
dt <- data.table(melt(dt, key(dt), variable.name="featureCode"))
```

Merge activity name.


```r
dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by="featureCode", all.x=TRUE)
```

Create a new variable, `activity` that is equivalent to `activityName` as a factor class.
Create a new variable, `feature` that is equivalent to `featureName` as a factor class.


```r
dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)
```

Seperate features from `featureName` using the helper function `grepthis`.


```r
grepthis <- function (regex) {
  grepl(regex, dt$feature)
}
## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol=nrow(y))
dt$featDomain <- factor(x %*% y, labels=c("Time", "Freq"))
x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol=nrow(y))
dt$featInstrument <- factor(x %*% y, labels=c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol=nrow(y))
dt$featAcceleration <- factor(x %*% y, labels=c(NA, "Body", "Gravity"))
x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol=nrow(y))
dt$featVariable <- factor(x %*% y, labels=c("Mean", "SD"))
## Features with 1 category
dt$featJerk <- factor(grepthis("Jerk"), labels=c(NA, "Jerk"))
dt$featMagnitude <- factor(grepthis("Mag"), labels=c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol=nrow(y))
dt$featAxis <- factor(x %*% y, labels=c(NA, "X", "Y", "Z"))
```

Check to make sure all possible combinations of `feature` are accounted for by all possible combinations of the factor class variables.


```r
r1 <- nrow(dt[, .N, by=c("feature")])
r2 <- nrow(dt[, .N, by=c("featDomain", "featAcceleration", "featInstrument", "featJerk", "featMagnitude", "featVariable", "featAxis")])
r1 == r2
```

```
## [1] TRUE
```

Yes, I accounted for all possible combinations. 



Create a tidy data set
----------------------

Create a data set with the average of each variable for each activity and each subject.


```r
setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by=key(dt)]
```

Make codebook.


```r
knit("makeCodebook.Rmd", output="codebook.md", encoding="ISO8859-1", quiet=TRUE)
```

```
## [1] "codebook.md"
```

```r
markdownToHTML("codebook.md", "codebook.html")
```
