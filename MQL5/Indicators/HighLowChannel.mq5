//+------------------------------------------------------------------+
//|                                               HighLowChannel.mq5 |
//|                                       Copyright 2020, Rodrigo S. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
//--- input parameters
input int Periodo = 21;

double HighBuffer[];
double LowBuffer[];

#property indicator_chart_window
#property indicator_plots   2
#property indicator_buffers 2

#property indicator_type1   DRAW_LINE
#property indicator_label1  "Banda High"
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_type2   DRAW_LINE
#property indicator_label2  "Banda Low"
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   SetIndexBuffer(0, HighBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_SHIFT, 0);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Periodo);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(1, LowBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_SHIFT, 0);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Periodo);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{

   int i,limit;

   if(rates_total<Periodo-1) return(0);

   if(prev_calculated==0)
      limit = Periodo-1;
   else
      limit = prev_calculated-1;

   for(i=limit;i<rates_total;i++)
   {
      HighBuffer[i] = Highest(high, Periodo, i);
      LowBuffer[i] = Lowest(low, Periodo, i);
      //HighBuffer[i]=CalcularMaxima(i,high,Periodo);
      //LowBuffer[i]=CalcularMinima(i,low,Periodo);
      //MiddleBuffer[i]=0;//(HighBuffer[i]-LowBuffer[i]);
   }

   return(rates_total);

}
//+------------------------------------------------------------------+
double CalcularMinima(int position,const double &low[],int period)
{
   double vMinima = 0;

   if(position<period) return(0);

   for(int i=0;i<period;i++)
   {
      if(low[position+i]<vMinima)
         vMinima = low[position+i];
   }

   return (vMinima);

}

double CalcularMaxima(int position,const double &high[],int period)
{
   double vMaxima = 0;

   for(int i=0;i<period;i++)
   {
      if(high[position+i]>vMaxima)
         vMaxima = high[position+i];
   }

   return (vMaxima);

}
