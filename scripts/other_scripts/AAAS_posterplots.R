################################################################################
#
# Fitness Plots
#
################################################################################

rm(list = ls())
source("scripts/__Util__MASTER.R")
source("scripts/3_PrepPlotExperimentData.R")
library(RColorBrewer)
library(scales)

load("output/__RData/FixedDelta06Sigma01Eta7100reps.Rdata")


####################
# Task Negelect
####################
# Across roup size plot
noTaskPerf <- lapply(groups_taskTally, function(group_size) {
  # Loop through replicates within group size
  within_groupTaskPerf <- lapply(group_size, function(replicate) {
    # Get basics and counts of instances in which there isn't anyone performing task
    to_return <- data.frame(n = unique(replicate$n), 
                            replicate = unique(replicate$replicate),
                            Set = paste0(unique(replicate$n), "-", unique(replicate$replicate)),
                            noTask1 = sum(replicate$Task1 == 0),
                            noTask2 = sum(replicate$Task2 == 0))
    #  Quantify length of no-performance bouts
    for (task in c("Task1", "Task2")) {
      bout_lengths <- rle(replicate[ , task])
      bout_lengths <- as.data.frame(do.call("cbind", bout_lengths))
      bout_lengths <- bout_lengths %>% 
        filter(values == 0)
      avg_nonPerformance <- mean(bout_lengths$lengths)
      if(task == "Task1") {
        to_return$noTask1Length = avg_nonPerformance
      } 
      else {
        to_return$noTask2Length = avg_nonPerformance
      }
    }
    # Get averages
    to_return <- to_return %>% 
      mutate(noTaskAvg = (noTask1 + noTask2) / 2,
             noTaskLengthAvg = (noTask1Length + noTask2Length) / 2)
    # Return
    return(to_return)
  })
  # Bind and return
  within_groupTaskPerf <- do.call("rbind", within_groupTaskPerf)
  return(within_groupTaskPerf)
})
# Bind
noTaskPerf <- do.call("rbind", noTaskPerf)


# Summarise
noTaskPerf <- noTaskPerf %>% 
  group_by(n) %>% 
  mutate(noTask1 = noTask1 / 10000,
         noTask2 = noTask2 / 10000,
         noTaskAvg = noTaskAvg / 10000)

neglectSum <- noTaskPerf %>% 
  summarise(Task1NegelectMean = mean(noTask1, na.rm = TRUE),
            Task1NegelectSE = ( sd(noTask1) / sqrt(length(noTask1)) ),
            Task2NegelectMean = mean(noTask2, na.rm = TRUE),
            Task2NegelectSE = ( sd(noTask2) / sqrt(length(noTask2)) ),
            TaskNegelectMean = mean(noTaskAvg, na.rm = TRUE),
            TaskNegelectSE = ( sd(noTaskAvg) / sqrt(length(noTaskAvg)) ))

# Plot
gg_noTask <- ggplot() +
  geom_point(data = noTaskPerf, 
             aes(x = n, y = noTaskAvg),
             fill = "grey50", 
             colour = "grey50", 
             position = position_jitter(width = 0.1),
             size = 0.7, 
             alpha = 0.4,
             stroke = 0) +
  geom_errorbar(data = neglectSum,
                aes(x = n, 
                    ymin = TaskNegelectMean - TaskNegelectSE, 
                    ymax = TaskNegelectMean + TaskNegelectSE),
                colour = "black",
                size = 0.25) +
  geom_point(data = neglectSum,
             aes(x = n, y = TaskNegelectMean),
             colour = "black",
             size = 1.5) +
  theme_classic() +
  labs(x = "Group size",
       y = "Avg. task neglect") +
  scale_x_continuous(breaks = unique(neglectSum$n),
                     labels = c("1", "", "4", "", "8", "", "16")) +
  scale_y_continuous(breaks = seq(0, 1, 0.1),
                     limits = c(0, 0.71),
                     expand = c(0, 0)) +
  theme(legend.position = "none",
        legend.justification = c(1, 1),
        legend.title = element_blank(),
        legend.key.height = unit(0.3, "cm"),
        legend.key.width= unit(0.4, "cm"),
        legend.margin =  margin(t = 0, r = 0, b = 0, l = -0.2, "cm"),
        legend.text = element_text(size = 6),
        legend.text.align = 0,
        # legend.box.background = element_rect(),
        axis.text.y = element_text(size = 8, margin = margin(5, 6, 5, -2), color = "black"),
        axis.text.x = element_text(size = 8, margin = margin(6, 5, -2, 5), color = "black"),
        axis.title = element_text(size = 10, margin = margin(0, 0, 0, 0)),
        axis.ticks.length = unit(-0.1, "cm"))

