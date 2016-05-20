

library(reshape2)

filename <- "Getting and Cleaning Project Data.zip"

#################
# 1. Downloading and unziping the dataset:
#################

if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

################
## 2. Loading activity labels and features
################

Activity_Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
Activity_Labels[,2] <- as.character(Activity_Labels[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(Features[,2])


################
### 3. Extracting only the data on mean and standard deviation (Std)
################

FeaturesWanted <- grep(".*mean.*|.*std.*", Features[,2])
FeaturesWanted.names <- Features[FeaturesWanted,2]
FeaturesWanted.names = gsub('-mean', 'Mean', FeaturesWanted.names)
FeaturesWanted.names = gsub('-std', 'Std', FeaturesWanted.names)
FeaturesWanted.names <- gsub('[-()]', '', FeaturesWanted.names)

################
## 4. Loading those datasets
################

Train <- read.table("UCI HAR Dataset/train/X_train.txt")[FeaturesWanted]
TrainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
Train <- cbind(TrainSubjects, TrainActivities, Train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[FeaturesWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

#################
#### 5.merging datasets and adding labels
#################

All_Data <- rbind(Train, test)
colnames(All_Data) <- c("subject", "activity", FeaturesWanted.names)


###############
##### 6. Changing activities & subjects into factors
###############
All_Data$activity <- factor(All_Data$activity, levels = Activity_Labels[,1], labels = Activity_Labels[,2])
All_Data$subject <- as.factor(All_Data$subject)

All_Data.melted <- melt(All_Data, id = c("subject", "activity"))
All_Data.mean <- dcast(All_Data.melted, subject + activity ~ variable, mean)

write.table(All_Data.mean, "tidy dataset.txt", row.names = FALSE, quote = FALSE)


###############
# Thank you very much for reviewing!
###############

