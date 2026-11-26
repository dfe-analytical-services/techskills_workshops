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
# MAGIC ## Below you will find a guide talking you through the creation of a job using the Databricks API
# MAGIC
# MAGIC If you would like to create the same job by clicking through the Databricks interface instead, see the `01 Using Jobs & Pipelines - Databricks interface` notebook in this folder.
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

# DBTITLE 1,Coded workflows
# MAGIC %md
# MAGIC ## Coded jobs
# MAGIC
# MAGIC Another useful aspect of jobs and pipelines is that they can be defined and ran using code through the [DataBricks Jobs API](https://docs.databricks.com/api/workspace/jobs).
# MAGIC
# MAGIC There is an R library which has been created to interface with the DataBricks API, meaning that you can script jobs in R using the [DataBricks SDK for R package](https://docs.databricks.com/en/dev-tools/sdk-r.html) using lists instead of JSON.

# COMMAND ----------

# DBTITLE 1,Scripting a workflow
# MAGIC %md
# MAGIC
# MAGIC # Scripting a job in Databricks
# MAGIC
# MAGIC Jobs can be constructed through the Databricks Jobs user interface (UI), however for large or complex jobs the UI can be a time consuming way to build a job. In these scenarios it is quicker and more inline with RAP principles to script your job.
# MAGIC
# MAGIC For a pipeline to be built there must be scripts, queries or notebooks available to read by Databricks, either located in your workspace, or in a Git repository.
# MAGIC
# MAGIC For this example we will use the notebooks stored in `/jobs and pipelines notebooks` as the tasks, and this notebook will use code (R) to create a job from them. We'll also set it up to notify us by email when the job successfully completes.
# MAGIC
# MAGIC The job constructed is the same as the one built in the `01 Using Jobs & Pipelines - Databricks interface` notebook.
# MAGIC
# MAGIC > **Note:** The default language of this notebook has been set to `R` to prevent us having to use the `%r` _magic command_ in every cell.

# COMMAND ----------

# DBTITLE 1,Terminology
# MAGIC %md
# MAGIC ## Terminology
# MAGIC
# MAGIC The terms 'workflow' and 'jobs' are used pretty interchangably in the UI of Databricks but 'workflow' is archaic. In the code of the `databricks` R package they are more frequently referred to as 'jobs'.
# MAGIC
# MAGIC For consistency with previous exercises this notebook uses the term 'job' but the meaning of a workflow or job is the same.
# MAGIC
# MAGIC A 'task' is a component of a workflow/job, and is always referred to as a 'task'.

# COMMAND ----------

# DBTITLE 1,Required packages
# MAGIC %md
# MAGIC ## Required packages
# MAGIC
# MAGIC In the chunk below we load the `tidyverse` package, then install the `devtools` package and load it. 
# MAGIC
# MAGIC We then use `devtools::install_github()` function to install the `databricks` package, then load it.
# MAGIC
# MAGIC We'll also require the `sparklyr` package and a spark connection (`sc`) to retrieve data from Databricks and bring it into R.

# COMMAND ----------

# DBTITLE 1,Install packages
# MAGIC %r
# MAGIC library(tidyverse)
# MAGIC install.packages("remotes")
# MAGIC library(remotes)
# MAGIC install.packages("devtools")
# MAGIC library(devtools)
# MAGIC
# MAGIC install_github("databrickslabs/databricks-sdk-r")
# MAGIC library(databricks)
# MAGIC
# MAGIC library(sparklyr)
# MAGIC
# MAGIC sc <- spark_connect(method = "databricks")

# COMMAND ----------

# DBTITLE 1,PAT widget intro
# MAGIC %md
# MAGIC Assuming you have generated a PAT, run the cell below to create the widget at the top of the page. Once the widget is there paste in your personal access token into the text box.

# COMMAND ----------

# DBTITLE 1,Create api_token widget
# MAGIC %r
# MAGIC dbutils.widgets.text("api_token", "")

# COMMAND ----------

# DBTITLE 1,Catalog and owner_group widgets
# MAGIC %md
# MAGIC We're also going to need a widget for the name of your modelling area (`catalog`) and the name of the group that owns the catalog (`owner_group`). These will be passed through to the job and so we need them accessible to the code.  
# MAGIC
# MAGIC Run the chunk below and then add in the values for the `catalog` and `owner_group` widgets.

