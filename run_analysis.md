
### Load Packages

packages <- c("data.table", "reshape2");
sapply(packages, require, character.only = TRUE, quietly = TRUE)


# Set path

path <- getwd()
path


##Get the data from site


url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- "dataSet.zip"

if (!file.exists(path)){
        dir.create(path)
}

download.file(url, destfile=file.path(path, f))

# Unzip the file 

# executable <- file.path("C:", "Program Files (x86)", "7-Zip", "7z.exe")
# parameters <- "x"
# cmd <- paste(paste0("\"", executable, "\""), parameters, paste0("\"", file.path(path, 
#                                                                                 f), "\""))
# system(cmd)

unzip(file.path(path,f), overwrite = TRUE)

##The unzip put the files in a folder named UCI HAR Dataset. Set this folder as the input path. List the files here.

pathIn <- file.path(path, "UCI HAR Dataset")
list.files(pathIn, recursive = TRUE)

## See the README.txt

### Read files

# Read subject files

dtSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
dtSubjectTest  <-  fread(file.path(pathIn, "test", "subject_test.txt"))

# Read Label/activity files 

dtActivityTrain <- fread(file.path(pathIn, "train", "Y_train.txt"))
dtActivityTest  <- fread(file.path(pathIn, "test",  "Y_test.txt"))

## Read data files. 

#fread bombs due to newline or EOF chars in the file

# dtTrain <- fread(file.path(pathIn, "train", "X_train.txt"))
# dtTest  <- fread(file.path(pathIn, "test", "X_test.txt"))

fileToDataTable <- function(f){
        
        df <- read.table(f)
        dt <- data.table(df)
}

dtTrain <- fileToDataTable(file.path(pathIn, "train", "X_train.txt"))
dtTest  <- fileToDataTable(file.path(pathIn, "test", "X_test.txt"))

## merge training and test data sets

# dtSubject <- merge(dtSubjectTrain, dtSubjectTest, by.x="V1", all=TRUE)
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)

#merge colum wise

dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)

# setting up keys
setkey(dt, subject, activityNum)

## Extract mean and std. 

# Read features.txt

dtFeatures <- fread(file.path(pathIn,"features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))

# subset only for mean and std measurements

dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]

# 

dtFeatures$featureCode <- dtFeatures[,paste0("V", featureNum)]
head(dtFeatures)

dtFeatures$featureCode

# subset using variable names

select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with=FALSE]

## Use descriptive names for activities

# Read activity data

dtActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))

## Label activity names

dt<- merge(dt, dtActivityNames, by = "activityNum", all.x=TRUE)

# Add activity name as a key

setkey(dt, subject, activityNum, activityName)

# Melt the data table to a tall and thin one

dt <- data.table(melt(dt, key(dt), variable.name= "featureCode"))

# merge activity names

dt <- merge(dt, dtFeatures[, list(featureNum, featureCode,featureName)], by="featureCode", all.x=TRUE)

#Create a new variable, activity that is equivalent to activityName as a factor class. Create a new variable, feature that is equivalent to featureName as a factor class.

dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)


# Create a function to  help 

grepthis <- function(regex) {
        grepl(regex, dt$feature)
}
## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol = nrow(y))
dt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol = nrow(y))
dt$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol = nrow(y))
dt$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol = nrow(y))
dt$featVariable <- factor(x %*% y, labels = c("Mean", "SD"))
## Features with 1 category
dt$featJerk <- factor(grepthis("Jerk"), labels = c(NA, "Jerk"))
dt$featMagnitude <- factor(grepthis("Mag"), labels = c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol = nrow(y))
dt$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))

# Check to make sure all possible combinations of feature are accounted for by all possible combinations of the factor class variables.

r1 <- nrow(dt[, .N, by = c("feature")])
r2 <- nrow(dt[, .N, by = c("featDomain", "featAcceleration", "featInstrument", "featJerk", "featMagnitude", "featVariable", "featAxis")])
r1 == r2



### Create tidy data set

#Create a data set with the average of each variable for each activity and each subject.

setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by = key(dt)]

#make code book

knit("makeCodebook.Rmd", output = "codebook.md", encoding = "ISO8859-1", quiet = TRUE)

markdownToHTML("codebook.md", "codebook.html")

