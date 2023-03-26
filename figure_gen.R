library(cowplot)
library(lubridate)
library(stringr)
library(tidyverse)
library(viridis)

df = read_tsv('./dugway_table.tsv')

df %>% 
  group_by(Corp_Author_Name) %>% 
  summarise(counts = n()) %>% 
  arrange(desc(counts)) %>% 
  slice_head(n = 10) -> top_labs

top_labs %>% 
  ggplot(aes(x = counts, y = reorder(Corp_Author_Name, counts))) +
    geom_bar(stat='identity') +
    ylab('') +
    theme_bw(base_size = 18) +
    ggtitle('Institution Publication Count')

corp_labs <- str_wrap(top_labs$Corp_Author_Name, 10)

names(corp_labs) <- top_labs$Corp_Author_Name 

df %>% 
  mutate(Publish_Date = floor_date(Publish_Date, 'month')) %>% 
  filter(Corp_Author_Name %in% top_labs$Corp_Author_Name) %>% 
  group_by(Corp_Author_Name, Publish_Date) %>%
  summarise(counts = n()) %>% 
  arrange(desc(counts)) %>% 
  ggplot(aes(x = Publish_Date, y = counts)) + 
    geom_bar(stat = 'identity') +
    facet_wrap(~Corp_Author_Name, scales = 'free_y',
               labeller = labeller(Corp_Author_Name = corp_labs)) +
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
    theme(legend.position = 'bottom') +
    labs(fill = 'Document Classification', 
         x = 'Publication Date',
         y = 'Count',
         title = 'Monthly Publications') -> pub_dates
    

plot_grid(pub_dates, doc_class, 
          labels = c('A', 'B'),
          label_size = 22,
          rel_widths = c(0.8, 1))