gg_noTask

ggsave(filename = "output/FitnessPlots/AvgTaskNeglect_poster.png", height = 3, width = 1.75, dpi = 600)

# Within group size
# Load specialization
taskCorrTot <- do.call("rbind", groups_taskCorr)
taskCorrTot <- taskCorrTot %>% 
  mutate(TaskMean = (Task1 + Task2) / 2)
taskCorrTot <- taskCorrTot %>% 
  mutate(Set = paste0(n, "-", replicate)) %>% 
  select(n, TaskMean, Task1, Task2, Set) 

# Merge
merged_specperf <- merge(taskCorrTot, noTaskPerf, by = c("Set", "n"))
merged_specperf <- merged_specperf %>% 
  mutate(noTaskAvg = noTaskAvg / 10000) %>% 
  group_by(n) %>% 
  mutate(noTaskAvgMin = min(noTaskAvg),
         noTaskAvgMax = max(noTaskAvg),
         TaskMeanMin = min(TaskMean),
         TaskMeanMax = max(TaskMean)) %>% 
  mutate(noTaskAvgNorm = (noTaskAvg - noTaskAvgMin) / (noTaskAvgMax - noTaskAvgMin),
         TaskMeanNorm = (TaskMean - TaskMeanMin) / (TaskMeanMax - TaskMeanMin)) 

# Plot
# Palette withoutsingle individuals
palette <- c("#F00924", "#F7A329", "#FDD545", "#027C2C", "#1D10F9", "#4C0E78")

gg_specPerfNorm <- ggplot(data = merged_specperf) +
  geom_point(aes(x = TaskMeanNorm,
                 # colour = as.factor(n),
                 y = noTaskAvgNorm), 
             colour = "#F23619",
             size = 0.1) +
  theme_classic() +
  theme(legend.position = "none") +
  ylab("Normalized task neglect") +
  xlab("specialization") +
  scale_y_continuous(breaks = seq(0, 1, 0.5), 
                     limits = c(-0.01, 1.01),
                     expand = c(0, 0)) +
  scale_x_continuous(breaks = seq(0, 1, 0.5), 
                     limits = c(-0.01, 1.01),
                     expand = c(0, 0)) +
  scale_color_manual(values = palette) +
  theme(legend.position = "none",
        legend.justification = c(1, 1),
        legend.title = element_blank(),
        legend.key.height = unit(0.3, "cm"),
        legend.key.width= unit(0.4, "cm"),
        legend.margin =  margin(t = 0, r = 0, b = 0, l = -0.2, "cm"),
        legend.text = element_text(size = 6),
        legend.text.align = 0,
        # legend.box.background = element_rect(),
        axis.text.y = element_text(size = 8, margin = margin(5, 6, 5, -2), color = "black"),
        axis.text.x = element_text(size = 8, margin = margin(6, 5, -2, 5), color = "black"),
        axis.title = element_text(size = 10, margin = margin(0, 0, 0, 0)),
        axis.ticks.length = unit(-0.1, "cm"))
gg_specPerfNorm

ggsave(filename = "output/FitnessPlots/TaskNeglectVsSpecializationWithinGroups_poster.png", height = 3, width = 1.75, dpi = 600)

####################
# Stimulus Fluctuation
####################
# Unlist
stims <- unlist(groups_stim, recursive = FALSE)
stims <- do.call("rbind", stims)

