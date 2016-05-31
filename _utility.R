# * Author:    Bangyou Zheng (Bangyou.Zheng@csiro.au)
# * Created:   02:06 PM Wednesday, 11 May 2016
# * Copyright: AS IS


new_breaks <- function(x) {
    if (max(x) < 11) {
        breaks <- seq(1, 10, by = 1)
    } else {
        breaks <- seq(0, 2500, by = 500)
    }
    names(breaks) <- attr(breaks,"labels")
    breaks
}


plot_report <- function(df, x_var, y_cols, x_lab = x_var, y_lab = 'Value',
                        panel = FALSE) {
    library(ggplot2)
    # x_var_name <- gsub('.*\\.(.*)', '\\1', x_var)
    # x_var_n <- list()
    # x_var_n[[x_var_name]] <- x_var
    pd <- df %>%
        select_(.dots = c(x_var, y_cols)) %>%
        gather_(key_col = 'Trait', value_col = 'YValue', gather_cols = y_cols) %>%
        gather_(key_col = 'XVar', value_col = 'XValue', gather_cols = x_var) %>%
        mutate(Trait = gsub('.*\\.(.*)', '\\1', Trait)) %>%
        mutate(XVar = gsub('.*\\.(.*)', '\\1', XVar))
    x_var_name <- gsub('.*\\.(.*)', '\\1', x_var)
    y_cols_name <- gsub('.*\\.(.*)', '\\1', y_cols)
    pd <- pd %>%
        mutate(Trait = factor(Trait, levels = y_cols_name),
               XVar = factor(XVar, levels = x_var_name))

    p <- ggplot(pd, aes(XValue, YValue))
    if (panel) {
        p <- p +
            geom_line() +
            geom_point()
        if (length(x_var) == 1) {
            p <- p + facet_wrap(~Trait, scales = 'free_y', ncol = 1)
        } else {
            p <- p + facet_grid(Trait~XVar, scales = 'free')
        }
    } else {
        p <- p +
            geom_line(aes(colour = Trait)) +
            geom_point(aes(colour = Trait))
        if (length(x_var) > 1) {
            p <- p + facet_wrap(~XVar, scales = 'free_x', ncol = 1)
        }
    }
    p <- p + theme_bw() +
        theme(legend.position = 'bottom') +
        xlab(x_lab) + ylab(y_lab) +
        guides(colour = guide_legend(title = '', ncol = 1))
    if (length(grep('Stage', x_var)) > 0) {

        p <- p + scale_x_continuous(breaks = new_breaks)
    }
    p
}




plot_report_vector <- function(df, x_var, y_cols, x_lab = x_var, y_lab = 'Value',
                        panel = FALSE) {
    library(ggplot2)
    # x_var_name <- gsub('.*\\.(.*)', '\\1', x_var)
    # x_var_n <- list()
    # x_var_n[[x_var_name]] <- x_var

    col_names <- grepl(paste(y_cols, collapse = '|'), names(df)) | (names(df) %in% x_var)
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
        gather_(key_col = 'XVar', value_col = 'XValue', gather_cols = x_var) %>%
        mutate(XVar = gsub('.*\\.(.*)', '\\1', XVar))
    x_var_name <- gsub('.*\\.(.*)', '\\1', x_var)
    pd <- pd %>%
        mutate(XVar = factor(XVar, levels = x_var_name))


    p <- ggplot(pd, aes(XValue, Value, colour = Index)) +
        geom_line() +
        geom_point() +
        theme_bw() +
        theme(legend.position = 'bottom') +
        xlab(x_lab) + ylab(y_lab) +
        guides(colour = guide_legend(title = ''))
    if (length(x_var) > 1 & length(y_cols) > 1) {
        p <- p + facet_grid(Trait~XVar, scales = 'free_x')
    } else if (length(x_var) > 1) {
        p <- p + facet_wrap(~XVar, scales = 'free_x', ncol = 1)
    }

    if (length(grep('Stage', x_var)) > 0) {
        p <- p +
            scale_x_continuous(breaks = new_breaks)
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

