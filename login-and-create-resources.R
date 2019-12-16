# It is recommended that a service principal be created and setup
tenant <- "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" # Azure Tenant ID
subscription <- "ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj" # Azure Subscription ID
sp_app_id <- "kkkkkkkk-llll-mmmm-nnnn-oooooooooooo" # Service Principal ID
cert_path <- "mycert.pem" # Location of certificate

# Load libraries
library(AzureCognitive)
library(AzureRMR)

# Create the Azure Login object using the Service Principal and cert
az <- create_azure_login(
  tenant = tenant,
  app = sp_app_id,
  certificate = cert_path, 
  auth_type="client_credentials"
  )

# Select the subscription
sub <- az$get_subscription(subscription)

# Create a name for the new resource group
rg_name <- "rg-created-with-azurermr"

# create new resource group
sub$create_resource_group(name = rg_name, location = "eastus2")
rg <- sub$get_resource_group(rg_name)

# create a new Text Analytics service 
rg$create_cognitive_service("mv-services-created-from-r",
                            service_type = "CognitiveServices",
                            service_tier = "S0",
                            location = "eastus2")

# retrieve the Cog Service
cogsvc <- rg$get_cognitive_service("mv-services-created-from-r")

# Get the Cog Service keys
key <- cogsvc$list_keys()[[1]]
point()

# Create the endpoint object
text_api_endpoint <- cognitive_endpoint("https://mv-services-created-from-r.cognitiveservices.azure.com",
                         service_type = "Text",
                         key = key)

# Save the endpoint object to disk, you will need this later
saveRDS(text_api_endpoint, "text-api-endpoint.rds")
