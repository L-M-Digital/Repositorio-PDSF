//+------------------------------------------------------------------+
//|                                                      sinaisF.mq5 |
//|                                                Marcelino Andrade |
//|                                              mrclnndrd@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>                                         //include the library for execution of trades
#include <Trade\PositionInfo.mqh>   

int               iMA_handle;                              //variable for storing the indicator handle
int               iMA_handle2; 

double            iMA_buf[];                               //dynamic array for storing indicator values
double            iMA_buf2[]; 
  
double            Close_buf[];                             //dynamic array for storing the closing price of each bar

string            my_symbol;                               //variable for storing the symbol
ENUM_TIMEFRAMES   my_timeframe;                             //variable for storing the time frame


input int         periodo=12;
input int         periodo2=40;

CTrade            m_Trade;                                 //structure for execution of trades
CPositionInfo     m_Position;                              //structure for obtaining information of positions

int OnInit()
  {
//---
   my_symbol=Symbol();
   my_timeframe=PERIOD_CURRENT;

   iMA_handle=iMA(my_symbol,my_timeframe,periodo,0,MODE_SMA,PRICE_CLOSE);
   iMA_handle2=iMA(my_symbol,my_timeframe,periodo2,0,MODE_SMA,PRICE_CLOSE); 
    
   if((iMA_handle==INVALID_HANDLE) || (iMA_handle2==INVALID_HANDLE))                            //check the availability of the indicator handle
   {
      Print("Failed to get the indicator handle");              //if the handle is not obtained, print the relevant error message into the log file
      return(-1);                                           //complete handling the error
   }
   
   ChartIndicatorAdd(ChartID(),0,iMA_handle);                  //add the indicator to the price chart
    ChartIndicatorAdd(ChartID(),0,iMA_handle2);  
   ArraySetAsSeries(iMA_buf,true);                            //set iMA_buf array indexing as time series
   ArraySetAsSeries(Close_buf,true);                          //set Close_buf array indexing as time series
   return(0);               
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(iMA_handle);
   ArrayFree(iMA_buf);
   
   IndicatorRelease(iMA_handle2);
   ArrayFree(iMA_buf2);   
    
   ArrayFree(Close_buf); 
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int err1=0;
   int err2=0;
   int err3=0;
      
   err1=CopyBuffer(iMA_handle,0,1,2,iMA_buf);
   err2=CopyBuffer(iMA_handle2,0,1,2,iMA_buf2);
   err3=CopyClose(my_symbol,my_timeframe,1,2,Close_buf);
   if(err1<0 || err2<0 || err3<0) 
   {
      Print("Failed to copy data from the indicator buffer or price chart buffer");  //then print the relevant error message into the log file
      return;                                                               //and exit the function
   }
   
   if(iMA_buf[1]<iMA_buf2[1] && iMA_buf[0]>iMA_buf2[0]) 
   
     {
      if(m_Position.Select(my_symbol))                     //if the position for this symbol already exists
        {
         if(m_Position.PositionType()==POSITION_TYPE_SELL) m_Trade.PositionClose(my_symbol);  //and this is a Sell position, then close it
         if(m_Position.PositionType()==POSITION_TYPE_BUY) return;                              //or else, if this is a Buy position, then exit
        }
      m_Trade.Buy(1,my_symbol);                          //if we got here, it means there is no position; then we open it
     }
     
   if(iMA_buf[1]>iMA_buf2[1] && iMA_buf[0]<iMA_buf2[0])
        {
      if(m_Position.Select(my_symbol))                     //if the position for this symbol already exists
        {
         if(m_Position.PositionType()==POSITION_TYPE_BUY) m_Trade.PositionClose(my_symbol);   //and this is a Buy position, then close it
         if(m_Position.PositionType()==POSITION_TYPE_SELL) return;                             //or else, if this is a Sell position, then exit
        }
      m_Trade.Sell(1,my_symbol);                         //if we got here, it means there is no position; then we open it
     }
   
   
   
  }
//+------------------------------------------------------------------+