#### 1 Time steps ####
# Normalize and Summarise by "day" (i.e., time window) and calculate difference
stimFluct <- stims %>% 
  select(-delta1, -delta2) %>% 
  mutate(Set = paste0(n, "-", replicate)) %>% 
  group_by(Set) %>% 
  mutate(t = 0:(length(Set)-1)) %>% 
  mutate(Window = t %/% 1) %>% 
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
  mutate(GroupSizeFactor = factor(n, levels = sort(unique(n))))

# Summarise by n
stimSumFluct <- stimFluct %>% 
  group_by(n, GroupSizeFactor) %>% 
  summarise(s1FluctMean = mean(s1Fluct, na.rm = TRUE),
            s1FluctSE = sd(s1Fluct, na.rm = TRUE) / sqrt(length(s1Fluct)),
            s2FluctMean = mean(s2Fluct, na.rm = TRUE),
            s2FluctSE = sd(s2Fluct, na.rm = TRUE) / sqrt(length(s2Fluct)))
stimSumFluct <- as.data.frame(stimSumFluct)
stimSumFluct <- stimSumFluct %>% 
  mutate(GroupSizeFactor = factor(GroupSizeFactor, levels = sort(unique(n))))

# Plot
gg_stimfluct <- ggplot() +
  geom_point(data = stimFluct, 
             aes(x = n, y = s1Fluct),
             fill = "grey50", 
             colour = "grey50", 
             position = position_jitter(width = 0.1),
             size = 0.7, 
             alpha = 0.4,
             stroke = 0) +
  # geom_line(data = stimSumFluct,
  #           aes(x = n, y = s1FluctMean),
  #           size = 0.3) +���
  theme_classic() +
  labs(x = "Group size",
       y = "Stimulus fluctuation") +
  scale_x_continuous(breaks = unique(neglectSum$n),
                     labels = c("", "2", "4", "", "8", "", "16")) +
  scale_y_continuous(breaks = seq(0, 2, 0.2),
                     limits = c(0, 0.85),
                     expand = c(0, 0)) +
  theme(legend.position = "none") +
  # Mean and SE portion of plot
  geom_errorbar(data = stimSumFluct, 
                aes(x = n, 
                    ymin = s1FluctMean - s1FluctSE, 
                    ymax = s1FluctMean + s1FluctSE),
                colour = "black",
                size = 0.25) +
  geom_point(data = stimSumFluct, 
             aes(x = n, y = s1FluctMean),
             colour = "black",
             size = 1.5) +
  theme(legend.position = "none",
        legend.justification = c(1, 1),
        legend.title = element_blank(),
        legend.key.height = unit(0.3, "cm"),
        legend.key.width= unit(0.4, "cm"),
        legend.margin =  margin(t = 0, r = 0, b = 0, l = -0.2, "cm"),
        legend.text = element_text(size = 6),
        legend.text.align = 0,
        # legend.box.background = element_rect(),
        axis.text.y = element_text(size = 8, margin = margin(5, 6, 5, -2), color = "black"),
        axis.text.x = element_text(size = 8, margin = margin(6, 5, -2, 5), color = "black"),
        axis.title = element_text(size = 10, margin = margin(0, 0, 0, 0)),
        axis.ticks.length = unit(-0.1, "cm"))

gg_stimfluct

ggsave(filename = "output/FitnessPlots/StimulusFluctuations_poster.png", height = 3, width = 2, dpi = 600)


#################
# Sample stimuli time series
####################
# Unlist
stims <- unlist(groups_stim, recursive = FALSE)
stims <- do.call("rbind", stims)

# Select out example colonies
stimSet <- stims %>% 
  filter(n %in% c(2)) %>% 
  filter(replicate == 3) %>% 
  group_by(n) %>% 
  mutate(timestep = 0:(length(n)-1))

