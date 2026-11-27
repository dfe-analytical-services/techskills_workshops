# Databricks notebook source
# /// script
# [tool.databricks.environment]
# environment_version = "6"
# ///
# DBTITLE 1,Introduction to Workflows
# MAGIC %md
# MAGIC
# MAGIC # Jobs & Pipelines
# MAGIC
# MAGIC The Jobs & Pipelines tab allows you to build complex data pipelines by chaining together multiple scripts, queries, notebooks and logic. Each one of these is called a task.
# MAGIC
# MAGIC They can be used to build Reproducible Analytical Pipelines (RAP) that can be re-run with different parameters and have all inputs and outputs audited automatically. 
# MAGIC
# MAGIC In addition, Jobs and Pipelines can be set to run on a schedule or a trigger you define, and can be setup to notify people when it succeeds (/ fails).
# MAGIC
# MAGIC Other recommended uses of jobs and pipelines are any data modelling tasks such as cleaning your source data and collating it into a more analytically friendly format in your modelling area.
# MAGIC
# MAGIC The Jobs & Pipelines page can be accessed from the left-hand side bar. 
# MAGIC
# MAGIC ![./../../../images/jobs_location.png](././../../../images/jobs_location.png "./../../../images/jobs_location.png")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Below you will find a guide talking you through the creation of a job using the Databricks interface
# MAGIC
# MAGIC If you would like to create the same job using code, see the `02 Using Jobs & Pipelines - Databricks API` notebook in this folder.
# MAGIC
# MAGIC ### You can also create a job with yml code.
# MAGIC
# MAGIC To see how to do something in yml we recommend you use one of the below methods to create a pipeline and then click "Edit as YAML" from the dropdown next to the blue "Run now" button in the top left.
# MAGIC
# MAGIC ![./../../../images/jobs_yaml.png](././../../../images/jobs_yaml.png "./../../../images/jobs_yaml.png")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Benefits of Jobs
# MAGIC
# MAGIC There are some key benefits of jobs:
# MAGIC 1. They chain together tasks in a set order, this improves the reproducibility of the task, enables easy identification of failures.
# MAGIC 2. Jobs can be scheduled, this both means that they can run automatically without user input and that they can be specified to run at less energy taxing times of the day.
# MAGIC 3. Jobs are processes as code, meaning that they can be stored in git accounts, change managed, and migrated easily.
# MAGIC 4. Jobs enable you to build in the approval step into the run.
# MAGIC
# MAGIC ## Cons of Jobs
# MAGIC
# MAGIC There are also a few cons to jobs:
# MAGIC 1. Once set-up with a schedule a job will run until a user specifies it to stop, this means that energy and money might be wasted.
# MAGIC 2. Jobs are a more complex way of running notebooks and code, meaning that they add an extra layer of maintenance that might not be necessary.
# MAGIC 3. Code cannot be edited inline as a job runs.
# MAGIC 4. Give a false sense of security, jobs can fail just like scripts, and a green tick mark doens't always mean it succeeded.

# COMMAND ----------

# DBTITLE 1,Tasks and dependencies
# MAGIC %md
# MAGIC ## Tasks and dependencies
# MAGIC
# MAGIC Each step in a Job or Pipeline is referred to as a task and each task can have dependencies, which are other tasks that must have run before it. 
# MAGIC
# MAGIC Tasks are usually scripts, or Notebooks which can be held either in your Databricks Workspace, or (preferably) in a Git repository either on Github or Azure DevOps. 
# MAGIC
# MAGIC Below is an example of a Job with two tasks. The last task will only run once all other tasks have completed as it is dependant on them having completed.
# MAGIC
# MAGIC ![./../../../images/jobs_tasks.png](././../../../images/jobs_tasks.png "./../../../images/jobs_tasks.png")

# COMMAND ----------

