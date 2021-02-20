#' Plot wind profile using wind barbs
#' 
#' Function for plotting wind direction and wind speed profile. 
#' TODO: Can be launched as standalone function or coupled with pre-drawn Skew-T diagram.
#'
#' @import stats
#' @import utils
#' @importFrom dplyr left_join
#' @importFrom grDevices colorRampPalette
#'
#' @param pres pressure levels 
#' @param ws wind speed in knots(!)
#' @param wd wind direction in degress
#' @param altitude altitude in metres above sea level
#' @param convert logical. Whether to convert wind speed from knots to m/s (default FALSE)
#' @param ptop Pressure top level to be used for plotting wind speed. Valid options should be < 200 hPa (100 by default)
#' @param interpolate logical, draw wind barbs only at interpolated altitudes with 1 km interval (default = TRUE)  instead of all wind barbs for a given input dataset
#' @param showaxis logical, drawing bounding box with left axis for pressure heighs (default FALSE)
#' @param ... extra graphic arguments
#' @export
#' 
#' @examples 
#' # load examplary dataset:
#' data("sounding_wien")
#' attach(sounding_wien)
#' sounding_barbs(pres = PRES, ws = SKNT, wd = DRCT, altitude = HGHT, convert = TRUE)
#'

sounding_barbs <- function(pres, ws, wd, altitude, convert = FALSE,
                           ptop = 100, interpolate = TRUE, 
                           showaxis = FALSE, ...){
  
  if(ptop > 200) {
    stop("\nptop argument needs to be set < 200 (hPa)!")
  }
  
  # whether to convert wind speed from knots to m/s
  if(convert) {
    ws <- ws * 0.51444
  }
  
  # marginesy w ukladzie: 
  #c(bottom, left, top, right) 
  #par(mar = c(2, 1.5, 1 ,6))
  
  ymax <- skewty(1050)
  #ymin <- skewty(50)
  ymin <- skewty(ptop)
  xmin <- 0
  # przesuwanie rysowanego zakresu na wykresie:
  xmax <- 1
  
  xc <- c(xmin, xmin, xmax, xmax, xmin)
  yc <- c(ymin, ymax, ymax, ymin, ymin)
  plot(xc, yc, type = "l", axes = FALSE, xlab = "", ylab = "", lwd = 0.0)
  
  if(showaxis) plot(xc, yc, type = "l", axes = FALSE, xlab = "", ylab = "", lwd = 1)
  
  prs <- pres[which((altitude-altitude[1]) %in% seq(0,16000,500))]
  #prs <- c(1050, 1000, 850, 700, 500, 400, 300, seq(from = 200, to = ptop, by = -50))
  NPRES <- length(prs)
  
  ypos <- skewty(prs[2:NPRES])
  
  if(showaxis){
    axis(2, at = ypos, labels = NA, pos = xmin, padj = 1)
    # commented label for X-axis
    mtext(side = 2, line = 1.5, "Pressure (hPa)", padj = 2, cex=0.6)
  }
  
  # end of drawing diagram in square
  
  # draw pressure heights:
  y <- skewty(pres)
  ind = y < ymin # clipping to max visible height
  x <- rep(xmin, length(y))
  
  #segments(x0 = 0.5, y0 = y, x1 = ws, y1 = y, col = data$cols, lwd = 5)
  if(!interpolate){
    windbarbs(cx = x[ind]+0.5, cy = y[ind],direction = wd[ind], speed = ws[ind], cex = 0.3)
  }
  
  if(interpolate){
    u = round(-ws * sin(wd * pi/180), 2)
    v = round(-ws * cos(wd * pi/180), 2)
    
    data_u = approx(y = u, x = y, xout = skewty(prs))
    data_v = approx(y = v, x = y, xout = skewty(prs))
    data = data.frame(u = data_u$y, v = data_v$y, y = data_u$x)
    
    data$ws <- sqrt((data$u^2) + (data$v^2))
    data$wd <- round((180/pi * atan2(data$u, data$v) + 180))
    windbarbs(cx = rep(x = (xmin+xmax)/2, times = length(data$y)),
              cy = data$y, direction = data$wd, speed = data$ws, cex = 0.4)
  }
  #points(data$x, data$y, col = "blue")
  
}
  
