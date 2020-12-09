setBatchMode(true);

//Local variables
defaultIntervalTime=2.5;
monthArray=newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
monthDaysArrayNormalYear=newArray(31,28,31,30,31,30,31,31,30,31,30,31);
monthDaysArrayLeapYear=newArray(31,29,31,30,31,30,31,31,30,31,30,31);
excludeText="Exclude_" //Directory entries (directories or files) starting with this text will be ignored

//Get parameters for the run
inputPath=getDirectory("Choose a directory of time-lapse images...");
Dialog.create("Time-Lapse Settings");
Dialog.addString("Interval between images (minutes):",toString(defaultIntervalTime));
Dialog.show();
intervalLengthMinutes=Dialog.getString();

//Sort the file and folder list
//Item names must be in the format Oct 14, 2019 06:12:29 PM
//Items must be either a time-stamped directory containing consecutively numbered files
//or a time-stampted .tiff file
dirList=getFileList(inputPath);
//Reject entries which are not either directories or .tiff files, or which begin with "Exclude_"
for (i=0; i<lengthOf(dirList); i++) {
	if ((startsWith(dirList[i], excludeText)) | ((!endsWith(dirList[i], "/")) * (!endsWith(dirList[i], ".tiff")))) {
		dirList=Array.deleteIndex(dirList,i);
	}
}

//Extract a number corresponding to the date indicated in each file or direcotry
dirListTrimmed=Array.copy(dirList);
dateValues=newArray(lengthOf(dirList));
for (i=0; i<lengthOf(dirListTrimmed); i++) {
	
	//First trim off any slashes and filename extensions
	if (endsWith(dirListTrimmed[i],"/")) { //If we have a directory
		dirListTrimmed[i]=substring(dirListTrimmed[i],0,lengthOf(dirListTrimmed[i])-1); //Trim off the slash
	} else { //If we have a file
		dirListTrimmed[i]=substring(dirListTrimmed[i],0,lastIndexOf(dirListTrimmed[i],".")); //Trim off the filename extension
	}
	
	//Next convert each text date into a number

	//Get date parameters from the text date
	dateYear=parseInt(substring(dirListTrimmed[i],8,12)); //Get the year
	dateMonthTxt=substring(dirListTrimmed[i],0,3); //Get the month text
	dateMonth=0;
	for (j=0; j<lengthOf(monthArray); j++) { //Find the number for the month
		if (dateMonthTxt==monthArray[j]) {
			dateMonth=j+1;
		}
	}
	dateDay=parseInt(substring(dirListTrimmed[i],4,6)); //Get the day
	dateMeridianTxt=substring(dirListTrimmed[i],22,24); //Get whether it is AM or PM
	if (dateMeridianTxt=="AM") {
		dateMeridian=0;
	} else {
		dateMeridian=1;
	}
	dateHourRaw=parseInt(substring(dirListTrimmed[i],13,15));
	dateHourMod=dateHourRaw;
	if (dateHourRaw==12) { //Deal with 12 AM or PM
		dateHourMod=0;
	}
	dateHour=(12*dateMeridian)+dateHourMod; //Get the hour
	dateMinute=parseInt(substring(dirListTrimmed[i],16,18)); //Get the minute
	dateSecond=parseInt(substring(dirListTrimmed[i],19,21)); //Get the second

	//Get the number of days since January 1, 2000
	//First look at year elapsed
	yearRemainder=(dateYear-2000)%4;
	yearGroupsElapsed=(dateYear-yearRemainder-2000)/4;
	if (yearRemainder>0) { //If we have passed the last leap year
		yearsInDaysSinceLastLeapYear=366+(yearRemainder-1)*365;
		monthDaysArrayThisYear=monthDaysArrayNormalYear;
	} else {
		monthDaysArrayThisYear=monthDaysArrayLeapYear;
	}
	yearsPassedInDays=365.25*yearGroupsElapsed+yearsInDaysSinceLastLeapYear;
	//Next look at months elapsed
	monthsPassedInDays=0;
	for (j=0; j<dateMonth-1; j++) {
		monthsPassedInDays=monthsPassedInDays+monthDaysArrayThisYear[j];
	}

	//Now compute the final date value as days passed (including fractional days) since January 1, 2000
	dateValues[i]=yearsPassedInDays+monthsPassedInDays+(dateDay-1)+(dateHour/24)+(dateMinute/(60*24))+(dateSecond/(60*60*24));
}
//Use the date numbers to sort the directory entries
rankArray=Array.rankPositions(dateValues);