# DBTITLE 1,Auditing
# MAGIC %md
# MAGIC ## Auditing
# MAGIC
# MAGIC Each time a Job or Pipeline is run, Databricks audits:
# MAGIC - any input parameters
# MAGIC - all outputs
# MAGIC - the success and failure of each task
# MAGIC - when it was run and who by
# MAGIC
# MAGIC ![./../../../images/jobs_synopsis.png](././../../../images/jobs_synopsis.png "./../../../images/jobs_synopsis.png")
# MAGIC ![./../../../images/jobs_run_history.png](././../../../images/jobs_run_history.png "./../../../images/jobs_run_history.png")
# MAGIC
# MAGIC This makes Jobs and Pipelines a very powerful debugging tool as you can refer back to results from previous runs. This means that if your pipeline fails you can review the notebook(s) that failed and troubleshoot the issue.
# MAGIC
# MAGIC ![./../../../images/jobs_fail_history.png](././../../../images/jobs_fail_history.png "./../../../images/jobs_fail_history.png")
# MAGIC ![./../../../images/jobs_failure.png](././../../../images/jobs_failure.png "./../../../images/jobs_failure.png")
# MAGIC
# MAGIC Jobs and Pipelines that fail also allow you to repair the job or pipeline once you have found and fixed the issue. This prevents having to re-run the whole pipeline from scratch and allows it to pick up from the point where it failed.

# COMMAND ----------

# DBTITLE 1,Building a Workflow in the UI
# MAGIC %md
# MAGIC
# MAGIC # Building a job or pipeline using the Databricks Jobs & Pipelines user interface
# MAGIC
# MAGIC For this section we will use the notebooks stored in `Databricks_workshops/Databricks workshop/04 Using Jobs & Pipelines/jobs and pipelines notebooks` to build a job using the user interface.
# MAGIC
# MAGIC The job will take a catalog as a parameter. Within that catalog it will
# MAGIC
# MAGIC  - Create a schema called 'shared' if it doesn't already exist (01 - Create schema if not exist)
# MAGIC  - Create a table called 'shared_table_runs' if it doesn't already exist (02 - Create table if not exist)
# MAGIC  - Insert a row into the table of the current user and the time the row was inserted (03 - Insert data)
# MAGIC  - Select all the rows from the table and display them (04 - Select from table)
# MAGIC
# MAGIC Before following this exercise it is recommended that you look over the Notebooks in the `jobs and pipelines notebooks` folder and familiarise yourself with the syntax for each step.

# COMMAND ----------

# DBTITLE 1,Create a new workflow
# MAGIC %md
# MAGIC ## Create a new job / pipeline
# MAGIC
# MAGIC Right click on the 'Jobs & Pipelines' option in the left hand menu and click 'Open in a new window'.
# MAGIC
# MAGIC In the Jobs & Pipelines page click the blue 'Create job' button on the right hand side and then 'Job'.
# MAGIC
# MAGIC ![./../../../images/jobs_creation.png](././../../../images/jobs_creation.png "./../../../images/jobs_creation.png")

# COMMAND ----------

# DBTITLE 1,Job naming
# MAGIC %md
# MAGIC You will then be presented with a page titled 'New Job [timestamp]' which you can edit to give the job a meaningful name.
# MAGIC
# MAGIC For the purposes of this exercise title the job 'test_job_[your name]'.
# MAGIC
# MAGIC ![./../../../images/jobs_add_task.png](././../../../images/jobs_add_task.png "./../../../images/jobs_add_task.png")

# COMMAND ----------

