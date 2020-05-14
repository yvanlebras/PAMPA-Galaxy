#Rscript 

#####################################################################################################################
#####################################################################################################################
############################ Calculate presence absence table from observation data #################################
#####################################################################################################################
#####################################################################################################################

###################### Packages
suppressMessages(library(tidyr))

###################### Load arguments and declaring variables

args = commandArgs(trailingOnly=TRUE)
#options(encoding = "UTF-8")

if (length(args) < 3) {
    stop("At least one argument must be supplied, an input dataset file (.tabular).", call.=FALSE) #si pas d'arguments -> affiche erreur et quitte / if no args -> error and exit1

} else {
    Importdata<-args[1] ###### Nom du fichier importé avec son extension / file name imported with the file type ".filetype"  
    source(args[2]) ###### Import functions

}
#### Data must be a dataframe with at least 3 variables : unitobs representing location and year ("observation.unit"), species code ("species.code") and abundance ("number")


#Import des données / Import data 
obs<- read.table(Importdata,sep="\t",dec=".",header=TRUE,encoding="UTF-8") #
obs[obs == -999] <- NA 
factors <- fact.det.f(Obs=obs)
ObsType <- def.typeobs.f(Obs=obs)
create.unitobs(data=obs)

vars_data<-c("observation.unit","species.code","number")
err_msg_data<-"The input dataset doesn't have the right format. It need to have at least the following 3 variables :\n- observation.unit\n- species.code\n- number\n"
check_file(obs,err_msg_data,vars_data,3)


####################################################################################################
#################### Create presence/absence table ## Function : calc.presAbs.f ####################
####################################################################################################

calc.presAbs.f <- function(Data,
                           nbName="number")
{
    ## Purpose: Calcul des présences/absences à partir des abondances.
    ## ----------------------------------------------------------------------
    ## Arguments: Data : la table de métrique (temporaire).
    ##            nbName : nom de la colonne nombre.
    ##
    ## Output: vecteur des présences/absences (0 ou 1).
    ## ----------------------------------------------------------------------
    ## Author: Yves Reecht, Date: 20 déc. 2011, 12:04

    ## Presence - absence :
    presAbs <- integer(nrow(Data))
    presAbs[Data[ , nbName] > 0] <- as.integer(1) # pour avoir la richesse spécifique en 'integer'.1
    presAbs[Data[ , nbName] == 0] <- as.integer(0) # pour avoir la richesse spécifique en 'integer'.0

    return(presAbs)
}


####################################################################################################
################## create community metrics table ## Function : calcBiodiv.f #######################
####################################################################################################


################# Analysis

res <- calc.numbers.f(obs, ObsType=ObsType , factors=factors, nbName="number")
res$pres.abs <- calc.presAbs.f(res, nbName="number")


#Save dataframe in a tabular format
filenamePresAbs <- "TabPresAbs.tabular"
write.table(res, filenamePresAbs, row.names=FALSE, sep="\t", dec=".",fileEncoding="UTF-8")
cat(paste("\nWrite table with presence/absence. \n--> \"",filenamePresAbs,"\"\n",sep=""))

