##################################################
#
# Global Stimulus Functions 
#
##################################################


####################
# Seed Stimuls
####################
seedStimuls <- function(InitialSVector, RateVector, gens) {
  # Calculate number of blank spots to make
  repLength <- (length(InitialSVector) + length(RateVector)) * gens #intiial row does not count as gen
  # Build matrix
  stim <- matrix(data = c(InitialSVector, RateVector, rep(NA, repLength)),
                 byrow = TRUE, 
                 nrow = (gens + 1))
  # Fix Names
  colnames(stim) <- c(paste0(rep("s", length(InitialSVector)), 1:length(InitialSVector)),
                      paste0(rep("delta", length(RateVector)), 1:length(InitialSVector)))
  rownames(stim) <- paste0("Gen", 0:gens)
  # Return
  return(stim)
}

####################
# Stimulus Level
####################
# Frequency dependent
globalStimUpdate <- function(stimulus, delta, alpha, Ni, n) {
  # Calculate
  s <- stimulus + delta - ( alpha * ( Ni / n ))
  # If negative, make zero
  if(s < 0.0001) {
    s <- 0
  }
  return(s)
}

# Density dependent (per capita)
globalStimUpdate_PerCap <- function(stimulus, delta, alpha, Ni, n, m) {
  # Calculate
  s <- stimulus + (alpha * (delta ) * (n / m)) - (Ni * alpha)
  # s <- stimulus + (alpha * (delta ) * (1 / (1 + quitP)) * (n / m)) - (Ni * alpha)
  # If negative, make zero
  if(s < 0.0001) {
    s <- 0
  }
  return(s)
}

####################
# Update Exhuastion
####################
updateExhaustStim <- function(ExhaustStim, TaskExhaustVect, ExhaustRate, StateMat) {
  # Zero out stim for those that are inactive
  for (i in 1:nrow(StateMat)) {
    if (sum(StateMat[i, ]) == 0) {
      ExhaustStim[i] <- 0
    }
  }
  # Get relative rate increase for task being performed
  TaskRate <- StateMat %*% TaskExhaustVect
  # Get rate increase for time step
  StimIncrease <- TaskRate %*% ExhaustRate
  # Update Stim
  NewExhaust <- ExhaustStim + StimIncrease
  # Return 
  return(NewExhaust)
}