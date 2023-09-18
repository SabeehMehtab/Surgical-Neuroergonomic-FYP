Ronak's trans-cranial direct current stimulation (tDCS) data
==============================================================


%% Log:
%
% 28-Jan-2023: FOE
%  + This file created.
%
%


About Ronak's tDCS experiment
-----------------------------

This is a 3 factorial experiment

* Factor 1: Intervention
	** With levels: tDCS and Sham
	These levels are named "a" (active) and "s" (sham) below
* Factor 2: Time
	** With levels: Pre, Post, Retention
* Factor 3: Surgical Expertise
	** With levels: Junior vs Senior
	


Group allocation:

Junior Group
Participant Intervention
1	a
11	a
15	a
18	a
22	a
23	a
28	a

3	s
8	s
9	s
13	s
19	s
26	s
27	s

Senior group
Participant Intervention

2	a
4	a
6	a
14	a
16	a
24	a
25	a

5	s
7	s
10	s
12	s
17	s
20	s
21	s



Task is self-paced. Task involved a total of four blocks or trials (knots). 
A trigger 1 is placed at the start of each individual block period, trigger 2 and the end of each individual block period (therefore each NIRS file should contain 4 x trigger 1 and 4 x trigger 2)

	+--------------------------------------------------------+
	| WATCH OUT! Ronak calls the blocks, tasks! In addition, |
	| he has what he calls "block" which are actually        |
	| different observations within a single session.        |
	| Homer 3 calls different observations in a single       |
	| session, "runs".                                       |
	+--------------------------------------------------------+



Folder derivatives_fromTanaPerhaps_UnsureOrigin/
------------------------------------------------

Within the fNIRS_data/ folder containing Ronak's original .nirs files (Homer 2), and for each longitudinal session (Pre, Post, Retention) I found a folder called derivatives/homer/ and a Homer 2 or Homer 3 configuration (processing pipeline) file. Folder derivatives/homer/ is Homer3 (Homer 2 as well) default output folder.

In the previous folder ../ from derivatives/homer/, there was the Homer 3 (default) configuration file: processOpt_default.cfg


I believe these may correspond to Yarutana's work, but I cannot trace it back.
Hence, I mode all of that to the folder derivatives_fromTanaPerhaps_UnsureOrigin/


Another possiblity is that these are the default empty files that Homer 3 creates, when I open Homer 3 this morning. Very likely!! Anyway, I do not have the time to check right now.


Folder snirf_converted_raw/
---------------------------

Uing Homer 3, I converted the original .nirs files (Homer 2), to the .snirf format but otherwise did not make any processing