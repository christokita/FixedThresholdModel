################################################################################
#
# Behavioral Variation (De-syncing) within short time steps
#
################################################################################

rm(list = ls())
source("scripts/__Util__MASTER.R")
source("scripts/3_PrepPlotExperimentData.R")
library(RColorBrewer)
library(scales)


# Deterministic
load("output/__RData/MSrevision_FixedDelta06_DetThreshDetUpdateDetQuit100reps.Rdata")
individualVar <- lapply(groups_taskOverTime, function(group_size) {
  # Loop through replicates within group size
  within_groupTaskDiversity <- lapply(group_size, function(replicate) { 
    # Standard Dev
    Variation <- apply(replicate, 1, FUN = sd)
    # Shannon's diversity index of tasks
    Shannon <- apply(replicate, 1, FUN = function(row) {
      inactive <- sum(row == 0) /length(row)
      task1 <- sum(row == 1) / length(row)
      task2 <- sum(row == 2) / length(row)
      entropies <- lapply(c(inactive, task1, task2), function(p) {
        E <- p * log(p)
      })
      entropies[is.na(entropies)] <- 0
      diversity <- -1 * sum(unlist(entropies))
    })
    to_return <- data.frame(n = ncol(replicate), 
                            SD = mean(Variation),
                            Diversity = mean(Shannon))
    return(to_return)
  })
  group_var <- do.call("rbind", within_groupTaskDiversity)
})
model_var <- do.call("rbind", individualVar)
model_var$SD[is.na(model_var$SD)] <- 0
model_var_Sum <- model_var %>% 
  group_by(n) %>% 
  summarise(VariationMean = mean(SD),
            VariationSE = sd(SD) / sqrt(length(SD)),
            DiversityMean = mean(Diversity),
            DiversitySE = sd(Diversity) / sqrt(length(Diversity))) %>% 
  mutate(Source = "Deterministic")
model_var_all <- model_var_Sum

# Probabilistic thresholds
load("output/__RData/MSrevision_FixedDelta06_DetUpdateDetQuit100reps.Rdata")
individualVar <- lapply(groups_taskOverTime, function(group_size) {
  # Loop through replicates within group size
  within_groupTaskDiversity <- lapply(group_size, function(replicate) { 
    # Standard Dev
    Variation <- apply(replicate, 1, FUN = sd)
    # Shannon's diversity index of tasks
    Shannon <- apply(replicate, 1, FUN = function(row) {
      inactive <- sum(row == 0) /length(row)
      task1 <- sum(row == 1) / length(row)
      task2 <- sum(row == 2) / length(row)
      entropies <- lapply(c(inactive, task1, task2), function(p) {
        E <- p * log(p)
      })
      entropies[is.na(entropies)] <- 0
      diversity <- -1 * sum(unlist(entropies))
    })
    to_return <- data.frame(n = ncol(replicate), 
                            SD = mean(Variation),
                            Diversity = mean(Shannon))
    return(to_return)
  })
  group_var <- do.call("rbind", within_groupTaskDiversity)
  
})
model_var <- do.call("rbind", individualVar)
model_var$SD[is.na(model_var$SD)] <- 0
model_var_Sum <- model_var %>% 
  group_by(n) %>% 
  summarise(VariationMean = mean(SD),
            VariationSE = sd(SD) / sqrt(length(SD)),
            DiversityMean = mean(Diversity),
            DiversitySE = sd(Diversity) / sqrt(length(Diversity))) %>% 
  mutate(Source = "Prob. Thresholds")
model_var_all <- rbind(model_var_all, model_var_Sum)

# Probabilistic quitting
load("output/__RData/MSrevision_FixedDelta06_DetThreshDetUpdate100reps.Rdata")
individualVar <- lapply(groups_taskOverTime, function(group_size) {
  # Loop through replicates within group size
  within_groupTaskDiversity <- lapply(group_size, function(replicate) { 
    # Standard Dev
    Variation <- apply(replicate, 1, FUN = sd)
    # Shannon's diversity index of tasks
    Shannon <- apply(replicate, 1, FUN = function(row) {
      inactive <- sum(row == 0) /length(row)
      task1 <- sum(row == 1) / length(row)
      task2 <- sum(row == 2) / length(row)
      entropies <- lapply(c(inactive, task1, task2), function(p) {
        E <- p * log(p)
      })
      entropies[is.na(entropies)] <- 0
      diversity <- -1 * sum(unlist(entropies))
    })
    to_return <- data.frame(n = ncol(replicate), 
                            SD = mean(Variation),
                            Diversity = mean(Shannon))
    return(to_return)
  })
  group_var <- do.call("rbind", within_groupTaskDiversity)
  
})
model_var <- do.call("rbind", individualVar)
model_var$SD[is.na(model_var$SD)] <- 0
model_var_Sum <- model_var %>% 
  group_by(n) %>% 
  summarise(VariationMean = mean(SD),
            VariationSE = sd(SD) / sqrt(length(SD)),
            DiversityMean = mean(Diversity),
            DiversitySE = sd(Diversity) / sqrt(length(Diversity))) %>% 
  mutate(Source = "Prob. Quitting")
