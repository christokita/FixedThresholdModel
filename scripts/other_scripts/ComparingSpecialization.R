################################################################################
#
# Comparing various specialization plots
#
################################################################################

rm(list = ls())
source("scripts/__Util__MASTER.R")
source("scripts/3A_PrepPlotExperimentData.R")
library(RColorBrewer)
library(scales)

load("output/SpecializationMetrics/Rdata/FixedDelta06Sigma01Eta7100reps.Rdata")

####################
# Compare entropies
####################
# Unlist
entropy <- unlist(groups_entropy, recursive = FALSE)
entropy <- do.call("rbind", entropy)  %>% 
  mutate(set = paste(n, replicate, sep = "-"))%>% 
  select(-Dsym, -Dyx) %>% 
  filter(n != 1)


####################
# Task Rank Correlation
####################
# Unlist
taskCorrTot <- do.call("rbind", groups_taskCorr)
taskCorrTot <- taskCorrTot %>% 
  mutate(TaskMean = (Task1 + Task2) / 2) %>% 
  mutate(set = paste(n, replicate, sep = "-"))%>% 
  select(-Task1, -Task2)


####################
# Task Performance Specialization
####################
taskSpec <- groups_specialization %>% 
  group_by(n, replicate) %>% 
  summarise(SpecMean = mean(TransSpec))  %>% 
  mutate(set = paste(n, replicate, sep = "-")) 


####################
# Bind together and summarise
####################
# Bind
metrics <- merge(taskCorrTot, entropy)
metrics <- merge(metrics, taskSpec)

# Summarise
metrics <- metrics %>% 
  melt(., id.vars = c("n", "replicate", "set"))

names(metrics) <- c("n", "replicate", "set", "metric", "value")

metrics <- metrics %>% 
  group_by(n, metric) %>% 
  summarise(Mean = mean(value),
            SE = sd(value) / sqrt(length(value)))

names(metrics) <- c("n", "metric", "Mean", "SE")

levels(metrics$metric) <-c("Rank Correlation", "Task Entropy", "Task Consistency")

####################
# Plot
####################
gg_metric <- ggplot(data = metrics, aes(x = n, y = Mean, group = metric)) +
  geom_hline(aes(yintercept = 0), 
             colour = "grey30",
             size = 0.25) +
  geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), 
                width = 0.7) +
  geom_line(aes(y = Mean, linetype = metric)) +
  geom_point(aes(y = Mean, fill = metric), 
             size = 1.5,
             shape = 21) +
  theme_classic() +
  xlab("Group Size") +
  ylab("Value") +
  scale_y_continuous(limits = c(-0.05, 0.65),
                     breaks = seq(0, 1, 0.2)) +
  scale_x_continuous(breaks = unique(metrics$n)) +
  scale_fill_manual(name = "Metric",
                    values = c("black", "white", "white")) +
  scale_linetype_manual(name = "Metric",
                        values = c("solid", "dashed", "dotted")) +
  theme(legend.position = "none", 
        legend.title = element_text(size = 7, face = "bold"),
        legend.key.height = unit(0.3, "cm"),
        legend.key.width= unit(0.4, "cm"),
        legend.margin =  margin(t = 0.1, r = 0.1, b = 0.1, l = 0.1, "cm"),
        legend.text = element_text(size = 10),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 10),
        axis.ticks = element_line(size = 0.5),
        panel.grid = element_blank(),
        strip.text = element_text(size = 8, face = "italic"),
        strip.background = element_rect(fill = NA, colour = NA),
        panel.spacing = unit(0.5, "cm")) +
  facet_wrap(~ metric)

gg_metric

ggsave(gg_metric, file = "output/SpecializationMetrics/Plots/AllMetricsComparison.png", height = 2.2, width = 6, units = "in", dpi = 800)


####################
# Entropy vs Rank Correlation
####################

# Unlist
entropy <- unlist(groups_entropy, recursive = FALSE)
entropy <- do.call("rbind", entropy)  %>% 
  mutate(set = paste(n, replicate, sep = "-"))

# Unlist
taskCorrTot <- do.call("rbind", groups_taskCorr)
taskCorrTot <- taskCorrTot %>% 
  mutate(TaskMean = (Task1 + Task2) / 2) %>% 
  mutate(set = paste(n, replicate, sep = "-"))%>% 
  select(-Task1, -Task2)

# Speclialization vs Entropy at colony level
entropy <- entropy %>% 
  mutate(colony = paste0(n, "-", replicate)) %>% 
  group_by(colony) %>% 
  summarize(Dsym = mean(Dsym),
            Dyx = mean(Dyx),
            Dxy = mean(Dxy))
taskEntrCorr <- taskCorrTot %>% 
  mutate(colony = paste0(n, "-", replicate)) %>% 
  merge(entropy) %>% 
  select(colony, n, replicate, TaskMean, Dxy) %>% 
  mutate(groupsize = factor(paste0("n = ", n), 
                            levels = c("n = 2", "n = 4", "n = 6", "n = 8", "n = 12", "n = 16")))

