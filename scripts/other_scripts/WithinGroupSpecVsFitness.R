################################################################################
#
# Check within group size specialization vs stim fluctuation
#
################################################################################

rm(list = ls())
source("scripts/__Util__MASTER.R")
source("scripts/3_PrepPlotExperimentData.R")

load("output/__RData/MSrevision_FixedDelta06Sigma01Eta7100reps.Rdata")

# Set variable  
filename <- "Fixed_Delta06Sigma01Eta7"

# Palette without single individuals
#palette <- c("#F00924", "#F7A329", "#FDD545", "#027C2C", "#1D10F9", "#4C0E78", "#bdbdbd", "#525252")

# Palette without single individuals
palette <- c("#F00924", "#F7A329", "#FDD545", "#027C2C", "#1D10F9", "#4C0E78", "#bdbdbd", "#525252")


####################
# Task Rank Correlation
####################
# Unlist
taskCorrTot <- do.call("rbind", groups_taskCorr)
taskCorrTot <- taskCorrTot %>% 
  mutate(TaskMean = (Task1 + Task2) / 2)

# Manipulate and bind with Yuko data
taskCorrTot <- taskCorrTot %>% 
  mutate(Set = paste0(n, "-", replicate)) %>% 
  select(n, TaskMean, Set) 

####################
# Stimulus Fluctuation
####################
# Unlist
stims <- unlist(groups_stim, recursive = FALSE)
stims <- do.call("rbind", stims)

#### 200 Time steps ####
# Normalize and Summarise by "day" (i.e., time window) and calculate difference
stimFluct <- stims %>%
  select(-delta1, -delta2) %>%
  mutate(Set = paste0(n, "-", replicate)) %>%
  group_by(Set) %>%
  mutate(t = 0:(length(Set)-1)) %>%
  mutate(Window = t %/% 200) %>%
  filter(t != 0) %>%
  group_by(n, Set, Window) %>%
  summarise(s1 = mean(s1),
            s2 = mean(s2)) %>%
  mutate(s1Diff = abs(s1 - lag(s1)),
         s2Diff = abs(s2 - lag(s2)),
         BeginSet = !duplicated(Set))
#### 1 Time steps ####
# stimFluct <- stims %>% 
#   select(-delta1, -delta2) %>% 
#   mutate(Set = paste0(n, "-", replicate)) %>% 
#   group_by(Set) %>% 
#   mutate(t = 0:(length(Set)-1)) %>% 
#   mutate(Window = t %/% 1) %>% 
#   filter(t != 0) %>% 
#   group_by(n, Set, Window) %>% 
#   summarise(s1 = mean(s1),
#             s2 = mean(s2)) %>% 
#   mutate(s1Diff = abs(s1 - lag(s1)),
#          s2Diff = abs(s2 - lag(s2)),
#          BeginSet = !duplicated(Set)) 

# Make sure first diff row of each new set is NA
sets <- which(stimFluct$BeginSet == TRUE)
stimFluct$s1Diff[sets] <- NA
stimFluct$s2Diff[sets] <- NA

# Summarise by colony/set
stimFluct <- stimFluct %>% 
  group_by(n, Set) %>% 
  summarise(s1Fluct = mean(s1Diff, na.rm = TRUE),
            s2Fluct = mean(s2Diff, na.rm = TRUE)) %>% 
  mutate(GroupSizeFactor = factor(n, levels = sort(unique(n))),
         stimFluct = (s1Fluct + s2Fluct) / 2)

####################
# Task Performance Fluctuation
####################
# Unlist
tallies <- unlist(groups_taskTally, recursive = FALSE)
tallies <- do.call("rbind", tallies)

#### 200 Time steps ####
# Normalize and Summarise by "day" (i.e., time window) and calculate difference
# tallyFluct <- tallies %>%
#   mutate(Task1 = Task1 / n,
#          Task2 = Task2 / n,
#          Inactive = Inactive / n,
#          Set = paste0(n, "-", replicate),
#          Window = t %/% 200) %>%
#   group_by(n, Set, Window) %>%
#   summarise(Task1 = mean(Task1),
#             Task2 = mean(Task2),
#             Inactive = mean(Inactive)) %>%
#   mutate(Task1Diff = abs(Task1 - lag(Task1)),
#          Task2Diff = abs(Task2 - lag(Task2)),
#          InactiveDiff = abs(Inactive - lag(Inactive)),
#          BeginSet = !duplicated(Set))