# Plot
gg_stimEx2 <- ggplot(data = stimSet, aes(x = timestep, y = s1)) +
  geom_line(colour = "#4eb3d3", 
            size = 0.5) +
  theme_classic() +
  xlab("Timestep") +
  ylab("Stimulus") +
  scale_x_continuous(breaks = seq(0, 10000, 250),
                     limits = c(0, 500),
                     labels = comma) +
  scale_y_continuous(limits = c(0, 16),
                     breaks = seq(0, 15, 15),
                     expand = c(0,0)) +
  theme(plot.margin = margin(0.25, 0.4, 0.25, 0.25, "cm"),
        axis.text = element_text(size = 8),
        axis.title = element_blank(),
        axis.ticks = element_line(size = 0.5),
        strip.text = element_text(size = 7, face = "italic"),
        strip.background = element_rect(fill = NA, colour = NA),
        panel.spacing = unit(0.5, "cm"),
        aspect.ratio = 1) 

gg_stimEx2

ggsave(filename = "output/FitnessPlots/StimExample2_poster.png", width = 1.5, height = 1.5, units = "in", dpi = 600)


# Select out example colonies
stimSet <- stims %>% 
  filter(n %in% c(16)) %>% 
  filter(replicate == 1) %>% 
  group_by(n) %>% 
  mutate(timestep = 0:(length(n)-1))

# Plot
gg_stimEx16 <- ggplot(data = stimSet, aes(x = timestep, y = s1)) +
  geom_line(colour = "#4eb3d3", 
            size = 0.5) +
  theme_classic() +
  xlab("Timestep") +
  ylab("Stimulus") +
  scale_x_continuous(breaks = seq(0, 10000, 250),
                     limits = c(0, 500),
                     labels = comma) +
  scale_y_continuous(limits = c(0, 16),
                     breaks = seq(0, 15, 15),
                     expand = c(0,0)) +
  theme(plot.margin = margin(0.25, 0.4, 0.25, 0.25, "cm"),
        axis.text = element_text(size = 8),
        axis.title = element_blank(),
        axis.ticks = element_line(size = 0.5),
        strip.text = element_text(size = 7, face = "italic"),
        strip.background = element_rect(fill = NA, colour = NA),
        panel.spacing = unit(0.5, "cm"),
        aspect.ratio = 1) 

gg_stimEx16

ggsave(filename = "output/FitnessPlots/StimExample16_poster.png", width = 1.5, height = 1.5, units = "in", dpi = 600)


####################
# Sample Task Time Series
####################
# Unlist
tallies <- unlist(groups_taskTally, recursive = FALSE)
tallies <- do.call("rbind", tallies)

# Normalize
tallyEx <- tallies %>% 
  filter(n %in% c(2)) %>% 
  filter(replicate == 3) %>% 
  mutate(Task1 = Task1 / n,
         Task2 = Task2 / n,
         Inactive = Inactive / n,
         n = factor(n)) %>% 
  melt(id.vars = c("n", "t", "replicate")) %>% 
  rename(Task = variable, Freq = value) %>% 
  mutate(timestep = 0:(length(n)-1)) %>% 
  filter(Task == "Task1")


# Plot
cols <- c("#F00924", "#FDD545", "#4C0E78")

gg_taskEx <- ggplot(data = tallyEx, aes(x = t, y = Freq)) +
  geom_line(colour = "#F00924") +
  theme_classic() +
  xlab("Time step") +
  ylab("Proportion of colony") +
  scale_x_continuous(breaks = seq(0, 10000, 100),
                     limits = c(0, 200),
                     labels = comma,
                     expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 1),
                     breaks = seq(0, 1, 0.5),
                     expand = c(0,0)) +
  theme(plot.margin = margin(0.25, 0.4, 0.25, 0.25, "cm"),
        axis.text = element_text(size = 10, color = "black"),
        axis.title = element_blank(),
        axis.ticks = element_line(size = 0.5),
        strip.text = element_text(size = 7, face = "italic"),
        strip.background = element_rect(fill = NA, colour = NA),
        panel.spacing = unit(0.5, "cm"),
        aspect.ratio = 1) 

gg_taskEx

ggsave(filename = "output/FitnessPlots/TaskExample2_poster.png", width = 1.5, height = 1.5, units = "in", dpi = 600)

