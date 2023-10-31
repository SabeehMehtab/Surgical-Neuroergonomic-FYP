# Surgical-Neuroergonomic-FYP
This Project dives into the Data Processing and Analysis attempts of studying the brain activity of surgeon before and after neuro-stimulation, using functional Near-Infrared Spectroscopy (fNIRS), 
for future use in assisting remote robotic surgeries in the field of Surgical Neuroergonomics.

For preprocessing data, open the ‘preprocessing3.m’ matlab script file. To get started, first of all setup the paths for ‘baseDir’ and ‘workingDir’. ‘workingDir’ path should contain both the folders from the repository. 
After that follow the comments in each section block to select the session, subject number and the columns for visualization of a channel wavelength for the step. Run one section at a time. 
Only the wavelet filtering takes the most time, a maximum of 5 minutes. 
For some steps, the output is saved in a results folder related to the session and can be found and accessed in the working directory. This is how the processing was done.

For Homer's GLM analysis, refer to the ‘analysis1.m’ matlab script file. Setup the same ‘baseDir’ and ‘workingDir’ as before. 
In order to run this successfully, the concentration results before the block average are needed for a subject. 
Next, choose the subject and session for it to be carried on. After that, run the whole file and check the beta values from the parameter workspace.

Finally for the second unfinished analysis, open the ‘analysis2.m’ matlab script file. As before, setup the ‘baseDir’ and ‘workingDir’. 
Choose the subject and session to experiment on. Run till before the second to last section. Observe the graphs.
