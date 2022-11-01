# *Guidelines for Research Assistants*

Contents:
1. Administrative tasks
    1. [Managing project tasks with Asana](#i-managing-project-tasks-with-asana). Setting up Asana, keeping track of work, defining meeting agendas.
        1. [Setting up new projects](#setting-up-new-projects)
        2. [Using sections, columns, tasks and subtasks to keep track of work](#using-sections-columns-tasks-and-subtasks-to-keep-track-of-work)
        3. [Tracking priorities in the admin section](#tracking-priorities-in-the-admin-section)
        4. [Following up on presentation comments](#following-up-on-presentation-comments)
    2. [Managing meetings](#ii-managing-meetings). Preparing agendas before meetings, sending meeting recaps and keeping a record of previous meetings.
    3. [Weekly timesheets and recaps](#iii-weekly-timesheets-and-recaps). Preparing weekly timesheets and recaps.
    	1. [Weekly timesheets](#timesheets)
    	2. [Weekly recaps](#weekly-recaps)
    5. [Professional development meetings](#iv-professional-development-meetings). Regular calls to provide feedback, discuss areas to improve and review graduate school applications.
    6. [Tracking conference and presentation deadlines](#v-keeping-track-of-conference-and-presentation-deadlines). Using [remindR](https://github.com/clandinq/remindr) to keep track of deadlines, mantaining a conference calendar.
    	1. [remindR system](#reminder-system)
        2. [Conference calendar](#calendar-with-conference-dates)
    7. [Holidays & time off](#vi-holidays-and-time-off). Official university holidays, paid time off, and process for scheduling days off.

2. Keeping files organized
    1. [General project organization](#i-general-project-organization). Overview of how you should use Dropbox, Github and Overleaf for academic projects.
    2. [Working with GitHub](#ii-working-with-github). Setting up and using GitHub locally and in the server.
        1. [Setting up a new repo on GitHub and cloning locally](#setting-up-a-new-repo-on-github-and-cloning-locally)
        2. [Setting up an existing repo on the server or a new computer](#setting-up-an-existing-repo-on-the-server-or-a-new-computer)
        3. [Updating the GitHub repo](#updating-the-github-repo)
    3. [Working with Dropbox](#iii-working-with-dropbox). Keep a backup of project files and data on Dropbox.
    4. [Working with KLC](#iv-working-with-the-kellogg-linux-cluster-klc-server). Setting up the server and keeping project updated with GitHub.
        1. [Accessing KLC](#accessing-klc)
        2. [Uploading files with FileZilla](#uploading-files-via-filezilla)
        3. [Running scripts](#running-scripts)
    5. [Keeping Github and Dropbox updated](#v-keeping-github-and-dropbox-updated). Update Github and Dropbox with one simple terminal command.

3. Generating content for papers and presentations
    1. [Working with EPS figures](#i-working-with-eps-figures)
    2. [Generating different presentation versions](#v-generating-different-presentation-versions). Simplify generation of multiple presentation versions and presentation updating.


# 1. Administrative tasks
## i. Managing project tasks with Asana
We use [Asana](https://asana.com/) to keep track of project tasks, provide updates and follow up on meetings. Before setting up Asana, read the [product guide](https://asana.com/guide/help) and [common questions](https://asana.com/guide/help/faq/common-questions) to understand how Asana works. As a very brief introduction, Asana has five levels of organization:
1. **Organizations**. Your user will be part of the Northwestern Kellogg organization. This is defined by the email address you use, so it is important that you register with your @kellog.northwestern.edu email address.
2. **Teams**. Teams are comprised of groups/sections of tasks (what asana calls "projects") and team members. We will have one team per academic project.
3. **Projects**. Projects are groupings of tasks in similar categories.  For example, we will always have an Admin and Analysis section in our Projects, and these sections are what Asana defines as projects. In the rest of this guide, I will refer to academic projects as *Projects*, and the subcomponents/sections of Asana teams and workspaces as *projects*.
4. **Tasks**. Tasks are individual components of projects that contain deadlines, descriptions and opportunities to comment and upload content. Tasks can be assigned to multiple projects.
5. **Subtasks**. Tasks are subdivisions of tasks that function in the same way, allowing you to set deadlines and update content.

### Setting up new Projects
1. First, download and install [Asana](https://asana.com/). For Asana to function correctly, you must register with your Kellogg email, which will grant you access to the Kellogg organization on Asana. 
2. Create a new team by clicking on **Add Team** in the left panel. We will have one team per Project, and if you're working on more than one Project, you will be able to see all the teams in the same window.

    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_1.png" align="center" height="30%" width="30%">

2. Write down the name of the Project (preferrably one or two words) and a short description. You can start inviting members at this point, but you will have to add them to each Asana project once they are created.

    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_2.png" align="center" height="35%" width="35%">
    
3. The next step is to create Asana projects, which will be sections of our Project.
    1. Click on **Create a Project** below the selected team.

        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_3.png" align="center" height="30%" width="30%">
        
    2. Select **Blank project** for project setup.
    
        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_4.png" align="center" height="40%" width="40%">
    
    3. Define the section's name (e.g. "Admin"), choose **Board** as the default view, and leave privacy settings as **Public to team**. Click **Continue** to finalize creating this project. If you forget to set this up when creating the project, you can configure Board as the default view in the project settings.
        
        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_6.png" align="center" height="30%" width="30%">
        
    4. Click on **Start adding tasks** and **Go to project**.
        
        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_7.png" align="center" height="30%" width="30%">
        
    5. By default, the project will have three columns: To do, In progress, and Complete. Add a fourth column called "Archive".
        
        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_8.png" align="center" height="50%" width="50%">
        
    6. Once you have set up an initial project, click on the three dots next to the project name and select **Duplicate Project**. Duplicate the project to generate a section called Admin, a second one called Agenda, and a third one called Analysis. These three sections will be the base of the Project, since most tasks will fall into the Analysis category, Agenda is used for meetings, and Admin will contain administrative tasks. More details are explained in the [following part of the guide](https://github.com/skhiggins/ra_guide/#using-sections-to-keep-track-of-different-types-of-tasks).

        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_9.png" align="center" height="40%" width="40%">
        
    7. For each duplicated project, click on the down arrow next to the project name, and change the project's color so that it is easily identifiable.
    
        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_11.png" align="center" height="40%" width="40%">
        
    8. Here is an example of how the sections of a Project looks like:
        
        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/asana_setup_12.png" align="center" height="25%" width="25%">        
        
    9. Once all projects have been set up, invite all researchers and RAs as collaborators to the team.Once they have accepted your invitation, you can (and should) invite them to join the rest of the projects.  Ask collaborators (by assigning them a first task) to input their full name and a picture so that it's easy to identify task ownership. You can invite new members to a maximum of three projects. You can see who is a member of each project on the left of the search bar: 
    
        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/colab_1.png" align="center" height="40%" width="40%">        
        
### Using sections, columns, tasks and subtasks to keep track of work
#### Sections
Keep different types of tasks in separate sections. Most projects will have the following sections:
- **Admin**: This section should contain administrative tasks. For example, writing up presentation comments and organizing tasks in Asana.
- **Agenda**: Keep items to be discussed in meetings in this section. Also, there should be a category (column) titled "Priorities" with the priorities of all the team members. This is explained more in detail in the [next part of the guide](https://github.com/skhiggins/ra_guide/#keeping-track-of-agenda-contents).
- **Analysis**: All analysis-related tasks will be in this section. This should be the center of any project.
- **Presentations**: Tasks for presentations and conferences.
- **References**: Relevant references to keep in mind when writing the paper.
- **Comments**: Presentation comments. More details in the following sections.

Other sections projects can have include:
- Budget
- Grant deliverables
- Surveys

Feel free to set up new sections if necessary.

#### Columns
Most sections should have the following columns:
- **To do**: Tasks that have not been started yet.
- **In progress**: Tasks you are currently working on.
- **Complete**: Recently completed tasks.
- **Archive**: Completed tasks that have been discussed with researchers and whose output has been acknowledged. 

When completing a task, move it to the **Complete** column and add the task to the **Agenda** section to ensure it gets discussed in the next meeting with PIs. If it's a minor task that does not to be discussed in a meeting, you can assign a subtask to a PI so that they review what you've done, or alternatively, tag them in a comment. Once the task has been acknowledged, and if there are no more follow-up tasks that will be assigned to the same item, you can mark it as complete by clicking the check mark button and moving it to **Archive**.

#### Tasks and subtasks
All the work you do can be added as tasks and subtasks. The following is an example of a couple of tasks in Asana:

<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/task.png" align="center" height="25%" width="25%">

Lengthier tasks should be broken down into subtasks:

<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/subtask.png" align="center" height="40%" width="40%">

General guidelines for working with tasks and subtasks:
- **Naming**: Tasks and subtasks should have clear, short names that makes it easy to identify them. You can write down a full breakdown of the required task in the description section of the task or subtask. 
- **Deadlines**: When creating tasks, assign them to the main person responsible for completing the task, and assign a deadline. They are generally not hard deadlines, but can help to prioritize and identify tasks that have dragged on for longer than necessary. For tasks assigned to you, if the person creating the task did not put a deadline, set your own deadline to give the researchers a sense of when you think the task will be completed by. Subtasks can also have deadlines assigned to them. 
- **Adding results**: When adding results (graphs or tables), attach them as screenshots or JPG / PNG files, since PDF and EPS files will not show previews. If necessary, you can also attach Excel documents. If the description does not include it, add the reason why the analysis is being conducted, what the hypothesis was being tested, whether the results confirm or reject the hypothesis, and what can be concluded from the results.
- **Likes**: Use the like button to indicate that you've seen a task that has been assigned to you. **Don't forget to like comments to let PIs and other RAs know that you have seen their comments**.

### Tracking priorities in the admin section
The first column in the **Admin** section should be called "Priorities", and will include a task for each team member with their priorities:

<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/priorities_1.png" align="center" height="25%" width="25%">     

Include as subtasks current tasks by order of priority, with the most important tasks first. Delete subtasks when completed. This is so that it's easier to keep track of current tasks (since most of the time there will be several tasks assigned to you), and that PIs can know what your curent priorities are. **Always keep this section up to date**. Here is an example of a priorities task:

<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/priorities_2.png" align="center" height="40%" width="40%">     

### Keeping track of agenda contents
The agenda section is used to keep track of current priorities and items to be discussed in each meeting. Start by creating a column for each regular meeting:

<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/agenda_0.png" align="center" height="50%" width="50%">     

Follow these steps to add tasks to the agenda:
1. Click on a task that you want to add to a meeting agenda.

    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/agenda_1.png" align="center" height="25%" width="25%"> 
    
2. Click on **Add to projects** and select **Agenda**.

    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/agenda_2.png" align="center" height="30%" width="30%"> 
  
3. Select the meeting to add the task to.

    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/agenda_3.png" align="center" height="30%" width="30%"> 

4. The other section's color will display in the selected task. For example, this task is in the section **Analysis** and the Admin's section pink color is drawn over the task.

    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/agenda_4.png" align="center" height="25%" width="25%"> 

5. Once you have added all relevant tasks to the agenda, it will be easier to write the agenda email and add the detailed agenda to the Google Docs with detailed agendas and meeting recaps.

    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/agenda_5.png" align="center" height="25%" width="25%"> 

### Following up on presentation comments
PIs receive valuable comments from conferences where they present their academic projects. Asana can help convert these comments to actionable tasks, and by grouping comments by topic, prioritize which should be worked on first.

1. After each paper presentation, add a task in **Admin** asking the presenter to share the comments from the presentation. If you have the opportunity of being at the presentation, write down _every_ question asked, and who asked the question.
2. Create a document in the Project's Dropbox where you keep all presentation comments (example [here](https://github.com/skhiggins/ra_guide/blob/main/docs/Presentation%20comments.docx)). Color-code comments from PIs and RAs and highlight comments that should become tasks:

    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/comments_1.png" align="center" height="40%" width="40%"> 

3. Add comments to the **Comments** section on Asana. Group comments by topic, and make sure to assign actionable comments to the **Analysis** section.

    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/comments_2.png" align="center" height="50%" width="45%"> 
    <br/><br/>
    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/asana/comments_3.png" align="center" height="40%" width="40%"> 
    
4. Once a comment has been dealt with (either task has been done, or PI has responded the comment), move the comment to the **Complete** column in the **Comments** section. Assign the task to PIs so they can review, and once processed, ensure they are marked as complete and moved to the **Archive** column.

## ii. Managing meetings
1.	Send a meeting agenda **at least an hour before each meeting** with detailed items to discuss in the meeting and attaching all content relevant to the meeting. A useful way to remember is to set a calendar event with an email reminder for the agenda an hour or more before the meeting. Keep track of content for each meeting in Asana:
    1. Keep track of agenda items by adding them as tasks in an Asana project titled “Agenda”. 
    2. Make a different section for each recurring meeting, and update tasks with what was discussed in the presentation. 
    3. When tasks are complete, mark as complete and move to a section titled “Complete”.
2.	Send a meeting recap after each meeting with detailed notes about what was discussed in each meeting.
    1. Each item should have a discussion and tasks section.
        1. In the discussion section, write comments when possible as problem + potential solution.
        2. Immediately add items from tasks section to Asana.
    2. Upload summaries to a Google Docs document, and include this link in all recap emails.

## iii. Weekly timesheets and recaps

## Timesheets
All research assistants fill out a weekly timesheet. This is helpful for planning, making sure PIs are optimizing your time and setting realistic expectations about how long different tasks will take. You can start by using the [timesheet template](https://github.com/skhiggins/ra_guide/blob/main/docs/Timesheet_template_individual.xlsx).

### Filling out timesheets
There are two options for filling out timesheets: filling out the timesheet directly or using [Clockify](https://clockify.me/).

#### 1. Filling out Excel timesheet directly
One option is to keep the Excel open and fill it in when you start and stop working on a task. You can use a couple of shortcuts to make filling out the timesheet easier: `Ctrl+` to enter the current date in a cell and `Ctrl+Shift+` to enter the current time. 

#### 2. Using Clockify 
[Clockify](https://clockify.me/) is a time tracking app for Mac OS X, Windows, and web browsers. With Clockify, you can register individual entries as parts of tasks and projects, which makes this app easily compatible with the format of timesheets: 
- **Projects**: This field is useful when you want to track your time beyond RA work (for example, to keep yourself accountable when studying for the GRE or working on graduate school applications). You can make a project titled *RA work* and then only keep these entries for the timesheet.
- **Tasks**: This field can be used for project names if you're working on multiple projects (or for multiple PIs), or for individual tasks that group several subtasks if you only work for one PI.
- **Description**: Here, you should provide a short but useful description of the current task you're working on.

	<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/clockify/clock_1.png" align="center" height="40%" width="40%">
	<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/clockify/clock_2.png" align="center" height="25%" width="25%"> 

To download your Clockify entries for last week:
1. First, open https://app.clockify.me/reports/detailed. 
2. Then, select the entries for last week and filter by project or client.
 
	<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/clockify/clock_3.png" align="center" height="35%" width="35%">

3. Afterward, click on **Export** and **Save as CSV**. 

	<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/clockify/clock_4.png" align="center" height="30%" width="30%">

4. Download the [Clockify processing script](https://github.com/skhiggins/ra_guide/blob/main/scripts/prepare_timesheet.R) and update the location of the Downloads folder. 
5. Once you run the script, you can copy and paste the output directly into the timesheet. 

By default, Clockify keeps the filters you used in your last session, so it is easier to download data after doing the initial set-up.

The benefit of using Clockify is that you can easily track time for your other personal projects, whether taking a class or preparing applications. Additionally, you can analyze how you're spending your time, which can help you make necessary changes to your workday.

<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/clockify/clock_5.png" align="center" height="60%" width="60%">

## Weekly recaps
You should include timesheets in a weekly email sent every Monday morning recapping what the main things you accomplished during the last week were and your main priorities for the upcoming week in bullet points. Include as the subject of the email: [Name] Weekly email (X hours). Below are a few example emails from other RAs:
### RA working for 1 professor on 1 project
Last week:
1. Worked on grant deliverable: updated prize analyses scripts and wrote the section in Overleaf.
2. Reviewed survey incentives documentation.
3. Updated the tool data.
4. Implemented, tested, and published the set of new questions in Qualtrics. I also updated the English and Spanish versions of the questionnaires.
5. Minor tasks: Assigned tasks to Vicente, asked Nico about Google Ads consultation and posted his answer in Asana, emails with J-PAL, reviewed old budget documentation to switch to the research account after depleting TFI funds, and updated our master budget.

This week:
1. Work on NBER IRB submission.
2. Review the last version of the follow-up survey.
3. Pilot the follow-up survey.
4. Finish all the pending tasks for the prize analysis (review my writing and update scripts).

### RA working for 1 professor on multiple projects
Last week:
1. Project A:
	1. Worked on updating non-adoption calculations (top priority for tomorrow’s meeting)
	2. Worked on updating survey weights
	3. Generated output directories, updated previous tables and scripts
2. Project B:
	1. Set up new git locally in server,
	2. Started replication (currently about 50% through).

This week:
1. Project A:
	1. Update survey weights
	2. Finish updating non-adoption calculations
	3. Finish updating above-below median number of workers heterogeneity
	4. Finish updating Asana with all previous comments
2. Project B:
	1. Finish replication

### RA working separately for multiple professors
Last week:
1. Sean:
	1. Updated survey with profits note and num of employees questions
	2. Tested new way to ask for banks/firms of POS in survey
	3. Updated manual of surveyor
	4. Summarized EMEC scripts
2. Jacopo:
	1. Analyzed the case of dscrgrp variable from ESS
	2. Produced correlation tables (ESS, Gallup)
	3. Produced new graphs about dscr variables

This week:
1. Sean:
	1. Figure out what is going on with the NAs
	2. Add pre-survey questions about finding the owner of the retail
2. Jacopo:
	1. Figure out what is going on with some countries and number of respondents in ESS

## iv. Professional development meetings
We will have regularly scheduled (monthly or quarterly) professional development meetings to provide feedback to each other, help pinpoint strengths I can highlight in a letter of recommendation, discuss areas to improve (which will be a mandatory point in each meeting, so don’t interpret feedback on areas to improve as a bad sign), and check in on the status of your preparation for grad school applications.
 
In general, we can discuss the following things in the meeting:

1. **Graduate school preparation**
    - What classes are you taking/how are they going?
    - Status of GRE/TOEFL/anything else you need to do for grad school applications
    - Give me feedback: how can I do a better job mentoring/supporting you?
2. **RA work**
    - What were you most proud of this month/quarter?
    - What do you think you could improve on?
    - What areas would you like to grow?

By 5pm the night before the meeting, please e-mail me with:

1. Graduate school preparation:
    - An outline of how your graduate school preparation is going (if applicable)
2. RA work:
    1. A brief summary of what you've accomplished in the last month.
    2. Describe areas you can improve.
    3. Discuss things you'd like to grow into.
3. An outline of other issues you'd like to discuss

At the end each meeting, remember to schedule next month's/quarter's meeting. You can set up a repeating Google Calendar event with an email reminder a few weeks before to confirm the date and time.

## v. Keeping track of conference and presentation deadlines
### Reminder system
One important aspect of RA work is keeping track of deadlines related to presentations and grants. Professors must keep track of several deadlines: 
- Applications to dozens of conferences over the course of a single year to present their current work
- Sending paper drafts to discussants on time
- Preparing slides for presentations
- Submitting grand deliverables

Managing this manually is both time consuming and often leads to unwanted errors. I wrote a series of scripts ([remindR](https://github.com/clandinq/remindr)) to help project managers, researchers, research assistants and students keep track of deadlines related to academic projects. This system can send out four types of reminders:
1.	Future conference reminders. These are reminders to check if future conferences have announced details that would allow to track them (deadlines, submission links, and descriptions).
2.	Conference deadlines. Reminders to submit papers or abstracts to conferences.
3.	Upcoming presentations. Reminders for upcoming presentations, including slide submission deadlines.
4.	Grant deadlines. This can be useful both when applying for grants and when submitting grant deliverables.

Follow the instructions on the repo to set up remindR in your computer. The system is easy to set up, works with Mac OS X and Windows, and can be constantly modified when we’re notified of new deadlines. Please confirm with Sean / other PIs whenever you add a deadline to one of the lists. Also, it is important to keep track of the log to see that the system is working smoothly, and raise an issue on GitHub whenever there is a coding issue.

### Calendar with conference dates
Along with this reminder system, you should create a new calendar where you make all-day events for conferences we have applied, are applying to, and are presenting in. This way, we can determine whether there are any overlapping conferences and choose which one to apply to. 

Event titles should begin with **APP:** if applied or are applying to the conference, and **PRES:** if we are presenting at a conference. Include more details in the event description, including the conference website. Below is an example of a situation where having calendar events proved helpful: we found a conflict between two conferences and decided PIs could present in both.

<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/calendar.png" align="center" height="60%" width="60%">        

## vi. Holidays and time off

### University policies on holidays and time off

- **Paid university holidays**. You can view the university holiday calendar [here](https://www.northwestern.edu/hr/benefits/leaves-holidays/university-scheduled-holidays.html). In cases when you have to work on an official holiday, you can make up by taking an alternate workday off. For example, in your timesheet, you would register the working hours during that day and add a note in the “Time off” sheet that says you have an extra vacation day.
- **Vacation time**. During your first year, you will have 2 weeks of vacation time. After you have completed one year, you will have 3 weeks of vacation time per year. Any week where you want to take a vacation day would have 8 fewer hours of expected work. You can view more details [here](https://www.northwestern.edu/hr/benefits/leaves-holidays/vacation-time.html).
- **Personal floating holidays**. [Personal floating holidays](https://www.northwestern.edu/hr/benefits/leaves-holidays/personal-floating-holidays.html) are available for personal use and may be used as an extension of vacation time. The number of personal floating days available depend on the hire date. Hires from September 1 to November 30 (as it is the case with most RAs) will have 3 personal floating holidays available during the fiscal year (September 1 to August 31). Personal floating holidays unused at the end of the fiscal year are forfeited.
- **Vacation payouts**. Staff members will be paid out their accrued and unused vacation time and personal floating holidays at the termination of their contract. You can find more information about the process [here](https://www.northwestern.edu/hr/benefits/leaves-holidays/vacation-time.html).
- **Sick days**. 15 [sick days](https://www.northwestern.edu/hr/benefits/leaves-holidays/sick-time/incidental-sick-time.html) available per year.

### Process for taking time off
1. Ask for permission to supervisors.
2. Add days off to [WFS](https://www.northwestern.edu/hr/essentials/hr-systems/timekeeping/instructions.html).
3. Forward approval to department manager.
4. Send supervisors a calendar invite for an all-day event titled “RA *name* day off” for the days you will be out.

The process for days off if you are going to make up the hours and not take a vacation day are steps 1 and 3 above.

# 2. Keeping files organized
## i. General project organization
In academic projects, it's essential to keep files synchronized between multiple computers and backed-up over time. This allows to easily share scripts and results with PIs, keep raw and processed data backed up, maintain a record of changes in different files, and permit other RAs and PIs to work on the same papers, presentations and scripts. We accomplish all of these tasks with the help of Dropbox, Github and Overleaf: Dropbox mainly for backing-up data, GitHub to track the history of file changes and update files, and Overleaf to allow PIs to easily modify papers without having to use a Latex processor. This system also integrates with the KLC server for processing large datasets.

Our system works the following way:
1. **Local folder set-up and structure**. For existing projects, you should [clone the repo in your computer](#setting-up-an-existing-repo-on-the-server-or-a-new-computer). If this is a new project, start by setting up a local project folder with the following structure:
    - **admin**: This folder should contain administrative files, for example agreements, contracts, and grant proposals.
    - **data**: Only raw data go in this folder.
    - **documentation**: Documentation about the data goes in this folder.
    - **logs**: Only create this folder when generating logs from running scripts on the server.
    - **paper**: Paper tex and pdf documents.
    - **pictures**: Any pictures to be included in the paper or presentation.
    - **presentations**: Presentation tex and pdf documents.
    - **proc**: Processed data sets go in this folder.
    - **results**: Results go in this folder.
        - **figures**: Subfolder for figures.
	- **tables**: Subfolder for tables.
    - **scripts**: Code goes in this folder
        - **programs**: A subfolder containing functions called by the analysis scripts (if applicable).
    - An .Rproj file for the project. (This can be created in RStudio, with File > New Project.).
    You will normally work in your local folder unless working with large datasets or complex scripts (when you will have to use the server).

2. **Keep files backed-up and updated with GitHub**
    - Git is an open-source version control system that helps track file changes across time. GitHub is a company that hosts Git repositories (project folders), including the full history of each file. For example, for any given script that is constantly synchronized with GitHub, you can access the different versions of the script you had backed up over time. You can learn more about Git and GitHub [here](https://docs.github.com/en/get-started/using-git/about-git). 
    - If you set up a new project folder from scratch, follow the [instructions](#setting-up-a-new-repo-on-github-and-cloning-locally) to set up a new GitHub repo.
    - Every time you are done making important changes to a file, want to back-up your work or share it with another project member, you should [push your changes to GitHub](#updating-the-github-repo). At the same time, during this process you will import the changes made (pushed) by other users to the repository (repo).
    
3. **Back up data with Dropbox**
    - Dropbox is mainly used for backing-up raw datasets. This can help reduce disk usage when working with large datasets, as you can delete the raw dataset from your local `data` folder and still be able to access it on Dropbox. We also use Dropbox for keeping constant backups of results and scripts that can easily be shared with PIs.

4. **Working on papers using Overleaf**
    - Some PIs prefer to work on papers using Overleaf, and it can also be useful to access and edit papers and presentations from any computer. To sync with GitHub, the users who want to make changes on Overleaf must have a Premium Overleaf subscription, either the Standard or Professional plan. Project members that don't need to make changes on Overleaf do not need to have a Premium subscription.
  
5. **Working on the server**
    - When working from the server, you will [set up the GitHub repo on the server](#setting-up-an-existing-repo-on-the-server-or-a-new-computer) and keep scripts and results backed-up with GitHub.
    - Files can be sent (raw data) and retrieved (processed data) using [FileZilla](#transferring-files-via-filezilla)

The system is summarized in the following chart:

<img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/org_map.png" align="center" height="30%" width="30%">        

## ii. Working with GitHub
GitHub is used to help facilitate sharing results and scripts with PIs and other research assistants, ensuring reproducibility of code, and having an up-to-date backup of current work, along with version control.
### Setting up a new repo on GitHub and cloning locally
1. Create new repo on GitHub, including a template .gitignore file. Modify .gitignore file on GitHub to include additional folders and files to exclude from updates: documents, data and certain file types.
2. Type the following commands in terminal:
    1. Change to directory where repo will be cloned 
        ```sh
        cd work
        ``` 
    2. Clone repo
        ```sh
        git clone https://github.com/user123/myproject
        ```

### Setting up an existing repo on the server or a new computer
KLC folders should be set up using Github (as if they were additional computers), so it’s easy to keep track of changes and sync files between the server and your local computer.

#### If there is already a folder set up on the server or computer and that be linked to the GitHub project repo
Type the following commands in the terminal:
1. Change directory to the existing folder
    ```sh
    cd existing_folder
    ``` 
2. Initialize repo
    ```sh
    git init
    ``` 
3. Link to existing repo
    ```sh
    git remote add origin https://github.com/user123/myproject
    ``` 
4. Git fetch using personal access token instead of password (https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
    ```sh
    git fetch
    ``` 
5. Checkout (here substitute main for master if master is name of branch generated on Github).
    ```sh
    git checkout origin/main -ft
    ``` 

#### If there is no folder set up on the server/computer:
Type the following commands in the terminal:
1. Change to directory where repo will be cloned 
    ```sh
    cd work
    ``` 
2. Clone repo
    ```sh
    git clone https://github.com/user123/myproject
    ```

### Updating the GitHub repo
First, modify files locally. Then, type the following commands in the terminal:
1. Change directory to project folder
    ```sh
    cd work/myrepo
    ``` 
2. Add new and modified files
    ```sh
    git add .
    ``` 
3. Review added files
    ```sh
    git status
    ``` 
4. Commit files and add a message
    ```sh
    git commit -m “This message describes what was changed in the current commit"
    ``` 
5. Get most up to date code from remote repo.
    ```sh
    git pull
    ```
6. Push changes to remote repo
    ```sh
    git push
    ```

### Creating a fork of a repo and making a pull request    
To make changes in repos where you are not the collaborator, you need to fork (create your own version of) the repo, make changes, and make a *pull request* to merge these changes back into the original repo. Follow these steps to fork a repo and create a pull request:

1. Install the [GitHub Command Line Interface (CLI)](https://cli.github.com/). If you have [Homebrew](https://brew.sh/) installed (on Mac OS X), you can install by typing on the command line `brew install gh`.
2. [Fork the repo](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
    ```sh
    gh repo fork https://github.com/otheruser/repo_a
    ``` 
3. Clone forked repo
    ```sh
    git clone https://github.com/myuser/repo_a
    ``` 
4. Change directory to local folder
    ```sh
    cd repo_a
    ``` 
5. Make changes to files locally 
6. Add, commit and push changes. This updates files on your own fork of the repo.
7. Change directory to local folder
    ```sh
    git add .
    git commit -m “Add a message here”
    git push
    ```   
8. Create [pull request](https://cli.github.com/manual/gh_pr_create). Add title, insert details in body (if necessary) and submit pull request. Select other user’s repo as base repo.
    ```sh
    gh pr create
    ```   

## iii. Working with Dropbox
- Keep all raw data backed up in the Dropbox. You should **never** save scripts directly or reference raw data that in the Dropbox project folder.
- The Dropbox folder can also contain administrative files and presentations that are not required in the GitHub.
- All files from the local project folder (the one synced with GitHub) except `data` should be routinely copied from the local folder over to Dropbox to keep a back-up of all files. We accomplish this using a [shortcut](#v-keeping-github-and-dropbox-updated) that substitutes multiple git commands and copies the data to Dropbox.
- For large project folders you will need a Dropbox Plus account. The easiest way to get it is to buy it (choose the “billed yearly” option for the price discount – it costs about $100) and then send the receipt to [Adam Troutman](adam.troutman@kellogg.northwestern.edu) and you will receive reimbursement into the bank account where you are paid by Northwestern. 

## iv. Working with the Kellogg Linux Cluster (KLC) server
Processing of large datasets (dataset size approximating RAM size) should be done on KLC. The workflow is the following:
1. Write scripts locally and push to GitHub.
2. Upload raw files with FileZilla to KLC, update server with scripts using GitHub.
3. Update results produced in server with GitHub.

### Transferring files via FileZilla
You should only upload and download data (both raw and proceessed) via [FileZilla](https://filezilla-project.org/), and keep updated results and scripts using GitHub. To upload new files, you can input the following on FileZilla:
- **Host**: klc.ci.northwestern.edu
- **Username**: Your NetID
- **Password**: Password for your NetID
- **Port**: 22
To upload files, drag to the selected folder on the right pane. To download files, right click download.

### Accessing KLC
1.	If you’re not connected to a network at Northwestern, use [GlobalProtect](https://kb.northwestern.edu/page.php?id=94726) to connect via VPN.
2.	If you have a Mac, open the terminal. If you have Windows, first install Cygwin so that you can use Linux commands from the command line, then you can open the command line with Windows+R, type cmd, Enter.
3.	In the terminal or command line, type:
    ```sh
    ssh <netID>@klc.ci.northwestern.edu
    ```
4.	Enter the password you created for your netID.
5.	Now you should be connected to KLC. 

### Running scripts
Once you have (1) set up GitHub to work with the KLC folder, (2) uploaded necessary data files, and (3) updated scripts using GitHub, there are two ways to run scripts on the server:
#### Running files with a 00_run script and no visible output
This first version will generate logs and return the command line for other work.
```sh
cd path_of_project_folder
module load stata/17 # or module load R/4.0.3 [or latest; check what’s available with module avail R]
nohup R CMD BATCH --vanilla -q scripts/00_run.do logs/00_run.log & # Nohup is so that if you get logged out the script keeps running.
```
#### Running do files (Stata) with visible output
The second option will display the output on the terminal.
```sh
cd path_of_project_folder
module load stata/17
stata-mp
# Set base directory and relative file paths
do scripts/myscript.do
```
## v. Keeping Github and Dropbox updated 
- We use Dropbox as a backup folder and to easily share files with PIs. Since copying files manually to update the Dropbox is a tedious task, and we are interested in mantaining the folder up to date, we developed a shortcut that substitutes multiple git commands and copies the data to Dropbox. This reduces the time necessary to update the git (making it easier to make multiple commits and keep the git up to date), and makes it much easier to keep Dropbox in sync with the git (instead of having to manually copy files every time you make a commit).
- Files we only want in Dropbox and not in the git (for example, admin files) will not be modified by this system, as they are never involved in a commit.
- Processed data will also not be linked to Dropbox. Anyone who needs to have the processed data will need to run the scripts to obtain the data in proc/ on their local git folder. 
 
### Setting up and running dual Github-Dropbox updates
1. Download and edit Github to Dropbox backup script.
    1. Download the file [github_to_dropbox.R](/scripts/github_to_dropbox.R) and put it in your local project folder inside /scripts/programs/.
    2. Update the path of the Dropbox folder where files should be routinely backed up to.
            
	    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/gh_db_1.png" align="center" height="60%" width="60%">

2. Add shortcuts to bash profile.
    1. Open a new terminal window and edit the bash profile:
        ```sh
        vi ~/.zprofile
        ``` 
    2. Insert at the bottom of the bash profile the following lines:
		```sh
		function logupdate () {
		    echo "********Pull from repo"********"
		    git pull
		    echo "********Push recent changes to repo"********"
		    git push
		    echo "********Export commit to log********"
		    echo "Generating log..."
		    git log --name-status HEAD^..HEAD > "$(pwd)/git_log.txt"
		    echo "********Update Dropbox********"
		    echo "Updating files on Dropbox..."
		    Rscript $(pwd)/scripts/programs/github_to_dropbox.R
		}
		
		function gitcommit () {
		    echo "********Adding all files to commit********"
		    git add .
		    git commit -m $@
		    logupdate
		}
		``` 
		The first function pulls and pushes a recent commit, generates a log of this commit, and mirrors the same changes on Dropbox. The second function adds all files to the commit and runs the first function. To add only certain files to the commit, do the commit manually  (`git add file_special; git commit -m "Upload only one file"`) and the run `logupdate`.

    3. Save the bash profile (press Escape, type :wq, and hit Enter)

3. Make changes and run Github - Dropbox dual backup shortcut. Remember to change directory to the desired project folder.
    ```sh
    cd project_folder
    gitcommit "My first commit with the shortcut"
    ``` 
    
    <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/gh_db_2.png" align="center" height="80%" width="80%">
	    
# 3. Coding best practices
## i. Working with eps figures
Working with .eps files is useful because of their high resolution and ability to modify them. However, Latex can only compile PDF files, so we must use the package `epstopdf` to convert files automatically to .eps when compiling. Sometimes, the `epstopdf` package will not generate a PDF file. The following steps have been useful to solve this issue:
1.  Use script [gen_figures.R](https://github.com/skhiggins/ra_guide/blob/main/scripts/gen_figures.R) to make a list with all .eps files included in the folder /results/figures, and generate a .tex document with all of them.
2.  Force full typeset this document to convert all eps figures to PDF.

## ii. Generating different presentation versions
When presenting papers in academic conferences, we will have to generate multiple versions of presentations with different lengths, changing which slides are included in the main presentation and which slides are sent to the appendix. The following system helps generate multiple versions of presentations while keeping them all up to date with the latest content and reducing the need for making manual changes:

1. **Update master presentation**. 
    - Generate a "master presentation" with all of the slides that can be included in the different presentation versions.
    - To modify a slide for all presentations, make changes in the master presentation. 
	- Keep all slides clearly labeled, with labels defined as *group*_*slidename*. For example, a slide in the model section could be labeled *model_introduction*, and a slide in the results section discussing takeup *takeup_overall*. Labels have to be included in the line immediately following `\begin{frame}`:

        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/pres_tex_1.png" align="center" height="45%" width="45%">
	- Insert all buttons to slides that could or will be in the appendix in the master presentation. 
        - If a slide is included in the main part of the presentation, any buttons from other slides in the main presentation to that slide will be removed. 
        - For example, if slides A and B are included in the main presentation, they will not have any buttons referencing each other. If slide A is in the main presentation and slide B is in the appendix, buttons from slide A to B and slide B to A will not be removed.
	    
            <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/pres_tex_2.png" align="center" height="60%" width="60%">

2. **Define which slides to include in main presentation and in presentation appendix**. 
	- If this is the first time using this system, run script [presentation_versions.R](https://github.com/skhiggins/ra_guide/blob/main/scripts/presentation_versions.R) to generate /presentations/slide_dataset.xlsx. Remember to first update the name of the master presentation (line 25).
	- To define what content will be in a presentation, modify the relevant presentation colum in presentations/slide_dataset.xlsx. For example, the content for the 15-minute version of the presentation is defined in the column titled “15”.  Each slide can be included in the main part of the presentation, in the appendix, or not included at all. To include a slide in the main part of the presentation, mark the slide as 1. To include the slide in the appendix, mark the slide with a 2. To omit the slide, mark the slide with a 0.
	- Both slides included in the main part and in the appendix have the same order as in the master presentation. To update the order, the master presentation must be updated. 
    	    
        <img src="https://github.com/skhiggins/ra_guide/blob/main/pictures/pres_tex_3.png" align="center" height="60%" width="60%">
3. **Update and run the presentation versions script**.
	1. Update the presentation or presentations to modify (line 95) in script [presentation_versions.R](https://github.com/skhiggins/ra_guide/blob/main/scripts/presentation_versions.R).
	2. Run the full script to generate the desired .tex document.
4. **Compile the presentation and push changes to GitHub**.

**Note**: The person updating the master presentation should also run the presentation versions script and push to GitHub, to ensure all presentations are kept up to date.
