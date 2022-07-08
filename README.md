# Guidelines for Research Assistants

Contents:
1. [Managing meetings](#managing-meetings). Preparing agendas before meetings, sending meeting recaps and keeping a record of previous meetings.
2. [Working with GitHub](#working-with-github). Setting up and using GitHub locally and in the server.
    1. [Setting up a new repo on GitHub and cloning locally](#setting-up-a-new-repo-on-github-and-cloning-locally)
    2. [Setting up an existing repo on the server or a new computer](#setting-up-an-existing-repo-on-the-server-or-a-new-computer)
    3. [Updating the GitHub repo](#updating-the-github-repo)
3. [Working with KLC](#working-with-the-kellogg-linux-cluster-klc-server). Setting up the server and keeping project updated with GitHub.
    1. [Accessing KLC](#accessing-klc)
    2. [Uploading files with FileZilla](#uploading-and-downloading-files-via-filezilla)
    3. [Running scripts](#running-scripts)
4. [Keeping track of conference and presentation deadlines](#keeping-track-of-conference-and-presentation-deadlines). Using [remindR](https://github.com/clandinq/remindr) to keep track of important deadlines.

# Managing meetings
1.	Send a meeting agenda as early as possible before each meeting with detailed items to discuss in the meeting and attaching all content relevant to the meeting. A useful way to remember is to set a calendar event with an email reminder for the agenda an hour or more before the meeting. Keep track of content for each meeting in Asana:
    1. Keep track of agenda items by adding them as tasks in an Asana project titled “Agenda”. 
    2. Make a different section for each recurring meeting, and update tasks with what was discussed in the presentation. 
    3. When tasks are complete, mark as complete and move to a section titled “Archive”.
2.	Send a meeting recap after each meeting with detailed notes about what was discussed in each meeting.
    1. Each item should have a discussion and tasks section.
        1. In the discussion section, write comments when possible as problem + potential solution.
        2. Immediately add items from tasks section to Asana.
    2. Upload summaries to a Google Docs document, and include this link in all recap emails.


# Working with GitHub
GitHub is worked to keep facilitate sharing results and scripts with PIs and other research assistants, ensuring reproducibility of code, and having an up-to-date backup of current work, along with version control.
## Setting up a new repo on GitHub and cloning locally
1. Create new repo on GitHub, including a template .gitignore file. Modify .gitignore file on GitHub to include additional folders and files to exclude from updates: documents, data and certain file types.
2. Type the following commands in terminal:
    1. Change to directory where repo will be cloned 
        ```
        cd work
        ``` 
    2. Clone repo
        ```
        git clone https://github.com/user123/myproject
        ```

## Setting up an existing repo on the server or a new computer
KLC folders should be set up using Github (as if they were additional computers), so it’s easy to keep track of changes and sync files between the server and your local computer.

### If there is already a folder set up on the server or computer and that be linked to the GitHub project repo:
1. Change directory to the existing folder
    ```
    cd existing_folder
    ``` 
2. Initialize repo
    ```
    git init
    ``` 
3. Link to existing repo
    ```
    git remote add origin https://github.com/user123/myproject
    ``` 
4. Git fetch using personal access token instead of password (https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
    ```
    git fetch
    ``` 
5. Checkout (here substitute main for master if master is name of branch generated on Github).
    ```
    git checkout origin/main -ft
    ``` 

### If there is no folder set up on the server/computer:
1. Type the following commands in terminal
    1. Change to directory where repo will be cloned 
        ```
        cd work
        ``` 
    2. Clone repo
        ```
        git clone https://github.com/user123/myproject
        ```

## Updating the GitHub repo
1. Modify files locally.
2. Change directory to project folder
    ```
    cd work/myrepo
    ``` 
3. Add new and modified files
    ```
    git add .
    ``` 
4. Review added files
    ```
    git status
    ``` 
5. Commit files and add a message
    ```
    git commit -m “This message describes what was changed in the current commit"
    ``` 
6. Get most up to date code from remote repo.
    ```
    git pull
    ```
7. Push changes to remote repo
    ```
    git push
    ```

# Working with the Kellogg Linux Cluster (KLC) server
Processing of large datasets (dataset size approximating RAM size) should be done on KLC. The workflow is the following:
1. Write scripts locally and push to GitHub.
2. Upload raw files with FileZilla to KLC, update server with scripts using GitHub.
3. Update results produced in server with GitHub.

## Uploading files via FileZilla
You should only upload and download data (both raw and proceessed) via [FileZilla](https://filezilla-project.org/), and keep updated results and scripts using GitHub. To upload new files, you can input the following on FileZilla:
- **Host**: klc.ci.northwestern.edu
- **Username**: Your NetID
- **Password**: Password for your NetID
- **Port**: 22
To upload files, drag to the selected folder on the right pane. To download files, right click download.

## Accessing KLC
1.	If you’re not connected to a network at Northwestern, use [GlobalProtect](https://kb.northwestern.edu/page.php?id=94726) to connect via VPN.
2.	If you have a Mac, open the terminal. If you have Windows, first install Cygwin so that you can use Linux commands from the command line, then you can open the command line with Windows+R, type cmd, Enter.
3.	In the terminal or command line, type:
    ```
    ssh <netID>@klc.ci.northwestern.edu
    ```
4.	Enter the password you created for your netID.
5.	Now you should be connected to KLC. 

## Running scripts
Once you have (1) set up GitHub to work with the KLC folder, (2) uploaded necessary data files, and (3) updated scripts using GitHub, there are two ways to run scripts on the server:
### Running files with a 00_run script and no visible output
This first version will generate logs and return the command line for other work.
```
cd path_of_project_folder
module load stata/14 # or module load R/4.0.3 [or latest; check what’s available with module avail R]
nohup R CMD BATCH --vanilla -q scripts/00_run.do logs/00_run.log & # Nohup is so that if you get logged out the script keeps running.
```
### Running do files (Stata) with visible output
The second option will display the output on the terminal.
```
cd path_of_project_folder
module load stata/14
stata-mp
# Set base directory and relative file paths
do scripts/myscript.do
```

# Keeping track of conference and presentation deadlines
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