model_var_all <- rbind(model_var_all, model_var_Sum)

# Probabilistic Updating
load("output/__RData/MSrevision_FixedDelta06_DetThreshDetQuit100reps.Rdata")
individualVar <- lapply(groups_taskOverTime, function(group_size) {
  # Loop through replicates within group size
  within_groupTaskDiversity <- lapply(group_size, function(replicate) { 
    # Standard Dev
    Variation <- apply(replicate, 1, FUN = sd)
    # Shannon's diversity index of tasks
    Shannon <- apply(replicate, 1, FUN = function(row) {
      inactive <- sum(row == 0) /length(row)
      task1 <- sum(row == 1) / length(row)
      task2 <- sum(row == 2) / length(row)
      entropies <- lapply(c(inactive, task1, task2), function(p) {
        E <- p * log(p)
      })
      entropies[is.na(entropies)] <- 0
      diversity <- -1 * sum(unlist(entropies))
    })
    to_return <- data.frame(n = ncol(replicate), 
                            SD = mean(Variation),
                            Diversity = mean(Shannon))
    return(to_return)
  })
  group_var <- do.call("rbind", within_groupTaskDiversity)
  
})
model_var <- do.call("rbind", individualVar)
model_var$SD[is.na(model_var$SD)] <- 0
model_var_Sum <- model_var %>% 
  group_by(n) %>% 
  summarise(VariationMean = mean(SD),
            VariationSE = sd(SD) / sqrt(length(SD)),
            DiversityMean = mean(Diversity),
            DiversitySE = sd(Diversity) / sqrt(length(Diversity))) %>% 
  mutate(Source = "Prob. Updating")
model_var_all <- rbind(model_var_all, model_var_Sum)

# Threshold Variation
load("output/__RData/MSrevision_FixedDelta06_DetThreshWithSigmaDetUpdateDetQuit100reps.Rdata")
individualVar <- lapply(groups_taskOverTime, function(group_size) {
  # Loop through replicates within group size
  within_groupTaskDiversity <- lapply(group_size, function(replicate) { 
    # Standard Dev
    Variation <- apply(replicate, 1, FUN = sd)
    # Shannon's diversity index of tasks
    Shannon <- apply(replicate, 1, FUN = function(row) {
      inactive <- sum(row == 0) /length(row)
      task1 <- sum(row == 1) / length(row)
      task2 <- sum(row == 2) / length(row)
      entropies <- lapply(c(inactive, task1, task2), function(p) {
        E <- p * log(p)
      })
      entropies[is.na(entropies)] <- 0
      diversity <- -1 * sum(unlist(entropies))
    })
    to_return <- data.frame(n = ncol(replicate), 
                            SD = mean(Variation),
                            Diversity = mean(Shannon))
    return(to_return)
  })
  group_var <- do.call("rbind", within_groupTaskDiversity)
  
})
model_var <- do.call("rbind", individualVar)
model_var$SD[is.na(model_var$SD)] <- 0
model_var_Sum <- model_var %>% 
  group_by(n) %>% 
  summarise(VariationMean = mean(SD),
            VariationSE = sd(SD) / sqrt(length(SD)),
            DiversityMean = mean(Diversity),
            DiversitySE = sd(Diversity) / sqrt(length(Diversity))) %>% 
  mutate(Source = "Threshold Variation")
model_var_all <- rbind(model_var_all, model_var_Sum)

