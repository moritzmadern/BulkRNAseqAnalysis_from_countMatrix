## functions required for "bulkRNAseq_Analysis.Rmd"




### PCA plot function ###
PCA_plot <- function(m, groups, batch, legend_colors, plot_path=NULL){
  
  # replace NAs with 0
  m[is.na(m)] <- 0
  
  # berechne PCA
  pca_res <- prcomp(t(m))
  rot_mat <- pca_res$rotation
  res_final <- as.matrix(scale(t(m), center=TRUE, scale=FALSE)) %*% rot_mat
  eigenvectors <- pca_res$sdev^2
  anteil_var_pca1 <- round(eigenvectors[1]/sum(eigenvectors),digits=3)
  anteil_var_pca2 <- round(eigenvectors[2]/sum(eigenvectors),digits=3)
  
  ## create groups
  groups <- as.factor(groups)
  colors <- legend_colors
  names(colors) <- levels(groups)
  
  ## ggplot PCR
  if(is.null(batch)){
    df_gg <- as.data.frame(res_final)
    df_gg$samplenames <- samplenames
    df_gg$groups <- groups
    gg <- ggplot(df_gg) + 
      geom_point(aes(x=PC1, y=PC2, col=groups, text=samplenames),size=5) +
      scale_color_manual(values=legend_colors)+
      xlab(paste0("PC1  ","(",anteil_var_pca1*100,"%",")")) +
      ylab(paste0("PC2  ","(",anteil_var_pca2*100,"%",")")) +
      theme_bw()
  } else {
    df_gg <- as.data.frame(res_final)
    df_gg$samplenames <- samplenames
    df_gg$groups <- groups
    df_gg$batch <- as.factor(batch)
    gg <- ggplot(df_gg) + 
      geom_point(aes(x=PC1, y=PC2, col=groups, text=samplenames, shape=batch),size=5) +
      scale_color_manual(values=legend_colors)+
      xlab(paste0("PC1  ","(",anteil_var_pca1*100,"%",")")) +
      ylab(paste0("PC2  ","(",anteil_var_pca2*100,"%",")")) +
      theme_bw()
  }
  
  # save plot
  ggsave(plot=gg, filename=plot_path, width = 6, height = 4)
  
  # print plot
  ggplotly(gg)
  
}




### heatmap plot ###
heatmap_plot <- function(m, groups, legend_colors, sample_names, type="normal", dendrogram="column", labrow="", bool_rowv=TRUE, bool_colv = TRUE){
  
  # create groups
  names(colors) <- levels(groups)
  
  # replaces NAs with 0
  m[is.na(m)] <- 0
  colnames(m) <- sample_names
  
  # should rows be reordered
  if (bool_rowv){
    rowv <- as.dendrogram(hclust(dist(m)))
  } else {
    rowv <- FALSE
  }
  
  # should columns be reordered
  if (is.logical(bool_colv)){
    if (bool_colv){
      colv <- as.dendrogram(hclust(dist(t(m))))
    } else {
      colv <- FALSE
    }
  } else {
    colv <- bool_colv
  }
  
  # specify colors
  if(is.null(legend_colors)){
    sidecolors <- rep("white", times=ncol(m))
  } else{
    sidecolors <- legend_colors[groups]
  }
  
  # create color palette
  heatmap_pal <- colorRampPalette(rev(brewer.pal(11, "RdBu")))
  
  # plot heatmap
  colors_pal <- colorRampPalette(pals::parula(40))
  par(mfrow=c(1,1))
  par(xpd=TRUE)
  if (type == "normal"){
    heatmap.2(m,         
              Rowv = rowv,
              Colv=colv, 
              margins=c(8,8), cexCol = 1,labRow=labrow,col=heatmap_pal(50), ColSideColors = sidecolors, symkey = F,
              cex.lab=1.5, scale="none", trace="none", dendrogram=dendrogram)
  }
  if (type == "centered"){
    min_m <- min(m, na.rm=TRUE)
    max_m <- max(m, na.rm=TRUE)
    heatmap.2(m,         
              Rowv = rowv,
              Colv=colv,
              labRow=labrow, margins=c(8,8), ColSideColors = sidecolors, trace="none",col=heatmap_pal(50),
              breaks = seq(from=-2,to=2, length.out=51), 
              symkey = F,
              dendrogram=dendrogram)
  } 
  if (type == "standardized"){
    min_m <- min(m, na.rm=TRUE)
    max_m <- max(m, na.rm=TRUE)
    heatmap.2(m,         
              Rowv = rowv,
              Colv= colv,
              labRow=labrow, margins=c(8,8), ColSideColors = sidecolors, trace="none",col=heatmap_pal(50), symkey = F,
              breaks = seq(from=-2,to=2, length.out=51),
              dendrogram=dendrogram)
  }
  
  # add legend
  par(xpd=TRUE)
}




