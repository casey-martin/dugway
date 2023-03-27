library(cowplot)
library(lubridate)
library(scales)
library(stringr)
library(tidyverse)
library(umap)

df = read_tsv('./data/dugway_table.tsv')
embed = read_tsv('./data/embeddings.tsv')
classification <- c('Unclassified',
                    'Restricted',
                    'Confidential',
                    'Secret')

names(classification) <- c('U', 'C', 'S', 'R')

umap_embed <- umap(embed)
umap_embed_layout <- as_tibble(umap_embed$layout)



df %>% 
  group_by(Corp_Author_Name) %>% 
  summarise(counts = n()) %>% 
  arrange(desc(counts)) %>% 
  slice_head(n = 9) -> top_labs

df %>% 
  mutate(Document_Classification = substr(Document_Classification, 1, 1),
         Center = if_else(Corp_Author_Name %in% top_labs$Corp_Author_Name,
                          Corp_Author_Name,
                          'OTHER'),
         Document_Classification = factor(classification[Document_Classification],
                                 ordered = TRUE,
                                 levels = classification)) -> df

df %>% 
  group_by(Center, Document_Classification) %>% 
  summarise(class_counts = n()) %>% 
  ungroup() %>% 
  mutate(Center = str_wrap(Center, 25)) -> center_pubs 
center_pubs %>% 
  group_by(Center) %>% 
  summarise(counts = sum(class_counts)) -> center_sums

center_pubs %>% 
  left_join(center_sums) %>% 
  ggplot(aes(x = class_counts, y = reorder(Center, counts))) +
    geom_bar(stat='identity', color = 'black',
             aes(fill = Document_Classification)) +
    ylab('') +
    theme_bw(base_size = 18) +
    ggtitle('Institution Publication Count') +
    scale_x_continuous(expand = expansion(mult = c(0, .24)),
                       labels = scientific) +
    facet_wrap(~Document_Classification,
               nrow = 1,
               scales = 'free_x') +
    geom_text(aes(label = class_counts,hjust = -.25)) +
    theme(legend.position = 'none',
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 90, vjust = 0.5)) +
    scale_fill_brewer(palette = 'Spectral') -> center_barplots


corp_labs <- str_wrap(df$Center, 25)
names(corp_labs) <- df$Center 

df %>% 
  mutate(Publish_Date = floor_date(Publish_Date, 'month')) %>% 
  group_by(Center, Publish_Date) %>%
  summarise(counts = n()) %>% 
  arrange(desc(counts)) %>% 
  ggplot(aes(x = Publish_Date, y = counts)) + 
    geom_bar(stat = 'identity') +
    facet_wrap(~Center, scales = 'free_y',
               labeller = labeller(Center = corp_labs)) +
    theme_bw(base_size = 16)

df  %>% 
  group_by(Document_Classification) %>% 
  summarise(counts = n()) %>% 
  ggplot(aes(y = reorder(Document_Classification, counts), x = counts)) +
    geom_bar(stat='identity') +
    geom_text(aes(label = counts), hjust = -0.25) +
    theme_bw(base_size = 18) +
    scale_x_continuous(expand = expansion(mult = c(0, .13))) +
    ylab('') +
    ggtitle('Document Classification') -> doc_class

df %>% 
  group_by(Document_Classification) %>% 
  mutate(Class_Counts = n()) %>% 
  ungroup() %>% 
  mutate(Publish_Date = floor_date(Publish_Date, 'month')) %>% 
  group_by(Publish_Date, Document_Classification, Class_Counts) %>% 
  summarise(Doc_Counts = n()) %>% 
  ungroup() %>% 
  group_by(Publish_Date) %>% 
  mutate(Monthly_Doc_Counts = sum(Doc_Counts)) %>% 
  ungroup() %>% 
  filter(Class_Counts > 300) %>% 
  group_by(Publish_Date) %>% 
  mutate(Monthly_Missing_Doc_Counts = sum(Doc_Counts)) %>% 
  group_modify(~ add_row(.x, .before=0,
                         Publish_Date = first(.x$Publish_Date), 
                         Document_Classification = "Other",
                         Monthly_Doc_Counts = first(.x$Monthly_Doc_Counts),
                         Doc_Counts = first(.x$Monthly_Doc_Counts) - 
                                      first(.x$Monthly_Missing_Doc_Counts))) %>% 
  ungroup() %>% 
  replace_na(list(Class_Counts = 0)) -> monthly_pubs_by_class


monthly_pubs_by_class %>% 
  ggplot(aes(x = Publish_Date, y = Doc_Counts)) +
    geom_bar(stat='identity', color='black',
             aes(fill = reorder(Document_Classification, -Class_Counts))) +
    scale_fill_brewer(palette = 'Spectral') +
    theme_bw(base_size = 18) +
    theme(legend.position = 'none') +
    labs(fill = 'Document Classification', 
         x = 'Publication Date',
         y = 'Count',
         title = 'Monthly Publications') -> pub_dates
    

df %>% 
  cbind(umap_embed_layout) %>% 
  mutate(total = n()) %>% 
  group_by(Document_Classification) %>% 
  mutate(class_counts = n()) %>% 
  ungroup() %>% 
  mutate(myalpha = class_counts/max(class_counts),
         myalpha = rescale(myalpha, to = c(1, 0.01))) %>% 
  filter(V1 < 20, V2 < 100) %>% 
  ggplot(aes(x = V1, y = V2, fill = Document_Classification)) +
    geom_point(aes(alpha = myalpha),
                size = 1.8, pch = 21) +
    theme_bw(base_size = 18) +
    labs(fill = 'Classification') +
    facet_wrap(~Document_Classification,
               nrow = 2) +
    theme(legend.position = 'bottom') +
    ggtitle('UMAP Embeddings') +
    scale_fill_brewer(palette = 'Spectral') +
    scale_alpha(guide = 'none') -> embed_class


plot_grid(pub_dates, center_barplots, 
          embed_class + theme(legend.position = 'none'),
          labels = c('A', 'B', 'C'),
          label_size = 22, nrow = 1,
          rel_widths = c(0.5, 1, 0.6)) -> top_row

plot_grid(top_row, get_legend(embed_class), 
          ncol = 1,
          rel_heights = c(1, 0.1))


df %>% 
  cbind(umap_embed_layout) %>% 
  filter(V1 < 20,
         V2 < 100) %>% 
  ggplot(aes(x = V1, y= V2, 
             color = factor(Document_Classification, ordered = TRUE, 
                            levels = classification))) +
    geom_point(alpha = 0.3, size = 1.5) +
    theme_bw(base_size = 18) +
    scale_color_brewer(palette = 'Dark2') +
    facet_wrap(~Center, nrow = 4,
               labeller = labeller(Center = corp_labs)) +
    theme(strip.text = element_text(size=10)) +
    labs(color = 'Classification')