# DBTITLE 1,Workflow settings
# MAGIC %md
# MAGIC ## Job settings
# MAGIC
# MAGIC The 'Job Details' panel **on the right** allows you to configure job level schedules and triggers, parameters which will be accessible to **all tasks in the job**, email notifications for successful / failed runs, and permissions on who can access and run the job. You can also add tags and descriptions to your job to help you keep track of them. This is different from **Task Parameters**, which you can find in the panel below the task when you **click on the Task**.
# MAGIC
# MAGIC This job will create a schema in your modelling area titled `shared`, however due to the way permissions work on Databricks the person to create the schema will become it's owner, meaning no one else can use it. For this (and probably most) purposes we need anyone with access to the catalog to have the ability to use the schema, so the job will address this too by setting the owner to the *group* that manages the database.
# MAGIC
# MAGIC #### Finding your group name
# MAGIC
# MAGIC To do this we'll need to `ALTER` the `OWNER TO` the name of the group that owns the catalog. This will be done by one of the notebooks in the job, but we need to add it as a parameter so that notebook is able to set the permissions to the correct group. 
# MAGIC
# MAGIC To find the group name navigate to your catalog in the 'Catalog Explorer' and then click the 'Permissions' tab. There should be a table with the headings 'Principal', 'Privilege' and 'Object'. You'll want to copy the Principle' name with "RWC" (Read / Write / Create) in it and add it as the value for the 'owner_group' job parameter (see below) and give 'Can Manage' permissions.
# MAGIC
# MAGIC ![./../../../images/jobs_permissions.png](././../../../images/jobs_permissions.png "./../../../images/jobs_permissions.png")
# MAGIC
# MAGIC ### Task Parameters
# MAGIC
# MAGIC Click the '+ Add' button under 'Parameters' then add a parameter with a 'Key' of 'catalog' and a 'Value' of the name of your teams data catalog. Add a second parameter with a 'Key' of 'owner_group', and a value of the RWC (Read / Write / Create) group that manages the catalog. Remember to click on a task to see the parameters below.
# MAGIC
# MAGIC ![./../../../images/jobs_task_parameters.png](././../../../images/jobs_task_parameters.png "./../../../images/jobs_task_parameters.png")
# MAGIC
# MAGIC ### Task Notifications
# MAGIC
# MAGIC Next, let's also setup a notification to tell us when the job has finished. Click the '+ Add' button under the 'Notifications' header then click the 'Add notification' button.
# MAGIC
# MAGIC In the 'Select a destination' box choose 'Email address' and type in your email address ensure that the 'Success' and 'Failure' are ticked then click 'Save'. 
# MAGIC
# MAGIC ![./../../../images/jobs_task_notifications.png](././../../../images/jobs_task_notifications.png "./../../../images/jobs_task_notifications.png")
# MAGIC
# MAGIC ### Job Parameters and Notifications
# MAGIC
# MAGIC Similar to the above you can create parameters and notifications for the whole Job using the sidebar.
# MAGIC
# MAGIC ![./../../../images/jobs_parameters_and_notifications.png](././../../../images/jobs_parameters_and_notifications.png "./../../../images/jobs_parameters_and_notifications.png")

# COMMAND ----------

# DBTITLE 1,Defining tasks
# MAGIC %md
# MAGIC ## Defining tasks
# MAGIC
# MAGIC Now we'll need to define the tasks in the main window. 
# MAGIC
# MAGIC It's generally a good idea to give the name of the task a descriptive one, so for this job we'll just reuse the names of the notebooks for the task names. Task names can't have spaces in though so we'll use underscores (`_`) instead.
# MAGIC
# MAGIC ### Task Settings
# MAGIC
# MAGIC You can see the task settings by clicking on the task.
# MAGIC
# MAGIC ### Create schema if not exist
# MAGIC
# MAGIC Name the first task create_schema_if_not_exist. 
# MAGIC
# MAGIC You can leave the 'Type' as notebook, but change the 'Source' to 'Workspace' (if using a git repo you want to change this to "Git provider", set up the URL, and have the path to the notebook from the directory specified), then click the blue 'Edit' link to the right.
# MAGIC
# MAGIC ![./../../../images/jobs_git_selection.png](././../../../images/jobs_git_selection.png "./../../../images/jobs_git_selection.png")
# MAGIC
# MAGIC ![./../../../images/jobs_git_configuration.png](././../../../images/jobs_git_configuration.png "./../../../images/jobs_git_configuration.png")
# MAGIC
# MAGIC In the 'Git information' box put the following settings and click 'Confirm':
# MAGIC
# MAGIC - Git repository URL: https://github.com/dfe-analytical-services/techskills_workshops
# MAGIC - Git provider: GitHub
# MAGIC - Git reference: main (branch)
# MAGIC
# MAGIC This ensures that the job runs the code from this Git repository on the 'main' branch.
# MAGIC
# MAGIC Once you've set your git settings set the 'Path' to `/jobs and pipelines notebooks/01 - Create schema if not exist`.
# MAGIC
# MAGIC Change the compute to your personal cluster.
# MAGIC
# MAGIC ![./../../../images/jobs_cluster.png](././../../../images/jobs_cluster.png "./../../../images/jobs_cluster.png")
# MAGIC
# MAGIC Click Create task.