#### 1 Time steps ####
# Normalize and Summarise by "day" (i.e., time window) and calculate difference
tallyFluct <- tallies %>%
  mutate(Task1 = Task1 / n,
         Task2 = Task2 / n,
         Inactive = Inactive / n,
         Set = paste0(n, "-", replicate),
         Window = t %/% 200) %>%
  group_by(n, Set, Window) %>%
  summarise(Task1 = mean(Task1),
            Task2 = mean(Task2),
            Inactive = mean(Inactive)) %>%
  mutate(Task1Diff = abs(Task1 - lag(Task1)),
         Task2Diff = abs(Task2 - lag(Task2)),
         InactiveDiff = abs(Inactive - lag(Inactive)),
         BeginSet = !duplicated(Set))

# Make sure first diff row of each new set is NA
sets <- which(tallyFluct$BeginSet == TRUE)
tallyFluct$Task1Diff[sets] <- NA
tallyFluct$Task2Diff[sets] <- NA
tallyFluct$InactiveDiff[sets] <- NA

# Summarise by colony/set
tallyFluct <- tallyFluct %>% 
  group_by(n, Set) %>% 
  summarise(Task1Fluct = mean(Task1Diff, na.rm = TRUE),
            Task2Fluct = mean(Task2Diff, na.rm = TRUE),
            InactiveFluct = mean(InactiveDiff, na.rm = TRUE)) %>% 
  mutate(GroupSizeFactor = factor(n, levels = sort(unique(n))),
         taskFluct = (Task1Fluct + Task2Fluct) / 2)



####################
# Merge and plot
####################
# Merge
merged_specstim <- merge(taskCorrTot, stimFluct, by = c("Set", "n"))
merged_specstim <- merge(merged_specstim, tallyFluct, by = c("Set", "n"))

# Plot - Stimulus vs Specialization total
gg_compareTot <- gg_compare <- ggplot(merged_specstim, aes(x = TaskMean, y = s1Fluct, colour = as.factor(n))) +
  geom_point() +
  theme_classic() +
  scale_color_manual(values = palette, name = "Group Size") +
  xlab("Task Correlation") +
  ylab("Stim 1 Fluctuations")
gg_compareTot

# Plot - Stimulus vs Specialization by Group Size
gg_compare <- ggplot(merged_specstim, aes(x = TaskMean, y = s1Fluct, colour = as.factor(n))) +
  geom_point() +
  theme_classic() +
  scale_color_manual(values = palette) +
  theme(legend.position = "none") +
  facet_wrap(~ n, scales = "free") +
  xlab("Task Correlation") +
  ylab("Stim 1 Fluctuations")
gg_compare


# Plot - Stimulus vs Task Fluctuations total
gg_compareTot <- gg_compare <- ggplot(merged_specstim, aes(y = Task1Fluct, x = s1Fluct, colour = as.factor(n))) +
  geom_point() +
  theme_classic() +
  scale_color_manual(values = palette, name = "Group Size") +
  xlab("Stim 1 Fluctuations") +
  ylab("Task 1 Fluctuations")
gg_compareTot

# Plot - Stimulus vs Task Fluctuations by group size
gg_compare <- gg_compare <- ggplot(merged_specstim, aes(y = Task1Fluct, x = TaskMean, colour = as.factor(n))) +
  geom_point() +
  theme_classic() +
  scale_color_manual(values = palette, name = "Group Size") +
  facet_wrap(~ n, scales = "free") +
  xlab("Stim 1 Fluctuations") +
  ylab("Task 1 Fluctuations")
gg_compare



####################
# Check correlation by time step
####################
window_sizes <- c(1, 5, 10, 15, 20, 30, 50, 100)

