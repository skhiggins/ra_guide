# ra_guide
Guidelines for research assistants

# Working with GitHub
GitHub is worked to keep facilitate sharing results and scripts with PIs and other research assistants, ensuring reproducibility of code, and having an up-to-date backup of current work, along with version control.
## Setting up a new repo on GitHub and cloning locally
1. Create new repo on GitHub, including a template .gitignore file. Modify .gitignore file on GitHub to include additional folders and files to exclude from updates: documents, data and certain file types.
2. Type the following commands in terminal:
    1. `cd work` Change to directory where repo will be cloned
    2. `git clone https://github.com/user123/myproject` Clone repo
    3. `cd myproject` Change directory to repo


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
```
# Change to directory where repo will be cloned
cd work	
# Clone repo
git clone https://github.com/user123/myproject
# Change directory to repo
cd myproject
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
git commit -m “Message goes here"
``` 
6. Get most up to date code from remote repo (here substitute main for master if master is name of branch generated on Github).
git pull
7. Push changes to remote repo
git push


