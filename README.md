# ra_guide
Guidelines for research assistants

Contents:
1. [Managing meetings](#managing-meetings). Preparing agendas before meetings, sending meeting recaps and keeping a record of previous meetings.

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


# Keeping track of conference and presentation deadlines
One important aspect of RA work is keeping track of deadlines related to presentations and grants. Professors must keep track of several deadlines: 
- Applications to dozens of conferences over the course of a single year to present their current work
- Sending paper drafts to discussants on time
- Preparing slides for presentations
- Submitting grand deliverables

Managing this manually is both time consuming and often leads to unwanted errors. I wrote a series of scripts to help project managers, researchers, research assistants and students keep track of deadlines related to academic projects. This system can send out four types of reminders:
1.	Future conference reminders. These are reminders to check if future conferences have announced details that would allow to track them (deadlines, submission links, and descriptions).
2.	Conference deadlines. Reminders to submit papers or abstracts to conferences.
3.	Upcoming presentations. Reminders for upcoming presentations, including slide submission deadlines.
4.	Grant deadlines. This can be useful both when applying for grants and when submitting grant deliverables.

[remindR](https://github.com/clandinq/remindr) is easy to set up, works with Mac OS X and Windows, and can be constantly modified when we’re notified of new deadlines. Please confirm with Sean / other PIs whenever you add a deadline to one of the lists. Also, it is important to keep track of the log to see that the system is working smoothly, and raise an issue on GitHub whenever there is a coding issue.

