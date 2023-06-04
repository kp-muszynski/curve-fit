# set directory to dir of the script

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# loading necessary libraries

library(ChainLadder) # only for initializing RAA and Sample triangles
library(ggplot2)
library(dplyr)
library(plotly)
library(shiny)
library(DT)

# defining function for link ratios calculation

ata_weight<-function(dataset,weight){
  n<-nrow(dataset)
  z<-sapply(1:(n-1),
             function(i){
               y<-sum(dataset[c(max(n-weight+1-i,1):(n-i)),i+1])/sum(dataset[c(max(n-weight+1-i,1):(n-i)),i])
               y[is.nan(y)|is.na(y)|is.infinite(y)]<-1
               return(y)
             })
   return(z)
}

# defining function that fits the curves to age-to-age factors and returns the results

link_plot<-function(vect,vect_ini,mperiod){
  
  z<-vect[vect>1]
  
  # Exponential
  
  y<-c(1:length(z))
  exp_mod<-lm(log(z-1)~y)
  exp_extrap<-exp(predict(exp_mod,data.frame(y=c((length(vect_ini)+1):(length(vect_ini)+mperiod)))))+1
  exp_interp<-exp(predict(exp_mod,data.frame(y=c(1:length(vect_ini)))))+1
  
  # Power
  
  pwr_mod<-lm(log(log(z))~y)
  pwr_extrap<-exp(exp(predict(pwr_mod,data.frame(y=c((length(vect_ini)+1):(length(vect_ini)+mperiod))))))
  pwr_interp<-exp(exp(predict(pwr_mod,data.frame(y=c(1:length(vect_ini))))))
  
  # Weibull
  
  wib_mod<-lm(log(-log(-(z^(-1)-1)))~log(y))
  wib_extrap<-(-(exp(-exp(predict(wib_mod,data.frame(y=c((length(vect_ini)+1):(length(vect_ini)+mperiod))))))-1))^(-1)
  wib_interp<-(-(exp(-exp(predict(wib_mod,data.frame(y=c(1:length(vect_ini))))))-1))^(-1)
  
  # plot
  
  ratios_ini<-c(vect_ini,rep(NA,mperiod))
  period<-c(1:length(ratios_ini))
  
  plot1_data<-as.data.frame(cbind(period,ratios_ini,c(wib_interp,wib_extrap),c(exp_interp,exp_extrap),c(pwr_interp,pwr_extrap)))
  colnames(plot1_data)<-c("period","ratios_ini","weibull","exponential","power")
  
  plot1<-plot1_data %>% ggplot(aes(x=period,y=ratios_ini))+geom_point()+xlab("Periods")+ylab("Age-to-age factors")+
    geom_line(aes(x=period,y=weibull),colour="red")+
    geom_line(aes(x=period,y=exponential),colour="green", lwd=1)+
    geom_line(aes(x=period,y=power),colour="blue")+
    annotate(geom="text",x=15,y=1.75,label=paste("Weibull: ",round(summary(wib_mod)$r.squared,3),sep=""),color="red")+
    annotate(geom="text",x=15,y=1.625,label=paste("Exponential ",round(summary(exp_mod)$r.squared,3),sep=""),color="green")+
    annotate(geom="text",x=15,y=1.5,label=paste("Power ",round(summary(pwr_mod)$r.squared,3),sep=""),color="blue")+
    ggtitle(label="Curve fit to age-to-age factors ")+theme_classic()
  
  plot2<-ggplotly(plot1,tooltip=c("period","ratios_ini","weibull","exponential","power"))
  
  # for displaying tails and R squared
  
  tab<-as.data.frame(cbind(c("Weibull","Exponential","Power"),c(round(summary(wib_mod)$r.squared,3),round(summary(exp_mod)$r.squared,3),round(summary(pwr_mod)$r.squared,3)),c(round(cumprod(wib_extrap)[mperiod],5),round(cumprod(exp_extrap)[mperiod],5),round(cumprod(pwr_extrap)[mperiod],5))),row.names = F,stringsAsFactors=F)
  colnames(tab)<-c("Curve","R_squared","tail")
  
  return(list(plot2,tab))
}

# initial choice of triangles, reading real data example

x=c("RAA_triangle","Sample_triangle")

Sample_triangle<-as.triangle(read.csv2("data_file.txt"),origin = "year",dev="period",value="value")
RAA_triangle<-RAA
colnames(RAA_triangle)<-as.numeric(colnames(RAA_triangle))-1

# running the App

runApp(getwd())