# COMMAND ----------

# DBTITLE 1,Create catalog and owner_group widgets
# MAGIC %r
# MAGIC dbutils.widgets.text("catalog","")
# MAGIC dbutils.widgets.text("owner_group","")

# COMMAND ----------

# DBTITLE 1,Host widget
# MAGIC %md
# MAGIC Finally, we'll add a widget for the Databricks production URL called `host`. This isn't needed from a technical point of view, we could just hard-code it into the script as it is unlikely to change. 
# MAGIC
# MAGIC However, as this repository isn't access controlled and is available to the public on GitHub it would be more secure to keep the web address of the Departments data analytics platform out of the code. It also means if the URL for Databricks ever did change there would be less code maintenance.
# MAGIC
# MAGIC Run the chunk below and then populate it with the URL of this current page up until (and including) the first `/`.
# MAGIC
# MAGIC You'll need to remove the https:// part of the URL.

# COMMAND ----------

# DBTITLE 1,Create host widget
# MAGIC %r
# MAGIC dbutils.widgets.text("host","")

# COMMAND ----------

# DBTITLE 1,Connect to API
# MAGIC %md
# MAGIC ## Connect to Databricks through it's API
# MAGIC
# MAGIC We can now connect to the API through the `databricks` package using the `databricks::DatabricksClient()` function. It requires the `host` which and your token which we just defined above. We'll store the result in a variable called `client` as we need to pass this to the other functions in the `databricks` library, the same way we would have to pass an ODBC connection variable to a database query.

# COMMAND ----------

# DBTITLE 1,DatabricksClient connection
# MAGIC %r
# MAGIC host <- dbutils.widgets.get("host")
# MAGIC api_token <- dbutils.widgets.get("api_token")
# MAGIC
# MAGIC client <- databricks::DatabricksClient(host = host, token = api_token)

# COMMAND ----------

# DBTITLE 1,List clusters
# MAGIC %md
# MAGIC We can then use the `databricks::clustersList()` function to fetch a list of the clusters, which we can view using `display()`. To ensure we get the correct cluster though we'll also need our username(/email address) which we can get from Databricks using the `sparklyr` connection we set up earlier.

# COMMAND ----------

# DBTITLE 1,Get clusters list
# MAGIC %r
# MAGIC user_name <- sdf_sql(sc, "SELECT CURRENT_USER();") %>% collect() %>% as.character()
# MAGIC
# MAGIC clusters <- databricks::clustersList(client) %>% filter(single_user_name == user_name)
# MAGIC
# MAGIC display(
# MAGIC   clusters %>% 
# MAGIC     select(cluster_id, single_user_name, creator_user_name, cluster_name, spark_version, cluster_cores, cluster_memory_mb)
# MAGIC )

# COMMAND ----------

# DBTITLE 1,Select cluster_id
# MAGIC %md
# MAGIC
# MAGIC The `databricks::clustersList()` function will return any clusters that you have permission to see. Sometimes a user may have access to more than a single cluster, so we'll order the clusters by `spark_version` (descending) and take only the first result, then store it's id in a variable called `cluster_id`.
# MAGIC
# MAGIC > NOTE: The data returned by the function is hierarchical, and a single 'column' may contain several other columns. As the `display()` function renders a table, you'll have to select only columns that `display()` knows how to show. Generally, the columns that are at the left-most position when you run `str(clusters)` (shows the structure).

# COMMAND ----------

# DBTITLE 1,Store cluster_id
# MAGIC %r
# MAGIC cluster_id <- clusters %>% 
# MAGIC                 select(cluster_id, single_user_name, spark_version) %>% 
# MAGIC                 arrange(desc(spark_version)) %>%
# MAGIC                 filter(row_number() == 1) %>% 
# MAGIC                 pull(cluster_id)

# COMMAND ----------