//Loop through the directory entries and do these tasks:
//If the directory entry is a .tiff image, open the .tiff image and add the time-stamp
//If the diretory entry is a directory, sort the images in the directory, open each image in the directory add the time-stamp to each image
entriesToDo=lengthOf(rankArray);
getDateAndTime(yearNow, monthValNow, dayOfWeekNow, dayOfMonthNow, hourNow, minuteNow, secondNow, msecNow);
nowDateFormatted=toString(yearNow)+toString(monthValNow+1)+toString(dayOfMonthNow)+"_"+toString(hourNow)+"-"+toString(minuteNow)+"-"+toString(secondNow);
saveDir=inputPath+excludeText+"MovieMakerRun_"+nowDateFormatted;
File.makeDirectory(saveDir);
fileNameIndex=0;
for (i=0; i<entriesToDo; i++) {
	print("Processing entry "+toString(i+1)+" of "+toString(entriesToDo)+".");
	print("Entry name is: "+dirList[rankArray[i]]);
	startingTime=(dateValues[rankArray[i]]-dateValues[rankArray[0]])*24*60;

	//If the entry is a directory
	if (endsWith(dirList[rankArray[i]], "/")) {
		print("This entry is a directory.");
		baseImagePath=inputPath+dirListTrimmed[rankArray[i]]+File.separator;
		currentDirList=getFileList(baseImagePath);
		currentDirNumFiles=lengthOf(currentDirList);
		//Sort the files
		currentDirNumbers=newArray(currentDirNumFiles);
		for (j=0; j<currentDirNumFiles; j++) {
			currentDirNumbers[j]=parseInt(substring(currentDirList[j], 0, lastIndexOf(currentDirList[j], ".")));
		}
		currentDirRanks=Array.rankPositions(currentDirNumbers);
		setForegroundColor(6,6,6); //Set the text color to black
		for (j=0; j<currentDirNumFiles; j++) {
			showProgress(j,currentDirNumFiles);
			currentImagePath=baseImagePath+currentDirList[currentDirRanks[j]];
			open(currentImagePath);
			//run("Label...", "format=0 starting="+toString(startingTime+((j+1)*intervalLengthMinutes))+" interval="+toString(intervalLengthMinutes)+" x=75 y=20 font=50 text=min range=1-1");
			setFont("SansSerif", 50, " antialiased");
			setJustification("right");
			drawString(toString(startingTime+((j)*intervalLengthMinutes))+" min",500,100);
			saveAs("tiff", saveDir+File.separator+toString(fileNameIndex)+".tiff");
			close();
			fileNameIndex=fileNameIndex+1;
		}
	}

	//If the entry is a .tiff image
	if (endsWith(dirList[rankArray[i]], ".tiff")) {
		print("This entry is a .tiff image.");
		currentImagePath=inputPath+dirList[rankArray[i]];
		open(currentImagePath);
		setForegroundColor(6,6,6); //Set the text color to black
		//run("Label...", "format=0 starting="+toString(startingTime)+" interval="+toString(intervalLengthMinutes)+" x=75 y=20 font=50 text=min range=1-1");
		setFont("SansSerif", 50, " antialiased");
		setJustification("right");
		drawString(toString(startingTime+((j)*intervalLengthMinutes))+" min",500,100);
		saveAs("tiff", saveDir+File.separator+toString(fileNameIndex)+".tiff");
		close();
	}
	
	print("Done with entry "+toString(i+1)+" of "+toString(entriesToDo)+".");
	print("");
}

//Open the merged directory and make an avi file
firstSequencePath=saveDir+File.separator+"0.tiff";
run("Image Sequence...", "open=[firstSequencePath] sort use");
saveDirAVI=saveDir+File.separator+substring(substring(inputPath,0,lengthOf(inputPath)-1),lastIndexOf(substring(inputPath,0,lengthOf(inputPath)-1),File.separator)+1,lengthOf(substring(inputPath,0,lengthOf(inputPath)-1)))+".avi";
run("AVI... ", "compression=JPEG frame=7 save=[saveDirAVI]");
close();

setBatchMode(false);