# Original model
load("output/__RData/FixedDelta06Sigma01Eta7100reps.Rdata")
individualVar <- lapply(groups_taskOverTime, function(group_size) {
  # Loop through replicates within group size
  within_groupTaskDiversity <- lapply(group_size, function(replicate) {
    # Standard Dev
    Variation <- apply(replicate, 1, FUN = sd)
    # Shannon's diversity index of tasks
    Shannon <- apply(replicate, 1, FUN = function(row) {
      inactive <- sum(row == 0) /length(row)
      task1 <- sum(row == 1) / length(row)
      task2 <- sum(row == 2) / length(row)
      entropies <- lapply(c(inactive, task1, task2), function(p) {
        E <- p * log(p)
      })
      entropies[is.na(entropies)] <- 0
      diversity <- -1 * sum(unlist(entropies))
    })
    to_return <- data.frame(n = ncol(replicate),
                            SD = mean(Variation),
                            Diversity = mean(Shannon))
    return(to_return)
  })
  group_var <- do.call("rbind", within_groupTaskDiversity)

})
model_var <- do.call("rbind", individualVar)
model_var$SD[is.na(model_var$SD)] <- 0
model_var_Sum <- model_var %>%
  group_by(n) %>%
  summarise(VariationMean = mean(SD),
            VariationSE = sd(SD) / sqrt(length(SD)),
            DiversityMean = mean(Diversity),
            DiversitySE = sd(Diversity) / sqrt(length(Diversity))) %>%
  mutate(Source = "All (Original)")
model_var_all <- rbind(model_var_all, model_var_Sum)



#Plot
model_var_all$Source <- factor(model_var_all$Source, levels = c("Deterministic",
                                                                "Prob. Quitting",
                                                                "Prob. Thresholds",
                                                                "Prob. Updating",
                                                                "Threshold Variation",
                                                                "All (Original)"))


# Plot all
gg_var <- ggplot(data = model_var_all) +
  geom_errorbar(aes(x = n, ymin = VariationMean - VariationSE, ymax = VariationMean + VariationSE, colour = Source),
                width = 1.5,
                position = position_dodge(width = 1)) +
  geom_point(aes(x = n, y = VariationMean, colour = Source),
             size = 2,
             position = position_dodge(width = 1)) +
  geom_line(aes(x = n, y = VariationMean, colour = Source),
            position = position_dodge(width = 1)) +
  theme_classic() +
  scale_color_brewer(palette = "Set1") +
  scale_x_continuous(breaks = unique(model_var_all$n)) +
  xlab("Group Size") +
  ylab("Short-term Variation (SD)") +
  theme(legend.position = "right",
        legend.justification = c(1, 1),
        legend.title = element_blank(),
        legend.key.height = unit(0.3, "cm"),
        legend.key.width= unit(0.4, "cm"),
        legend.margin =  margin(t = 0, r = 0, b = 0, l = -0.2, "cm"),
        legend.text = element_text(size = 10),
        legend.text.align = 0,
        # legend.box.background = element_rect(),
        axis.text.y = element_text(size = 10, margin = margin(5, 6, 5, -2), color = "black"),
        axis.text.x = element_text(size = 10, margin = margin(6, 5, -2, 5), color = "black"),
        axis.title = element_text(size = 11, margin = margin(0, 0, 0, 0)),
        axis.ticks.length = unit(-0.1, "cm"),
        aspect.ratio = 1)

gg_var


gg_div <- ggplot(data = model_var_all) +
  geom_errorbar(aes(x = n, ymin = DiversityMean - DiversitySE, ymax = DiversityMean + DiversitySE, colour = Source),
                width = 1.5,
                position = position_dodge(width = 1)) +
  geom_line(aes(x = n, y = DiversityMean, colour = Source),
            position = position_dodge(width = 1)) +
  geom_point(aes(x = n, y = DiversityMean, colour = Source),
             size = 2,
             position = position_dodge(width = 1)) +
  theme_classic() +
  scale_color_brewer(palette = "Set1") +
  scale_x_continuous(breaks = unique(model_var_all$n)) +
  xlab("Group Size") +
  ylab("Shannon Diversity") +
  theme(legend.position = "right",
        legend.justification = c(1, 1),
        legend.title = element_blank(),
        legend.key.height = unit(0.3, "cm"),
        legend.key.width= unit(0.4, "cm"),
        legend.margin =  margin(t = 0, r = 0, b = 0, l = -0.2, "cm"),
        legend.text = element_text(size = 10),
        legend.text.align = 0,
        # legend.box.background = element_rect(),
        axis.text.y = element_text(size = 10, margin = margin(5, 6, 5, -2), color = "black"),
        axis.text.x = element_text(size = 10, margin = margin(6, 5, -2, 5), color = "black"),
        axis.title = element_text(size = 11, margin = margin(0, 0, 0, 0)),
        axis.ticks.length = unit(-0.1, "cm"),
        aspect.ratio = 1)

gg_div