# DBTITLE 1,Define workflow and tasks
# MAGIC %md
# MAGIC ## Define Jobs and tasks
# MAGIC
# MAGIC Now we have our connection to Databricks API and our `cluster_id` we'll start by setting some parameters for the job. 
# MAGIC
# MAGIC Firstly we'll need a `job_name`, and the paths to the Notebooks we're wanting to include in the job. We'll also need to create a unique `task_key` for each of the Notebook tasks we're going to set up.
# MAGIC
# MAGIC As the notebooks that we want to turn into tasks are stored in this repository we will need to provide relative paths (to the root folder of the repository). If we were referring to notebooks stored in our workspace but not a repository we would need to use absolute paths.

# COMMAND ----------

# DBTITLE 1,Define job name and paths
# MAGIC %r
# MAGIC job_name <- "test job"
# MAGIC
# MAGIC create_schema_key <- "create_schema"
# MAGIC create_schema_path <- "Databricks_workshops/Databricks workshop/04 Using Jobs & Pipelines/jobs and pipelines notebooks/01 - Create schema if not exist"
# MAGIC
# MAGIC create_table_key <- "create_table"
# MAGIC create_table_path <- "Databricks_workshops/Databricks workshop/04 Using Jobs & Pipelines/jobs and pipelines notebooks/02 - Create table if not exist"
# MAGIC
# MAGIC insert_data_key <- "insert_data"
# MAGIC insert_data_path <- "Databricks_workshops/Databricks workshop/04 Using Jobs & Pipelines/jobs and pipelines notebooks/03 - Insert data"
# MAGIC
# MAGIC select_from_table_key <- "select_from_table"
# MAGIC select_from_table_path <- "Databricks_workshops/Databricks workshop/04 Using Jobs & Pipelines/jobs and pipelines notebooks/04 - Select from table"

# COMMAND ----------

# DBTITLE 1,Task definitions explanation
# MAGIC %md
# MAGIC We can then define the tasks as lists. There are many options available available for setting when creating a task, a full list of which can be found in the tasks section of the [job API documentation](https://docs.databricks.com/api/workspace/jobs). When reading this documentation any parameter that is marked as an object needs to be passed as a list (`list()`) in R, and anything marked as an array should be passed as a vector (`c()`).
# MAGIC
# MAGIC For the first task we'll give it the first `task_key` we created above, and tell it to run on our existing cluster by passing the ID of our cluster to `existing_cluster_id`, we'll then specify that it is a `notebook_task` and pass that a list with the `notebook_path` and the `source` which we will set to `GIT` (as opposed to 'Workspace').

# COMMAND ----------

# DBTITLE 1,Create schema task
# MAGIC %r
# MAGIC create_schema_task <- list(
# MAGIC   task_key = create_schema_key,
# MAGIC   existing_cluster_id = cluster_id,
# MAGIC   notebook_task = list(
# MAGIC     notebook_path = create_schema_path,
# MAGIC     source = "GIT"
# MAGIC   )
# MAGIC )
# MAGIC
# MAGIC str(create_schema_task)

# COMMAND ----------

# DBTITLE 1,Second task explanation
# MAGIC %md
# MAGIC For the second task we will do the same, switching to the relevant `task_key` and `notebook_path`. In addition, we'll also add a `depends_on` clause with the previous `task_key` (passed in a list), and specify it is only to `run_if` `ALL_SUCCESS`. This means that the second task won't begin processing unless all of the tasks it `depends_on` have completed successfully.

# COMMAND ----------

# DBTITLE 1,Create table task
# MAGIC %r
# MAGIC create_table_task <- list(
# MAGIC   task_key = create_table_key,
# MAGIC   existing_cluster_id = cluster_id,
# MAGIC   notebook_task = list(
# MAGIC                     notebook_path = create_table_path,
# MAGIC                     source = "GIT"
# MAGIC                   ),
# MAGIC   depends_on = list(task_key = create_schema_key),
# MAGIC   run_if = "ALL_SUCCESS"
# MAGIC )
# MAGIC
# MAGIC str(create_table_task)

# COMMAND ----------

# DBTITLE 1,Third task explanation
# MAGIC %md
# MAGIC We'll do the same for the third task, this time switching the key, and path to the relevant variables defined above, and the dependencies to those of the `create_table_task`.

# COMMAND ----------

