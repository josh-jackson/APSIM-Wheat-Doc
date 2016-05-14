# * Author:    Bangyou Zheng (Bangyou.Zheng@csiro.au)
# * Created:   02:06 PM Wednesday, 11 May 2016
# * Copyright: AS IS




plot_report <- function(df, x_var, y_cols, x_lab = x_var, y_lab = 'Value',
                        panel = FALSE) {
    library(ggplot2)
    x_var_name <- gsub('.*\\.(.*)', '\\1', x_var)
    x_var_n <- list()
    x_var_n[[x_var_name]] <- x_var
    pd <- df %>%
        select_(.dots = c(x_var, y_cols)) %>%
        gather_(key_col = 'Trait', value_col = 'Value', gather_cols = y_cols) %>%
        mutate(Trait = gsub('.*\\.(.*)', '\\1', Trait)) %>%
        rename_(.dots = x_var_n)
#
#     ggvis(pd, x = as.name(x_var_name), y = ~Value, stroke = ~Trait) %>%
#         layer_lines() %>%
#         add_legend("stroke", title = "") %>%
#         add_tooltip(function(df) paste0('Stage: ', df[[x_var_name]], '\nValue: ', df$Value))
#
    p <- ggplot(pd)
    if (panel) {
        p <- p +
            geom_line(aes_string(x_var_name, 'Value')) +
            geom_point(aes_string(x_var_name, 'Value')) +
            facet_wrap(~Trait, scales = 'free_y', ncol = 1)
    } else {
        p <- p +
            geom_line(aes_string(x_var_name, 'Value', colour = 'Trait')) +
            geom_point(aes_string(x_var_name, 'Value', colour = 'Trait'))
    }
    p <- p + theme_bw() +
        theme(legend.position = 'bottom') +
        xlab(x_lab) + ylab(y_lab) +
        guides(colour = guide_legend(title = '', ncol = 1))
    if (length(grep('Stage', x_var)) > 0) {
        p <- p +
            scale_x_continuous(breaks = seq(1, 10))
    }
    p
}




plot_report_vector <- function(df, x_var, y_cols, x_lab = x_var, y_lab = 'Value',
                        panel = FALSE) {
    library(ggplot2)
    x_var_name <- gsub('.*\\.(.*)', '\\1', x_var)
    x_var_n <- list()
    x_var_n[[x_var_name]] <- x_var

    col_names <- grepl(y_cols, names(df)) | (names(df) %in% x_var)
    pd <- df[,col_names]
    names(pd) <- gsub('\\:|\\(|\\)', '_', names(pd))

    y_cols_new <- names(pd)[!(names(pd) %in% x_var)]

    pd <- pd %>%
        gather_(key_col = 'Trait', value_col = 'Value', gather_cols = y_cols_new) %>%
        mutate(
            Trait = gsub('.*\\.(.*)', '\\1', Trait),
            Index = gsub('(.*)\\d+_\\d+_(\\d+)_', '\\2', Trait),
            Trait = gsub('(.*)\\d+_\\d+_(\\d+)_', '\\1', Trait),
            Index = factor(as.numeric(as.character(Index)))
            ) %>%
        rename_(.dots = x_var_n)
    #
    #     ggvis(pd, x = as.name(x_var_name), y = ~Value, stroke = ~Trait) %>%
    #         layer_lines() %>%
    #         add_legend("stroke", title = "") %>%
    #         add_tooltip(function(df) paste0('Stage: ', df[[x_var_name]], '\nValue: ', df$Value))
    #
    p <- ggplot(pd) +
        geom_line(aes_string(x_var_name, 'Value', colour = 'Index')) +
        geom_point(aes_string(x_var_name, 'Value', colour = 'Index')) +
        theme_bw() +
        theme(legend.position = 'bottom') +
        xlab(x_lab) + ylab(y_lab) +
        guides(colour = guide_legend(title = ''))
    if (length(grep('Stage', x_var)) > 0) {
        p <- p +
            scale_x_continuous(breaks = seq(1, 10))
    }
    p
}





plot_xypair <- function(pmf, xpath, x_lab, y_lab) {

    xypair <- xml_find_one(pmf, xpath = paste0(xpath, '/following-sibling::XYPairs'))

    x <- as.numeric(xml_text(xml_children(xml_children(xypair)[[2]])))
    y <- as.numeric(xml_text(xml_children(xml_children(xypair)[[3]])))

    pd <- data.frame(x = x, y = y)

    ggplot(pd, aes(x, y)) +
        geom_point() +
        geom_line() +
        theme_bw() +
        xlab(x_lab) + ylab(y_lab)
}
