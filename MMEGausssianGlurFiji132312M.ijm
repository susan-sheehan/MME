
// Macro code for batch processing a folder
// of .tif files, includes saving .tifs back into the 
// ORIGINAL folder with a modified version 
// of the original image name
print("start directory loop");



dir = getDirectory("Choose input segment Directory ");      // prompts the user to select the folder to be processed, 

list = getFileList(dir);                                    // gives ImageJ a list of all files in the folder to work through
print("number of files in dir1 Segments",list.length);      // optional prints the number of files in the folder

dir2 = getDirectory("Choose input Image Directory "); // promts user to select folder to be saved in
list2 = getFileList(dir2);                 // gives ImageJ a list of all files in the folder to work through for directory2 
extension2 = ".tif";   //defines file type  variable 
print("number of files in dir2 Image",list2.length);                       // optional prints the number of files in the folder

dir3= getDirectory("Choose output Directory"); //promts user to select folder on Images for Results

setBatchMode(true);          // runs up to 6 times faster, without showing images onscreen.  Turn off during troubleshooting steps??
 
 dbugp = 1;							// verbose print for debug 
 
 // Note that the above processes are outside the loop brackets {  }, 
// so they will only be called once at the beginning of the macro
// list compare checker
// DIR and DIR2 must contain files for the same images in the same order
listerrs=0;
    for (f=0; f<list.length; f++) {
imageID = substring( list[f], 0,14);
print ("imageID",imageID);
//testindx =  indexOf("123456789","456");
//print("testindx=",testindx);
Imdx= indexOf( list2[f],imageID);
print("value of Index",Imdx);

if (Imdx <0 ) { // if list2[f] does not contain same imageID as list[f]
print("List Compare Error:");
print ( "   dir  file#",f," = ", list[f] );
print ( "   dir2 file#",f," = ", list2[f] );
listerrs++;  // count the errors
}
}
if(listerrs > 0 ) { exit(); }

print("START...");

// main files loop
// (process every image until you get to the bottom of the list) 
    for (f=0; f<list.length; f++) {
        path = dir+list[f];                       // creates the filepath for reading Segmentation files
		if(dbugp>0) {	 // optional prints the path & file name to a log window
			print("Name of path reading file from dir1",path); 
			}
        showProgress(f, list.length);     // optional progress monitor displayed at top of Fiji
        if (!endsWith(path,"/")) open(path);  // if subdirectory, push down into it Still have to open Path
        
		/* f (nImages>=1) {  // stop when there are no more open images */
		/*	if (endsWith(path,"f")) {	// Processes only tif files.   Useful if there are log or metadata files in the folder 
										// WILL ALSO ATTEMPT TO PROCESS .pdf OR ANY *f !!!!
										// Not needed if folder contains only .tif files*
		*/
			t=getTitle();    // gets the name of the image being processed   

			if(dbugp>0) {
				print("getTitle got t=", t ); 
				}	
			tt = substring(t,0,14); // Shortens title from start to X characters (t,0,X)
			if(dbugp>0) {
				print("attempt to truncate t=", tt ); 
				}
				
			run("Enhance Contrast...", "saturated=1 normalize");
			setAutoThreshold("Default dark");
			//run("Threshold...");
			//setThreshold(129, 255);
			setOption("BlackBackground", false);
			run("Convert to Mask");
			run("Gaussian Blur...", "sigma=10");
			run("Make Binary");
			run("Analyze Particles...", "size=4000-Infinity show=Outlines display include summarize add");
			n=roiManager("count");
			print("ROI_number=" + n); 
				//roiManager("Rename",tt+"roi"+n);
		
				
					if (roiManager("count")>0) {
						roiManager("Save", dir3 + tt +"roi"+n +".zip");
						for (i=0; i<n; i++) {
					
							roiManager("Select", i);

							path2=dir2+list2[f]; 
							print("Name of path reading files from dir2",path2);   
							//if (!endsWith(path2,"/")) open(path2); // This will open all files in folder
							//if (startsWith(path2,tt+".tif")) { 
							if (indexOf(path2,tt)>0) {
							//if (1) {
					 		open(path2); // this should only open matching file
													
							run("RGB Color");
							print("name of filefor dir2RGBrun step",tt);
							run("HSB Stack");
							run("Stack to Images");
							selectWindow("Saturation");
							rename(t+ "Saturation");
							setThreshold(90, 255);
							roiManager("Select",i );
							run("Measure");
						} else {
								print ("FILEName_ERROR");
							}
					}
						roiManager("Deselect");
						roiManager("Delete");            // Closes a loop.  Note there are as many } as there are { in the code, and each } is on it's own line
						}
			} 
    
	selectWindow("Results");
	saveAs(dir3+"GlomareaandMME.txt");
	selectWindow("Log");
	saveAs(dir3+"runlog.txt");

	// END processing per image