# DBTITLE 1,Insert data task
# MAGIC %r
# MAGIC insert_data_task <- list(
# MAGIC   task_key = insert_data_key,
# MAGIC   existing_cluster_id = cluster_id,
# MAGIC   notebook_task = list(
# MAGIC                     notebook_path = insert_data_path,
# MAGIC                     source = "GIT"
# MAGIC                   ),
# MAGIC   depends_on = list(task_key = create_table_key),
# MAGIC   run_if = "ALL_SUCCESS"
# MAGIC )
# MAGIC
# MAGIC str(insert_data_task)

# COMMAND ----------

# DBTITLE 1,Fourth task
# MAGIC %md
# MAGIC Finally we'll do the same with the last task.

# COMMAND ----------

# DBTITLE 1,Select from table task
# MAGIC %r
# MAGIC select_from_table_task <- list(
# MAGIC   task_key = select_from_table_key,
# MAGIC   existing_cluster_id = cluster_id,
# MAGIC   notebook_task = list(
# MAGIC                     notebook_path = select_from_table_path,
# MAGIC                     source = "GIT"
# MAGIC                   ),
# MAGIC   depends_on = list(task_key = insert_data_key),
# MAGIC   run_if = "ALL_SUCCESS"
# MAGIC )
# MAGIC
# MAGIC str(select_from_table_task)

# COMMAND ----------

# DBTITLE 1,Git details
# MAGIC %md
# MAGIC ## Git details
# MAGIC
# MAGIC Since we are running this job from a git repository we will need to pass the git details to the job definition. Specifically the URL of the repository, the Git provider, and the branch of the repository we are wanting to build the job from.

# COMMAND ----------

# DBTITLE 1,Define git_source_list
# MAGIC %r
# MAGIC git_source_list <- list(
# MAGIC           git_url = "https://github.com/dfe-analytical-services/techskills_workshops",
# MAGIC           git_provider = "gitHub",
# MAGIC           git_branch = "development/databricks_workshop_using_workflows"
# MAGIC         )

# COMMAND ----------

# DBTITLE 1,Parameters
# MAGIC %md
# MAGIC ## Parameters
# MAGIC
# MAGIC Finally, the tasks in the job have parameters, specifically the `catalog` to write data into and the `owner_group` of that catalog to ensure the permissions are set correctly for anyone in the group to modify any schemas/tables/views created.
# MAGIC
# MAGIC We could add parameters to each task individually, and if the values of those parameters was different for different tasks we would need to do this. Since the `catalog` and `owner_group` values are the same for each of our tasks we can simply add the parameters at a job level. These will be accessible to all the tasks within the job.
# MAGIC
# MAGIC The list of parameters is structured as a list which contains within it a list for each parameter with the values `name` and `default`. We could add our parameter values here as the `default` and therefore by default the parameters would always contain those values unless they were overridden by parameters passed at the time the job was run.
# MAGIC
# MAGIC Sometimes it is preferable for a job to fail than to make changes to database objects by accident. Having default values can run the risk of making it too easy to accidentally start a job without parameters and change the wrong database. This is a design decision that should be considered when building any automated job. 
# MAGIC
# MAGIC For the purpose of this tutorial, we'll leave the default values blank so that the job fails if there are no parameters passed on the basis that it removes any chance of an accidental run that could risk overwriting previous tables/data.

# COMMAND ----------

# DBTITLE 1,Define parameters_list
# MAGIC %r
# MAGIC parameters_list <- list(
# MAGIC   list(name = 'catalog', default = ''),
# MAGIC   list(name = 'owner_group', default = '')
# MAGIC )

# COMMAND ----------

# DBTITLE 1,Create the workflow
# MAGIC %md
# MAGIC
# MAGIC ## Create a job
# MAGIC
# MAGIC Now we have both of our tasks defined we can create the job using the `databricks::jobCreate()` function. We pass it the `client` as the first argument, then the job `name` we defined. The `tasks` are passed as a list which contains each of the task lists we built above.
# MAGIC We'll also tell it to send us `email_notifications` by passing a list with an `on_success` value of email addresses. As our `user_name` variable defined above is the same as our email address we can re-use this variable here.
# MAGIC
# MAGIC The `jobsCreate()` function returns the ID of the job we just created, so we will want to store the response in a variable called `job` so we can refer to it later.

