# Bicep-with-AzureDevOps
Here you'll find a template creation with Azure Bicep along with AzureDevOps pipelines with YAML

On the first folder: template_provisioning you'll find a template where i defined all the resources that should be created for the provisioning, they're:

*   4 App Services
    3 App services Plan
    1 Serverless Function App
    1 SQL Server (It would be created depending if the servers already exists or not)
    2 DATABASES
    1 Api Management
    3 Storages

On the second folder: yaml_automatization you'll see a pipeline with various task using Bash, Powershell etc, where i automate some tasks that are neccesary for the singletenant to work, some of them are:

*   Provisioning of the template along with the JSON file
    Networking rules for the DATABASES
    Database user creation
    Extracting existing schema from a database to the new databases that is being created
    Exporting and Importing all apis from an existing api management to the one that is being created
    Settings and connection string that werent set through bicep are done in a AzureCLI task

