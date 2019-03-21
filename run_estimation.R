#transdimensional mcmc for estimating glm AND temp suitability

run_estimation = function(run_id){
  #########################################################################################################
  ### LIBRARIES FOR PACKAGES USED ###
  #########################################################################################################
  
  library(dplyr)
  library(readr)
  library(reshape)
  library(mvtnorm)
  library(truncdist)
  library(R.utils)
  
  library(YFestimation)
  library(KsetupR)
  
  #########################################################################################################
  ### LOADING COUNTRIES ###
  #########################################################################################################
  
  Countries = read_csv(paste0("../Data/","Countries.csv"))
  c34 = Countries$c34
  
  #########################################################################################################
  ### SOURCE FUNCTIONS ###
  #########################################################################################################
  
  sourceDirectory("FUNCTIONS", modifiedOnly = FALSE)
  
  #########################################################################################################
  ### LOAD ENVIRONMENTAL DATA ###
  #########################################################################################################
  
  Env_Table_path = (paste0("../Data/","Environment/dat_with_worldclim/dat_worldclim_baseline_2019-03-15.csv")) 
  
  dat_full = read.csv(Env_Table_path, 
                      stringsAsFactors = FALSE)
  
  temp_type = "worldclim_temp_min"
  
  #########################################################################################################
  ### LOAD TEMPSUIT DATA ###
  #########################################################################################################
  ### a
  mordecai_biterate <- read_csv("Data/mordecai_biterate.csv")
  hamlet_biterate = read_csv("Data/hamlet_biterate.csv")
  mordecai_biterate$author = "mordecai"
  hamlet_biterate$author = "hamlet"
  names(hamlet_biterate) = names(mordecai_biterate)
  
  dat_bite = rbind(mordecai_biterate, hamlet_biterate)
  
  ### mu
  dat_mort <- read_csv("Data/Survival_mortality/SurvivalData_mordecai2018.csv")
  dat_mort = filter(dat_mort, `Time (dpi)`>0)
  
  ### PDR
  dat_EIP <- read_csv("Data/davis_EIP.csv")
  
  ########################################################################################################
  ### CREATE STATUS ###
  #########################################################################################################
  
  #first reset seed for generating the pseudo random start conditions
  index_code = as.numeric(commandArgs(TRUE))
  if(identical(index_code, numeric(0))) index_code=1
  
  t= as.numeric(Sys.time())
  seed= (t - floor(t)) * 1e8 
  set.seed(seed)
  
  
  #### INITIAL PARAM ####
  
  ### OR LOAD FROM PREVIOUS RUN ###
  file_name = "Z:/YF_climateChange/GLM_tempsuit_parameter_estimates_20190318 .csv"#get_latest_file(pattern = "GLM_tempsuit_parameter_estimates")
  prev_param = read.csv(file_name)
  
  pars_ini = c(prev_param$median)
  names(pars_ini) = prev_param$Parameter
  
  
  #########################################################################################################
  ### MCMC ###
  #########################################################################################################
  #create a directory to save the output in
  date=format(Sys.time(),"%Y%m%d")
  name_dir = paste0("GLM_tempsuit_MCMC_chain", "_", date, "_hamlet", "_cluster")
  dir.create(name_dir)
  
  Niter = 500000
  
  
  GLM_tempsuit_MCMC(Niter, name_dir, pars_ini, dat_full, temp_type, dat_bite, dat_mort, dat_EIP, c34, run_id, plot_chain = FALSE)
  
}