palette <- c("#F00924", "#F7A329", "#FDD545", "#027C2C", "#1D10F9", "#4C0E78", "#bdbdbd", "#525252")
gg_entrcorr <- ggplot(data = taskEntrCorr, aes(x = Dxy, y = TaskMean, col = groupsize)) +
  geom_hline(data = taskCorrTot, 
             aes(yintercept = 0),
             colour = "grey30",
             size = 0.25) +
  geom_point(alpha = 0.5,
             size = 0.2) +
  theme_bw() +
  xlab("Task Entropy") +
  ylab("Rank Correlation") +
  scale_colour_manual(name = "Group Size", 
                      values = palette) +
  scale_x_continuous(limits = c(0, 0.4),
                     breaks = seq(0, 0.4, 0.2)) +
  scale_y_continuous(limits = c(-0.5, 1)) +
  theme(legend.position = "none", 
        legend.title = element_text(size = 7),
        legend.key.height = unit(0.3, "cm"),
        legend.key.width= unit(0.4, "cm"),
        legend.margin =  margin(t = 0.1, r = 0.1, b = 0.1, l = 0.1, "cm"),
        legend.text = element_text(size = 6),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 10),
        axis.ticks = element_line(size = 0.5),
        panel.border = element_rect(fill = NA, size = 1),
        panel.grid = element_blank(),
        strip.text = element_text(size = 7, face = "italic"),
        strip.background = element_rect(fill = NA, colour = NA),
        panel.spacing = unit(0.5, "cm")) +
  facet_wrap(~ groupsize) 

gg_entrcorr

ggsave(filename = "output/SpecializationMetrics/Plots/EntropyVsCorrelation.png", width = 4, height = 3, units = "in", dpi = 600)

####################
# Fitness related plots
####################
# Speclialization vs Total Activity at inidividual level
palette <- c("#F00924", "#F7A329", "#FDD545", "#027C2C", "#1D10F9", "#4C0E78", "#bdbdbd", "#525252") 

taskDist <- unlist(groups_taskDist, recursive = FALSE)
taskDistTot <- do.call("rbind", taskDist)
taskDistSpec <- taskDistTot %>% 
  mutate(Active = Task1 + Task2) %>% 
  merge(groups_specialization) %>% 
  filter(n > 1) %>% 
  mutate(groupsize = factor(paste0("Group size ", n), 
                            levels = c("Group size 2", "Group size 4", "Group size 6", "Group size 8", "Group size 12", "Group size 16")))

gg_actspec <- ggplot(data = taskDistSpec, aes(x = Active, y = TransSpec, colour = groupsize)) +
  geom_hline(aes(yintercept = 0), 
             colour = "grey30",
             size = 0.25) +
  geom_point(alpha = 0.5, 
             size = 0.8,
             stroke = 0) +
  theme_bw() +
  scale_colour_manual(name = "Group Size", 
                      values = palette) +
  scale_y_continuous(limits = c(-0.2, 1)) +
  scale_x_continuous(breaks = seq(0, 1, 0.2)) +
  theme(legend.position = "none") +
  xlab("Activity level") +
  ylab("Task consistency") +
  theme(legend.position = "none", 
        legend.title = element_text(size = 7),
        legend.key.height = unit(0.3, "cm"),
        legend.key.width= unit(0.4, "cm"),
        legend.margin =  margin(t = 0.1, r = 0.1, b = 0.1, l = 0.1, "cm"),
        legend.text = element_text(size = 6),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 10),
        axis.ticks = element_line(size = 0.5),
        panel.border = element_rect(fill = NA, size = 1),
        panel.grid = element_blank(),
        strip.text = element_text(size = 8, face = "italic"),
        strip.background = element_rect(fill = NA, colour = NA),
        panel.spacing = unit(0.5, "cm")) +
  facet_wrap(~ groupsize)

gg_actspec

ggsave(filename = "output/SpecializationMetrics/Plots/SpecializationVsActivity.png", width = 4, height = 3, units = "in", dpi = 800)



myPalette <- colorRampPalette(brewer.pal(9, "Blues"))

gg_taskspec <- ggplot(data = taskDistSpec, aes(x = Task1, y = Task2, colour = TransSpec)) +
  geom_point(alpha = 0.5,
             size = 0.8,
             stroke = 0) +
  theme_bw() +
  scale_color_gradientn(name = "Task\nconsistency",
                        colours = myPalette(5), values = c(0, 0.1, 0.3, 0.5, 1), oob = squish,
                        breaks = seq(-1, 1, 0.2), limits = c(-0.2, 0.8)) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.5)) +
  scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.5)) +
  theme(legend.position = "none") +
  xlab("Task 1 activity") +
  ylab("Task 2 activity") +
  theme(legend.position = "right", 
        legend.title = element_text(size = 10),
        legend.key.height = unit(0.4, "cm"),
        legend.key.width= unit(0.3, "cm"),
        legend.margin =  margin(t = 0.1, r = 0.1, b = 0.1, l = 0.1, "cm"),
        legend.text = element_text(size = 8),
        axis.text = element_text(size = 8),
        axis.title = element_text(size = 10),
        axis.ticks = element_line(size = 0.5),
        panel.border = element_rect(fill = NA, size = 1),
        panel.grid = element_blank(),
        strip.text = element_text(size = 8, face = "italic"),
        strip.background = element_rect(fill = NA, colour = NA),
        panel.spacing = unit(0.5, "cm")) +
  facet_wrap(~ groupsize)

gg_taskspec

ggsave(filename = "output/SpecializationMetrics/Plots/TasksVsSpecializationWithLegend.png", width = 4, height = 3, units = "in", dpi = 800)