# COMMAND ----------

# DBTITLE 1,jobsCreate call
# MAGIC %r
# MAGIC   job <- jobsCreate(client,
# MAGIC       name = job_name,
# MAGIC       git_source = git_source_list,#defined above
# MAGIC       tasks = list(
# MAGIC                   create_schema_task, #defined above
# MAGIC                   create_table_task, #defined above
# MAGIC                   insert_data_task, #defined above
# MAGIC                   select_from_table_task), #defined above
# MAGIC       parameters = parameters_list, #defined above
# MAGIC       email_notifications = list(
# MAGIC                               on_success = c(user_name)
# MAGIC                               )
# MAGIC )
# MAGIC
# MAGIC job

# COMMAND ----------

# DBTITLE 1,Lists of lists note
# MAGIC %md
# MAGIC
# MAGIC
# MAGIC > ### _Lists of lists_
# MAGIC >
# MAGIC > _A `list()` in R is used to contain any number and type of data, including other `list()`s. This makes it excellent for storing hierarchical data in one place, however it can get quite confusing quite quickly._
# MAGIC >
# MAGIC > _Sometimes it's easier to break these `lists()` up into pieces by defining them seperately, as we did above by defining the task lists separately then passing them to the `tasks` argument in the `jobsCreate()` function._
# MAGIC >
# MAGIC > _This often makes it easier to think about and construct, but certainly makes it easier to read. Consider the code below which does exactly the same thing as the code above, but is just written all at once. It's much harder to tell what's going on when trying to absorb all that information at once._

# COMMAND ----------

# DBTITLE 1,Inline jobsCreate example
# MAGIC %md
# MAGIC     job <- jobsCreate(client,
# MAGIC     name = job_name,
# MAGIC     git_source = list(
# MAGIC         git_url = "https://github.com/dfe-analytical-services/databricks_code_learn",
# MAGIC         git_provider = "gitHub",
# MAGIC         git_branch = "main"
# MAGIC       ),
# MAGIC     tasks = list(
# MAGIC               list(
# MAGIC                   task_key = create_schema_key,
# MAGIC                   existing_cluster_id = cluster_id,
# MAGIC                   notebook_task = list(
# MAGIC                     notebook_path = create_schema_path,
# MAGIC                     source = "GIT"
# MAGIC                   )
# MAGIC                 ), #create_schema
# MAGIC                 list(
# MAGIC                   task_key = create_table_key,
# MAGIC                   existing_cluster_id = cluster_id,
# MAGIC                   notebook_task = list(
# MAGIC                                     notebook_path = create_table_path,
# MAGIC                                     source = "GIT"
# MAGIC                                   ),
# MAGIC                   depends_on = list(task_key = create_schema_key),
# MAGIC                   run_if = "ALL_SUCCESS"
# MAGIC                 ), #create_table
# MAGIC                 list(
# MAGIC                   task_key = insert_data_key,
# MAGIC                   existing_cluster_id = cluster_id,
# MAGIC                   notebook_task = list(
# MAGIC                                     notebook_path = insert_data_path,
# MAGIC                                     source = "GIT"
# MAGIC                                   ),
# MAGIC                   depends_on = list(task_key = create_table_key),
# MAGIC                   run_if = "ALL_SUCCESS"
# MAGIC                 ), #insert_data
# MAGIC                 list(
# MAGIC                   task_key = select_from_table_key,
# MAGIC                   existing_cluster_id = cluster_id,
# MAGIC                   notebook_task = list(
# MAGIC                                     notebook_path = select_from_table_path,
# MAGIC                                     source = "GIT"
# MAGIC                                   ),
# MAGIC                   depends_on = list(task_key = insert_data_key),
# MAGIC                   run_if = "ALL_SUCCESS"
# MAGIC                 )
# MAGIC               ), #select_from_table
# MAGIC     parameters = list(
# MAGIC                   list(name = 'catalog', default = ''),
# MAGIC                   list(name = 'owner_group', default = '')
# MAGIC                 ),
# MAGIC     email_notifications = list(
# MAGIC                             on_success = c(user_name)
# MAGIC                             )
# MAGIC     )

# COMMAND ----------