# COMMAND ----------

# DBTITLE 1,Create table task
# MAGIC %md
# MAGIC ### Create table if not exist
# MAGIC
# MAGIC Click the blue '+ Add task' button and choose 'Notebook' to add the second task. 
# MAGIC
# MAGIC Notice that it has assumed that this task 'Depends on' the previous task. In this case this is what we want, although in a more complex job we may want to change the dependent task, or add others. This can be done through the 'Depends on' field.
# MAGIC
# MAGIC For this task the settings should be the same as the previous task with the exception of the 'Task name' and 'Path' which should be as follows:
# MAGIC
# MAGIC - Task name: create_table_if_not_exists
# MAGIC - Path: /jobs and pipelines notebooks/02 - Create table if not exist
# MAGIC - Compute: _your personal cluster_

# COMMAND ----------

# DBTITLE 1,Insert Data task
# MAGIC %md
# MAGIC ### Insert Data
# MAGIC
# MAGIC Click the blue '+ Add task' button and choose 'Notebook' to add a new task. 
# MAGIC
# MAGIC For this task the setting should be the same as the previous tasks with the exception of the 'Task name' and 'Path' which should be as follows:
# MAGIC
# MAGIC - Task name: insert_data
# MAGIC - Path: /jobs and pipelines notebooks/03 - Insert data
# MAGIC - Compute: _your personal cluster_

# COMMAND ----------

# DBTITLE 1,Select from table task
# MAGIC %md
# MAGIC ### Select from table
# MAGIC
# MAGIC Click the blue '+ Add task' button and choose 'Notebook' to add a new task. 
# MAGIC
# MAGIC For this task the setting should be the same as the previous tasks with the exception of the 'Task name' and 'Path' which should be as follows:
# MAGIC
# MAGIC - Task name: select_from_table
# MAGIC - Path: /jobs and pipelines notebooks/04 - Select from table
# MAGIC - Compute: _your personal cluster_

# COMMAND ----------

# DBTITLE 1,Review workflow
# MAGIC %md
# MAGIC ## Review job
# MAGIC
# MAGIC Now you've added all the notebooks as tasks your job should look similar to the one below:
# MAGIC
# MAGIC ![./../../../images/jobs_overview.png](././../../../images/jobs_overview.png "./../../../images/jobs_overview.png")
# MAGIC
# MAGIC Assuming it does, click the blue 'Run now' button in the top right hand corner of the page. This will trigger a new run of the job and you'll likely get a pop up in the top right corner with a link to 'View run'. Click the link to watch the job run.
# MAGIC
# MAGIC > Note: To run the job your cluster must be running. If it isn't running when you click the 'Run now' button your cluster will begin to start up automatically however this may take a few minutes so will delay the running of the tasks.

# COMMAND ----------

# DBTITLE 1,Review the results
# MAGIC %md
# MAGIC ## Review the results
# MAGIC
# MAGIC Once the job has completed and (hopefully) succeeded running all the tasks click on the 'select_from_table' task box to view the notebook it ran and it's outputs.
# MAGIC
# MAGIC This should output a table with the names and run-times of everyone that has built and ran this job. 
# MAGIC
# MAGIC ![./../../../images/jobs_results.png](././../../../images/jobs_results.png "./../../../images/jobs_results.png")

# COMMAND ----------

with open("Quiz 01 Using Jobs & Pipelines - Databricks interface.html", "r", encoding="utf-8") as f:
    html_content = f.read()
    displayHTML(html_content)