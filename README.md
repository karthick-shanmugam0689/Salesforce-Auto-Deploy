# Hi Salesforce Devs,

Welcome to Auto-Deployment Process with respect to Salesforce. For sure once in our lifetime when working with Salesforce, we might have faced issues with deployment because of which we will sought the help of third party libraries or systems to help in deployment process (which is sometimes costlier)

But why we need to do this? Are we not able to develop our own libraries to do this?

There are tonnes of libraries waiting outside for us to use them to elivate our worries

I have introduced a new tool with the help of ANT which can be used with Jenkins and GitHub integration plugin for Jenkins with almost zero-configurations required from your side

Repo URL : https://github.com/karthick-shanmugam0689/Salesforce-Auto-Deploy

For you to do Auto-Deployment with Git-Jenkins, just I recommend you to fork this repo and use the scripts, how and ever you want.

Thanks to Jenkins and Github-Jenkins Integration plugin along with Force.com migration tool to have more features to be used.

### Please follow the below steps to be able to do Auto-Deployment to Salesforce

1. Configure Jenkins and install Github Integration plugin with Jenkins. Tonnes of tutorial available online to do this

https://wiki.jenkins.io/display/JENKINS/Git+Plugin

2. Create a new project in Jenkins with Github repo pointing to your repository and in the Build section of the project configuration setting page select "Invoke Ant" option and set Targets to "builderWithGitDiff" and properties as below

```
env.username=[Username with which you want to deploy]
env.password=[Password with Security Token]
env.serverurl=[Salesforce Instance URL]
env.branch=[Branch you want to deploy to the above mentioned Salesforce instance]
env.testClass=[Comma separated test classes to use]
env.clientId=[ClientId to connect to Salesforce instead of Username and password]
env.clientSecret=[Client Secret to connect to Salesforce instead of Username and password]
env.refreshToken=[Refresh token to connect to Salesforce instead of Username and password]
```

3. Tadaaaa --- Now you are done with Auto-Deployment. Click on Build Now for instance deployment or enable Poll SCM to opt for auto-deployment whenever you push to GIT 


Now lets see how the script works (so that in future you can modify the scripts however you want)

Before that just get to know about environmental variables offered by GITHUB-Jenkins integration plugin to do this


### Environment variables
The git plugin sets several environment variables you can use in your scripts:

**GIT_COMMIT** - SHA of the current

**GIT_BRANCH** - Name of the remote repository (defaults to origin), followed by name of the branch currently being used, e.g. "origin/master" or "origin/foo"

**GIT_LOCAL_BRANCH** - Name of the branch on Jenkins. When the "checkout to specific local branch" behavior is configured, the variable is published.  If the behavior is configured as null or **, the property will contain the resulting local branch name sans the remote name.

**GIT_PREVIOUS_COMMIT** - SHA of the previous built commit from the same branch (not set on first build on a branch)

**GIT_PREVIOUS_SUCCESSFUL_COMMIT** - SHA of the previous successfully built commit from the same branch (not set on first build on a branch)

**GIT_URL** - Repository remote URL

**GIT_URL_N** - Repository remote URLs when there are more than 1 remotes, e.g. GIT_URL_1, GIT_URL_2

**GIT_AUTHOR_NAME and GIT_COMMITTER_NAME** - The name entered if the "Custom user name/e-mail address" behaviour is enabled; falls back to the value entered in the Jenkins system config under "Global Config user.name Value" (if any)

**GIT_AUTHOR_EMAIL and GIT_COMMITTER_EMAIL** - The email entered if the "Custom user name/e-mail address" behaviour is enabled; falls back to the value entered in the Jenkins system config under "Global Config user.email Value" (if any)


### Lets visit the folder-structure in our git repo to understand the process

**lib** folder --> Tools enabling this auto-deployment process to work without any issues
          ant-contrib-1.0b3.jar --> For basic ant operations to support deployment process
          ant-salesforce.jar --> Force.com migration tool
          xmltask.jar --> xml tasks to generate package.xml for auto-deployment

**src** folder --> source code obtained from Salesforce containing objects, classes and so on

**build.properties** --> basic properties, configurations required for auto-deployment

**samplePackage.xml** --> sample package.xml to use for auto-deployment

### Now lets visit the build.xml file to see how the script works (It is the starting point and it the main part in our deployment process)

`builderWithGitDiff` --> 
         Takes the file-differences between GIT_PREVIOUS_SUCCESSFUL_COMMIT and GIT_COMMIT. 
         Checks whether the file-differences is a part of src folder
         If so, copies the files and paste it into deploy-sf folder which is created before
         Checks whether meta-xml files are required. If so copies that as well to deploy-sf folder
         Generates package.xml file to be used for deployment and place it under deploy-sf folder

`deploy` -->
         Deploys to salesforce with all the environmental variables used above

`deployProd` -->
         Deploys to Salesforce with all the environmental variales used above along with running of test classes

`validateProd` -->
         Validates the package in Salesforce with all the environmental variales used above along with running of test classes


As of now `deployProd` and `validateProd` commands are running with ClientId and Client Secret since most of the times we wish not to expose the username and password to the Prod environment, but you can change it if you want to

### Now lets see the properties in build.properties as you might need to know this as well if you want to change the configurations for yourself
```
sf.maxPoll = [maximum polling time to connect to Salesforce]

sf.deployDir = deploy-sf #deployment folder to use for Auto-Deployment
sf.samplePackageXML = samplePackage.xml #Sample package.xml file to use for deployment

#Categories to use for each and every component to use for generating package.xml for deployment
sf.classes = ApexClass 
sf.objects = CustomObject
sf.workflows = Workflow
sf.triggers = ApexTrigger
#sf.workflowFieldUpdate = WorkflowFieldUpdate
sf.email = EmailTemplate
sf.pages = ApexPage
sf.staticresources = StaticResource
#and so on....

response.regex = .*"access_token":"([.!a-z_A-Z0-9]*)".* #regex tokken to generate access-token if you are using client-id and client-secret to connect to Salesforce instead of Username and password
```
Now that's all. It is done. 

Change your build.xml and build.properties to suit your needs and start playing with it