# DBTITLE 1,Code complexity note
# MAGIC %md
# MAGIC > _We can see here that the code is getting very long, and is also more difficult to see which options relate to which list. If it weren't for being diligent with indentation here we'd have to resort to counting brackets to see what belonged where. This is especially problematic if you accidentally delete a bracket and need to work out where it was meant to go._

# COMMAND ----------

# DBTITLE 1,Run the workflow
# MAGIC %md
# MAGIC
# MAGIC ## Run the job through code
# MAGIC
# MAGIC We can now get the ID of the job that was created and tell the API to run the job. In a new code chunk we'll store the `job_id` from the `job` variable above. We'll then use the `databricks::jobsRunNow()` function to tell it to run the job we just created by passing it the `job_id` we just stored. 
# MAGIC
# MAGIC A job may be run many times and each of these runs is given an ID. To target a specific run of a job in code we'll need to store the `job_run_id` returned by the `databricks::jobsRunNow()` function.

# COMMAND ----------

# DBTITLE 1,Run job
# MAGIC %r
# MAGIC job_id <- job$job_id
# MAGIC
# MAGIC job_run <- jobsRunNow(client, 
# MAGIC                       job_id = job_id)
# MAGIC
# MAGIC job_run_id <- job_run$run_id
# MAGIC job_run_id

# COMMAND ----------

# DBTITLE 1,Create job link
# MAGIC %md
# MAGIC
# MAGIC ## Create a link for the job run
# MAGIC
# MAGIC We will now use this to create links to the job and the specific run of the job we just set off.
# MAGIC
# MAGIC In a new code cell, define a `job_link` by `paste0()`ing the `host` variable we passed to the `databricks::DatabricksClient()` function earlier, followed by `"job/"` followed by the `job_id` defined above.
# MAGIC We can then create a `job_run_link` by `paste0()`ing together the `job_link` followed by `"/runs/"` then the `job_run_id` from the previous step.
# MAGIC We can then output the `job_link` as text at the bottom of the cell.

# COMMAND ----------

# DBTITLE 1,Output job run link
# MAGIC %r
# MAGIC job_link <- paste0(host,"jobs/",job_id)
# MAGIC job_run_link <- paste0(job_link,"/runs/", job_run_id)
# MAGIC job_run_link

# COMMAND ----------

# DBTITLE 1,Check the link
# MAGIC %md
# MAGIC Now use the link above and check that it links to a job run before returning to the tutorial.
# MAGIC
# MAGIC Once you've clicked the link you should see a graph, but the job will have failed. The reason it failed is because we forgot to pass any parameters to the it, and since we left the default values of the parameters blank the first code chunk that referred to them threw an error. 
# MAGIC
# MAGIC This is what we wanted because not only did it prevent any accidental changes being made it also failed immediately allowing us to investigate the cause. This is preferable to accidentally making changes we didn't want but looking like a successful run, which could mean we don't even notice anything has gone wrong until later in the day when we're trying to access data we just overwrote.

# COMMAND ----------

# DBTITLE 1,Running with parameters
# MAGIC %md
# MAGIC
# MAGIC ## Running with parameters
# MAGIC
# MAGIC Now let's run the job with parameters and (hopefully) get a successful run out of it.
# MAGIC
# MAGIC We'll now take the values of the `catalog` and `owner_group` from the widgets we created earlier and pass them as parameters to the `databricks::jobsRunNow()` function.
# MAGIC
# MAGIC Here the argument for passing parameters is `job_parameters`, and the list is in the structure of a single list with each item being `parameter_name = 'parameter value'`. 

# COMMAND ----------

# DBTITLE 1,Run with parameters
# MAGIC %r
# MAGIC catalog <- dbutils.widgets.get("catalog")
# MAGIC owner_group <- dbutils.widgets.get("owner_group")
# MAGIC
# MAGIC job_run <- jobsRunNow(client, 
# MAGIC                       job_id = job_id,
# MAGIC                       job_parameters = list(
# MAGIC                           catalog = catalog,
# MAGIC                           owner_group = owner_group
# MAGIC                         ))
# MAGIC
# MAGIC job_run_id <- job_run$run_id
# MAGIC job_run_id

# COMMAND ----------