correlations <- lapply(window_sizes, function(window_size) {
  # Calculate tally fluctuations
  # Normalize and Summarise by "day" (i.e., time window) and calculate difference
  tallyFluct <- tallies %>%
    mutate(Task1 = Task1 / n,
           Task2 = Task2 / n,
           Inactive = Inactive / n,
           Set = paste0(n, "-", replicate),
           Window = t %/% window_size) %>%
    group_by(n, Set, Window) %>%
    summarise(Task1 = mean(Task1),
              Task2 = mean(Task2),
              Inactive = mean(Inactive)) %>%
    mutate(Task1Diff = abs(Task1 - lag(Task1)),
           Task2Diff = abs(Task2 - lag(Task2)),
           InactiveDiff = abs(Inactive - lag(Inactive)),
           BeginSet = !duplicated(Set))
  
  # Make sure first diff row of each new set is NA
  sets <- which(tallyFluct$BeginSet == TRUE)
  tallyFluct$Task1Diff[sets] <- NA
  tallyFluct$Task2Diff[sets] <- NA
  tallyFluct$InactiveDiff[sets] <- NA
  
  # Summarise by colony/set
  tallyFluct <- tallyFluct %>% 
    group_by(n, Set) %>% 
    summarise(Task1Fluct = mean(Task1Diff, na.rm = TRUE),
              Task2Fluct = mean(Task2Diff, na.rm = TRUE),
              InactiveFluct = mean(InactiveDiff, na.rm = TRUE)) %>% 
    mutate(GroupSizeFactor = factor(n, levels = sort(unique(n))),
           taskFluct = (Task1Fluct + Task2Fluct) / 2)
  
  # Calculate stim fluctuations
  # Normalize and Summarise by "day" (i.e., time window) and calculate difference
  stimFluct <- stims %>%
    select(-delta1, -delta2) %>%
    mutate(Set = paste0(n, "-", replicate)) %>%
    group_by(Set) %>%
    mutate(t = 0:(length(Set)-1)) %>%
    mutate(Window = t %/% window_size) %>%
    filter(t != 0) %>%
    group_by(n, Set, Window) %>%
    summarise(s1 = mean(s1),
              s2 = mean(s2)) %>%
    mutate(s1Diff = abs(s1 - lag(s1)),
           s2Diff = abs(s2 - lag(s2)),
           BeginSet = !duplicated(Set))
  
  # Make sure first diff row of each new set is NA
  sets <- which(stimFluct$BeginSet == TRUE)
  stimFluct$s1Diff[sets] <- NA
  stimFluct$s2Diff[sets] <- NA
  
  # Summarise by colony/set
  stimFluct <- stimFluct %>% 
    group_by(n, Set) %>% 
    summarise(s1Fluct = mean(s1Diff, na.rm = TRUE),
              s2Fluct = mean(s2Diff, na.rm = TRUE)) %>% 
    mutate(GroupSizeFactor = factor(n, levels = sort(unique(n))),
           stimFluct = (s1Fluct + s2Fluct) / 2)
  
  # Merge
  merged_specstim <- merge(taskCorrTot, stimFluct, by = c("Set", "n"))
  merged_specstim <- merge(merged_specstim, tallyFluct, by = c("Set", "n"))
  
  # Calculate correlations
  sizes <- lapply(c(2, 4, 6, 8, 12, 16), function(n) {
    # Filter
    temp_df <- merged_specstim[merged_specstim$n == n, ]
    # Calculate correlation
    stimCorr <- summary(lm(s1Fluct ~ TaskMean, data = temp_df))
    taskCorr <- summary(lm(Task1Fluct ~ TaskMean, data = temp_df))
    # dataframe to return
    sizesDF <- data.frame(Window = window_size, 
                          n = n,  
                          TaskInt = taskCorr$coefficients[2],
                          TaskP = taskCorr$coefficients[8],
                          stimInt = stimCorr$coefficients[2],
                          stimP = stimCorr$coefficients[8])
    return(sizesDF)
  })
  # dataframe to return
  correlationDF <- do.call("rbind", sizes)
})

# Bind
correlations <- do.call("rbind", correlations)
correlations <- correlations %>% 
  mutate(TaskSig = TaskP <= 0.05,
         StimSig = stimP <= 0.05)


gg_corrBySize <- ggplot(data = correlations, aes(x = Window)) +
  # geom_point(aes(y = TaskP), color = "blue") +
  # geom_line(aes(y = TaskP), color = "blue") +
  geom_point(aes(y = stimP), color = "red") +
  geom_line(aes(y = stimP), color = "red") +
  theme_classic() +
  geom_hline(yintercept = 0.05, type = "dashed") + 
  scale_y_continuous(limits = c(0, 0.5)) +
  facet_wrap(~n) +
  ylab("P value of correlation") +
  xlab("Window Size")

gg_corrBySize