# DBTITLE 1,Output run link
# MAGIC %md
# MAGIC We'll now output another link and check how successful the run of the job was.

# COMMAND ----------

# DBTITLE 1,Second job run link
# MAGIC %r
# MAGIC job_link <- paste0(host,"jobs/",job_id)
# MAGIC job_run_link <- paste0(job_link,"/runs/", job_run_id)
# MAGIC job_run_link

# COMMAND ----------

# DBTITLE 1,Verify results
# MAGIC %md
# MAGIC All being well you should now see a graph of tasks turning green in sequence. Once the final task has completed check your modelling area catalog and you should see a schema called `shared`, containing a table called `shared_table_runs`.
# MAGIC
# MAGIC Within that table there should be one or more rows depending on how many times this job has been run in your modelling area.

# COMMAND ----------

# DBTITLE 1,Cleaning up
# MAGIC %md
# MAGIC ## Cleaning up
# MAGIC
# MAGIC You've now created a jobs with code, and each time you re-run this notebook another job with the same name will be created. As this is a tutorial which most analysts may have to follow at some point, there's a reasonable chance that we could end up with several 'test jobs' cluttering up the job page.
# MAGIC
# MAGIC To avoid that we could use the `databricks::jobsDelete()` function (as below) to clean up after ourselves. All that we need to do is pass the function the `client`, and `job_id` variables from above.
# MAGIC
# MAGIC However, let's look at another way to do it.

# COMMAND ----------

# DBTITLE 1,Delete single job (commented)
# MAGIC %r
# MAGIC #jobsDelete(client, job_id)

# COMMAND ----------

# DBTITLE 1,Bulk Clean up
# MAGIC %md
# MAGIC ## Bulk Clean up
# MAGIC  
# MAGIC If you have been running and re-running bits of this code iteratively, there's a good chance you already have several instances of 'test job' listed under your name.
# MAGIC
# MAGIC If this is the case we'll want to clean up each of these, ideally without having to manually click through the UI process for each one.
# MAGIC
# MAGIC To do this, firstly call the `databricks::jobsList()` function, passing it the `client` variable, and specifying the `name` of the jobs you want to list. Then filter the list to just the jobs with a `creator_user_name` of your email address (which is still stored in the `user_name` variable defined above). 
# MAGIC
# MAGIC > Note: It's highly unlikely that you would get any jobs that weren't yours due to the default Databricks permissions model, but there is the possibility that people may have shared access to their jobs with you, so to guard against accidentally interfering with someone else's work it doesn't hurt to put an explicit safeguard in.

# COMMAND ----------

# DBTITLE 1,List test jobs
# MAGIC %r
# MAGIC my_jobs <- jobsList(client, name = "test job") 
# MAGIC
# MAGIC display(my_jobs %>% select(job_id, creator_user_name, run_as_user_name, created_time))

# COMMAND ----------

# DBTITLE 1,Loop deletion explanation
# MAGIC %md
# MAGIC We can now loop through the individual `job_id`s contained in `my_jobs` and use the `databricks::jobsDelete()` function to remove them all at once, programmatically.
# MAGIC
# MAGIC If you do only have one instance of 'test job' this loop will only run once, and will have the same effect as just deleting the job as above, but if you have multiple occurances this loop will run as many times as needed until all of the 'test jobs' under your name have been removed.

# COMMAND ----------

# DBTITLE 1,Delete all test jobs
# MAGIC %r
# MAGIC for(job_id in my_jobs$job_id){
# MAGIC       jobsDelete(client, job_id)
# MAGIC }

# COMMAND ----------

with open("Quiz 02 Using Jobs & Pipelines - Databricks API.html", "r", encoding="utf-8") as f:
    html_content = f.read()
    displayHTML(html_content)

# COMMAND ----------

# MAGIC %md
# MAGIC ✅ Task: Create a set of notebooks
# MAGIC 1. Create 2 or more notebooks.
# MAGIC 2. Check that they run.
# MAGIC
# MAGIC ✅ Task: Create a job with code
# MAGIC 1. Using code (the `databricks` R package), create a new job from the above notebooks.
# MAGIC 2. Have them dependent on each other.
# MAGIC 3. Add a parameter and schedule them to run at a specific time.